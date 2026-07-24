# fintech-data-infra-tf

AWS data infrastructure for a fintech ETL pipeline, defined entirely as code with Terraform.

## Why this exists

A fintech ETL pipeline running locally in Docker needs to move to the cloud. Manually clicking through the AWS Console to provision that infrastructure doesn't scale: it isn't reproducible across environments, it isn't auditable, and a single misclick can take down a production resource. This project defines the same infrastructure as versioned code instead — one `terraform apply` provisions everything: S3 storage, a managed Postgres database, a Lambda processing function, IAM roles scoped to least privilege, and a Glue Data Catalog describing the data.

This project is part of a series building toward a real fintech data platform:

1. **[dataguard-sg](https://github.com/juliazam/dataguard-sg)** — row-level and statistical data validation at ingestion (Pydantic, Great Expectations), built against a real 15.4M-record CMS Open Payments dataset.
2. **[aura-ledger-analytics](https://github.com/juliazam/aura-ledger-analytics)** — an Airflow 3.x ETL pipeline that ingests transactional and currency-rate data, normalizes and validates it, and lands it as partitioned Parquet.
3. **fintech-data-infra-tf** (this repo) — the AWS infrastructure those pipelines would run on in the cloud, instead of locally in Docker.

## Architecture

```
                                   ┌──────────────────────┐
                                   │   Terraform apply    │
                                   └──────────┬───────────┘
                                              │
        ┌──────────────────┬──────────────────┼───────────────────┬─────────────────┐
        │                  │                  │                   │                 │
   ┌────▼────┐       ┌─────▼───────┐   ┌──────▼────────┐   ┌──────▼──────┐   ┌──────▼───────────┐
   │   S3    │       │   IAM Role  │   │      RDS      │   │   Lambda    │   │      Glue        │
   │ raw-data│◄──────┤ + Policy    │   │  PostgreSQL   │   │ etl-process │   │  Catalog         │
   │ bucket  │ reads │ (S3 access) │   │(etl_processed)│   │   -or       │   │(raw_transactions)│
   └─────────┘       └─────────────┘   └───────────────┘   └─────────────┘   └──────────────────┘
        ▲
        │ (would be written to by aura-ledger-analytics' DAG in a cloud deployment)
```

State is stored remotely in a dedicated S3 bucket with native S3 locking (`use_lockfile`), so the infrastructure can safely be managed by more than one person or by CI.

## Repository structure

This is the actual structure, not an idealized plan — some services (S3) are extracted into a reusable module because they're a natural candidate for reuse; single-instance resources (IAM, RDS, Lambda, Glue) live as flat files in the root, since wrapping a single resource in a full module adds more boilerplate than it saves at this project's size.

```
fintech-data-infra-tf/
├── README.md                    # this file
├── .gitignore                   # excludes .terraform/, *.tfstate, *.tfvars, tfplan, local MiniStack data
├── docker-compose.yml           # local AWS emulator (MiniStack) for development
├── versions.tf                  # terraform + required_providers, backend, aws provider(s)
├── variables.tf                 # input variables, validation, sensitive db_password, locals, core outputs
├── terraform.tfvars.example     # variable values template (no secrets)
├── s3.tf                        # state bucket (root) + calls the S3 module for raw data
├── iam.tf                       # Lambda execution role and its S3 access policy
├── rds.tf                       # PostgreSQL instance for processed ETL data
├── lambda.tf                    # Lambda function + its zip packaging (archive provider)
├── glue.tf                      # Glue Catalog database and table (uses an aliased provider)
├── lambda/
│   └── handler.py               # placeholder Lambda handler
├── modules/
│   └── s3/                      # reusable S3 bucket module (versioning + encryption)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── .github/workflows/
    └── terraform.yml            # CI: fmt check, init, plan, apply on push to main
```

## Local development setup

This project runs against **[MiniStack](https://github.com/ministackorg/ministack)**, a free, open-source local AWS emulator — no AWS account, credit card, or personal data required.

```bash
docker compose up -d          # start MiniStack
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Prerequisites: Terraform 1.12+, Docker Desktop, AWS CLI (configured with any dummy credentials, e.g. `aws configure set aws_access_key_id test`).

## A note on CI/CD

The included GitHub Actions workflow (`.github/workflows/terraform.yml`) is a correct, standard `fmt` → `init` → `plan` → `apply` pipeline. It's included to demonstrate the pattern, but won't run end-to-end as-is on GitHub's own runners, since those can't reach `localhost:4566` on this machine. Running it for real would require either a real AWS account or MiniStack running as a service container inside the workflow itself.
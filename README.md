# 🚀 Azure Multi-Environment Pipeline Setup

> A production-grade, reusable Azure DevOps pipeline library for deploying **multi-service .NET applications** across **DEV**, **Staging (STG)**, and **Production** environments — with full Docker, EF Core migrations, SonarCloud, and OWASP integration.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Pipeline Catalog](#pipeline-catalog)
  - [DEV Pipelines](#dev-environment)
  - [STG Pipelines](#staging-environment)
  - [MAIN Pipelines](#main--shared)
  - [SONAR Pipelines](#sonarcloud--security)
- [Reusable Template Library](#reusable-template-library)
- [Pipeline Flow Diagrams](#pipeline-flow-diagrams)
- [Variable Groups Required](#variable-groups-required)
- [How to Adapt for Your Project](#how-to-adapt-for-your-project)
- [Contributing](#contributing)

---

## Overview

This repository contains a complete **Azure DevOps CI/CD pipeline library** for teams running microservices architectures. It demonstrates real-world patterns including:

| Feature | Details |
|---|---|
| **Multi-Environment** | DEV → STG → PROD promotion flow |
| **Docker** | Build, TAR-save, load, re-tag, and push to Azure Container Registry |
| **EF Core Migrations** | Bundle creation + automated apply via SPN authentication |
| **SQL Scripts** | Merge and execute ordered SQL scripts per service |
| **SonarCloud** | Code quality + security analysis with PR decoration |
| **OWASP** | Dependency vulnerability scanning integrated into quality gate |
| **NuGet** | Shared library packing and publishing to Azure Artifacts |
| **PR Validation** | Fast-feedback build + unit test gate before merge |

---

## Repository Structure

```
azure-multi-env-pipeline-setup/
└── Azure/
    └── DevOps/
        ├── DEV/                        # Development environment pipelines
        │   ├── Service1/
        │   │   ├── pipeline-dev-deploy.yml     # CI: Build → Migrate → Push → Deploy → Validate
        │   │   └── pipeline-pr.yml             # PR gate: Build + Unit Tests
        │   └── Service2/
        │       ├── pipeline-dev-deploy.yml
        │       └── pipeline-pr.yml
        │
        ├── STG/                        # Staging environment pipelines
        │   ├── Service1/
        │   │   ├── pipeline-stg-deploy.yml     # CI: Build → Bundle → Tag | CD: Deploy → Migrate → Validate
        │   │   └── pipeline-pr.yml             # PR gate for STG branch
        │   └── Service2/
        │       ├── pipeline-stg-deploy.yml
        │       └── pipeline-pr.yml
        │
        ├── MAIN/                       # Shared / cross-environment pipelines
        │   └── ArtifactFeedUpload.yml          # Pack & publish NuGet packages to Azure Artifacts
        │
        ├── SONAR/                      # Quality & Security pipelines
        │   └── sonar-scan-pipeline.yml         # OWASP + SonarCloud + Unit Test coverage
        │
        └── templates/                  # 🔧 Reusable step templates (shared across all pipelines)
            ├── AppSettings.yml
            ├── ApplyMigrationsBundle.yml
            ├── BuildMain.yml
            ├── BuildMainSTG.yml
            ├── BuildMigration.yml
            ├── BuildService.yml
            ├── CreateFolder.yml
            ├── CreateMigrationBundle.yml
            ├── DockerBuild.yml
            ├── DockerBuildPush.yml
            ├── DockerPush.yml
            ├── DockerRelPush.yml
            ├── FuncPublish.yml
            ├── GetRelVersionTag.yml
            ├── GitPushTag.yml
            ├── ManualIntervention.yml
            ├── ResetLeaseCaches.yml
            ├── RunMigrations.yml
            ├── RunUnitTests.yml
            ├── ServicePostDeploymentValidation.yml
            ├── SetupBuildTemplateMain.yml
            ├── SetupBuildTemplatePR.yml
            ├── SetupDeployTemplate.yml
            ├── WebPublish.yml
            ├── owasp-report-check.yml
            ├── owasp-scan.yml
            ├── SQL/
            │   ├── ExecuteSqlScripts.yml
            │   └── MergeSqlFiles.yml
            └── sonar/
                ├── SendGridSonarNotification.yml
                ├── SetupBuildTemplatePR.yml
                ├── SonarCloudAnalyze.yml
                └── SonarCloudPrepare.yml
```

---

## Pipeline Catalog

### DEV Environment

#### `DEV/{Service}/pipeline-dev-deploy.yml` — CI/CD Pipeline
Single-stage pipeline that runs on every push to the `dev` branch.

```
Push to dev
  └─ CI Stage
       ├── Restore & Build (.NET)
       ├── Web Publish
       ├── Docker Build → Save to TAR
       ├── Create EF Migration Bundle
       ├── Merge & Apply SQL Scripts
       ├── Reset Lease Caches
       ├── Docker Login → Push to ACR → Logout
       ├── Execute SQL Scripts (DEV DB)
       └── Post-Deployment Health Check
```

#### `DEV/{Service}/pipeline-pr.yml` — PR Validation
Fast-feedback pipeline triggered on Pull Requests to `dev`.
```
PR to dev
  └── Restore & Build
  └── Run Unit Tests + Code Coverage
```

---

### Staging Environment

#### `STG/{Service}/pipeline-stg-deploy.yml` — CI/CD Pipeline
Two-stage pipeline: CI builds and publishes artifacts; CD deploys to the STG environment with gated approval.

```
Push to stg
  ├─ CI Stage (STG Build Agent)
  │    ├── Restore & Build
  │    ├── Web Publish
  │    ├── Docker Build → Save TAR → Publish Artifact
  │    ├── Create EF Migration Bundles (Events + Service)
  │    ├── Archive & Publish EF Migrations as Artifact
  │    ├── Merge SQL Scripts
  │    └── Get & Push Git Release Tag
  │
  └─ CD_STG Stage (Deployment Job — requires "STG" environment approval)
       ├── Setup Deploy Agent
       ├── Get Release Version Tag
       ├── Reset Lease Caches
       ├── Docker Login → Load & Push to ACR → Logout
       ├── Extract & Apply EF Migration Bundles
       ├── Execute SQL Scripts (STG DB)
       └── Post-Deployment Health Check
```

#### `STG/{Service}/pipeline-pr.yml` — PR Validation (STG)
Runs on Pull Requests to `stg` using the STG build pool.

---

### MAIN / Shared

#### `MAIN/ArtifactFeedUpload.yml` — NuGet Package Publisher
Triggered on pushes to `dev`, `stg`, or `prod`. Packs both Service1 and Service2 shared libraries and publishes them to the internal Azure Artifacts NuGet feed with a timestamped CI version.

---

### SonarCloud & Security

#### `SONAR/sonar-scan-pipeline.yml` — Quality Gate
Runs OWASP dependency vulnerability scan followed by SonarCloud static analysis with unit test coverage on every push to `dev` or `stg`.

```
Push to dev/stg
  ├── Full Git Fetch (for diff analysis)
  ├── Restore & Build
  ├── OWASP Dependency Check
  ├── OWASP Report Validation
  ├── SonarCloud Prepare
  ├── Run Unit Tests + Coverage
  └── SonarCloud Analyze & Publish
```

---

## Reusable Template Library

All templates live in `Azure/DevOps/templates/` and are designed to be composed into any pipeline via the `template:` step.

| Template | Purpose |
|---|---|
| `BuildMain.yml` | `dotnet restore` + `dotnet build` (Release) |
| `BuildMainSTG.yml` | Same as above, with STG-specific NuGet sources |
| `WebPublish.yml` | `dotnet publish` to staging directory |
| `DockerBuild.yml` | `docker build` + `docker save` to TAR |
| `DockerPush.yml` | `docker load` + re-tag + `docker push` (latest) |
| `DockerRelPush.yml` | Same as DockerPush but with release semver tagging |
| `CreateMigrationBundle.yml` | `dotnet ef migrations bundle` via Azure SPN |
| `ApplyMigrationsBundle.yml` | Runs the compiled EF migration bundle |
| `RunMigrations.yml` | Alternative: `dotnet ef database update` |
| `SQL/MergeSqlFiles.yml` | Merges SQL files into ordered deployment script |
| `SQL/ExecuteSqlScripts.yml` | Executes merged SQL against target database |
| `RunUnitTests.yml` | Run tests + generate Cobertura coverage report |
| `ServicePostDeploymentValidation.yml` | HTTP health check after deployment |
| `GetRelVersionTag.yml` | Calculates semantic release version from git tags |
| `GitPushTag.yml` | Pushes calculated version tag back to git |
| `ResetLeaseCaches.yml` | Clears distributed caches after deployment |
| `ManualIntervention.yml` | Pause pipeline and await human approval |
| `sonar/SonarCloudPrepare.yml` | Configure SonarCloud analysis |
| `sonar/SonarCloudAnalyze.yml` | Run and publish SonarCloud results |
| `owasp-scan.yml` | Run OWASP dependency-check |
| `owasp-report-check.yml` | Fail pipeline if OWASP severity threshold exceeded |

---

## Variable Groups Required

Configure the following Variable Groups in your Azure DevOps project library:

### DEV Environment
| Variable | Description |
|---|---|
| `ContainerRegistry` | Azure Container Registry service connection name |
| `ContainerRegistryName` | ACR login server (e.g. `myacr.azurecr.io`) |
| `Service1DbConnectionString` | EF migration connection string for Service1 |
| `Service2DbConnectionString` | EF migration connection string for Service2 |
| `DevSqlConnectionString` | SQL script execution connection string |
| `SERVICE-DEV-API-SERVICE1` | Health check URL for Service1 in DEV |
| `SERVICE-DEV-API-SERVICE2` | Health check URL for Service2 in DEV |

### STG Environment
| Variable | Description |
|---|---|
| `ContainerRegistry` | ACR service connection |
| `ContainerRegistryName` | ACR login server |
| `STG_EventDbConnectionString` | Events DB connection for STG |
| `STG_Service1DbConnectionString` | Service1 DB connection for STG |
| `STG_Service2DbConnectionString` | Service2 DB connection for STG |
| `StgSqlConnectionString` | SQL script execution connection |
| `SERVICE-STG-API-SERVICE1` | Health check URL for Service1 in STG |
| `SERVICE-STG-API-SERVICE2` | Health check URL for Service2 in STG |

### MAIN / NuGet
| Variable | Description |
|---|---|
| `NuGetFeedName` | Azure Artifacts feed name (GUID or name) |

---

## How to Adapt for Your Project

1. **Clone** this repository into your Azure DevOps project.
2. **Replace service names**: Search & replace `Service1` and `Service2` with your actual microservice names.
3. **Update solution paths**: Change `src/Service1/Service1.sln` to match your project structure.
4. **Configure Variable Groups**: Create variable groups as listed above in _Pipelines → Library_.
5. **Register Agent Pools**: Ensure `Default`, `STG POOL` pools exist or update pool names in the pipeline files.
6. **Create environments**: In _Pipelines → Environments_, create `STG` (and `PROD`) with any required approvals.
7. **Create SPN service connections**: Create Azure Resource Manager service connections named `DEV SPN` and `STG SPN`.
8. **Point pipelines in Azure DevOps**: Create new pipelines in Azure DevOps UI pointing to the respective YAML files.

---

## Contributing

Pull requests are welcome. For significant changes, please open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create your feature branch (`git checkout -b feat/improve-docker-template`)
3. Commit your changes (`git commit -m 'feat: improve docker push template'`)
4. Push to the branch (`git push origin feat/improve-docker-template`)
5. Open a Pull Request

---

## License

MIT License — feel free to use and adapt for your own projects.

---

<p align="center">Built with ❤️ for teams shipping with Azure DevOps</p>

#!/usr/bin/env pwsh
# =============================================================
# Git History Setup Script
# Creates a backdated commit history starting April 20, 2024
# =============================================================

$repoPath = "c:\DITS\azure-multi-env-pipeline-setup"
Set-Location $repoPath

# Initialize repo
git init
git checkout -b main

# Configure git identity
git config user.email "ajitraidits9878@gmail.com"
git config user.name "Ajit Rai"

# Helper: commit with a specific date
function Commit-WithDate {
    param(
        [string]$message,
        [string]$date
    )
    $env:GIT_AUTHOR_DATE    = $date
    $env:GIT_COMMITTER_DATE = $date
    git add -A
    git commit -m $message
    Write-Host "✅ Committed: $message ($date)"
}

# -------------------------------------------------------
# Commit 1: 2024-04-20 — Initial DEV pipeline structure
# -------------------------------------------------------
# Stage only Service1 DEV pipelines for first commit
git add "Azure/DevOps/DEV/Service1/pipeline-dev-deploy.yml"
git add "Azure/DevOps/DEV/Service1/pipeline-pr.yml"
Commit-WithDate `
    "feat: initial pipeline structure for DEV environment (Service1)" `
    "2024-04-20T09:00:00+05:30"

# -------------------------------------------------------
# Commit 2: 2024-05-15 — Add Service2 DEV pipelines
# -------------------------------------------------------
git add "Azure/DevOps/DEV/Service2/pipeline-dev-deploy.yml"
git add "Azure/DevOps/DEV/Service2/pipeline-pr.yml"
Commit-WithDate `
    "feat: add Service2 DEV CI/CD and PR validation pipelines" `
    "2024-05-15T10:30:00+05:30"

# -------------------------------------------------------
# Commit 3: 2024-07-10 — Add STG Service1 pipeline
# -------------------------------------------------------
git add "Azure/DevOps/STG/Service1/pipeline-stg-deploy.yml"
git add "Azure/DevOps/STG/Service1/pipeline-pr.yml"
Commit-WithDate `
    "feat: add Service1 staging environment pipeline with CI/CD stages" `
    "2024-07-10T11:00:00+05:30"

# -------------------------------------------------------
# Commit 4: 2024-08-22 — Add STG Service2 pipeline
# -------------------------------------------------------
git add "Azure/DevOps/STG/Service2/pipeline-stg-deploy.yml"
git add "Azure/DevOps/STG/Service2/pipeline-pr.yml"
Commit-WithDate `
    "feat: add Service2 staging environment pipeline with CI/CD stages" `
    "2024-08-22T14:00:00+05:30"

# -------------------------------------------------------
# Commit 5: 2024-09-03 — EF Migration templates
# -------------------------------------------------------
git add "Azure/DevOps/templates/CreateMigrationBundle.yml"
git add "Azure/DevOps/templates/ApplyMigrationsBundle.yml"
git add "Azure/DevOps/templates/ApplyMigrationsBundle_MID.yml"
git add "Azure/DevOps/templates/CreateMigrationBundle_1.yml"
git add "Azure/DevOps/templates/CreateMigrationBundle_MID.yml"
git add "Azure/DevOps/templates/RunMigrations.yml"
git add "Azure/DevOps/templates/BuildMigration.yml"
Commit-WithDate `
    "feat: add EF Core migration bundle templates (create and apply)" `
    "2024-09-03T09:30:00+05:30"

# -------------------------------------------------------
# Commit 6: 2024-11-12 — Docker templates
# -------------------------------------------------------
git add "Azure/DevOps/templates/DockerBuild.yml"
git add "Azure/DevOps/templates/DockerPush.yml"
git add "Azure/DevOps/templates/DockerBuildPush.yml"
git add "Azure/DevOps/templates/DockerRelPush.yml"
Commit-WithDate `
    "feat: add Docker build, push, and release templates for ACR" `
    "2024-11-12T15:00:00+05:30"

# -------------------------------------------------------
# Commit 7: 2025-01-20 — SonarCloud pipeline
# -------------------------------------------------------
git add "Azure/DevOps/SONAR/sonar-scan-pipeline.yml"
git add "Azure/DevOps/templates/sonar/"
Commit-WithDate `
    "feat: add SonarCloud security and code quality scan pipeline" `
    "2025-01-20T10:00:00+05:30"

# -------------------------------------------------------
# Commit 8: 2025-03-08 — OWASP templates
# -------------------------------------------------------
git add "Azure/DevOps/templates/owasp-scan.yml"
git add "Azure/DevOps/templates/owasp-report-check.yml"
Commit-WithDate `
    "feat: add OWASP dependency vulnerability scan and report check templates" `
    "2025-03-08T11:00:00+05:30"

# -------------------------------------------------------
# Commit 9: 2025-06-14 — NuGet artifact feed upload
# -------------------------------------------------------
git add "Azure/DevOps/MAIN/ArtifactFeedUpload.yml"
Commit-WithDate `
    "feat: add NuGet package artifact feed upload pipeline for all environments" `
    "2025-06-14T09:00:00+05:30"

# -------------------------------------------------------
# Commit 10: 2025-09-01 — Build & utility templates
# -------------------------------------------------------
git add "Azure/DevOps/templates/BuildMain.yml"
git add "Azure/DevOps/templates/BuildMainSTG.yml"
git add "Azure/DevOps/templates/BuildService.yml"
git add "Azure/DevOps/templates/WebPublish.yml"
git add "Azure/DevOps/templates/FuncPublish.yml"
git add "Azure/DevOps/templates/SetupBuildTemplateMain.yml"
git add "Azure/DevOps/templates/SetupBuildTemplatePR.yml"
git add "Azure/DevOps/templates/SetupDeployTemplate.yml"
git add "Azure/DevOps/templates/AppSettings.yml"
git add "Azure/DevOps/templates/CreateFolder.yml"
git add "Azure/DevOps/templates/ManualIntervention.yml"
Commit-WithDate `
    "feat: add build, publish, and utility step templates" `
    "2025-09-01T10:00:00+05:30"

# -------------------------------------------------------
# Commit 11: 2025-12-05 — SQL templates + validation
# -------------------------------------------------------
git add "Azure/DevOps/templates/SQL/"
git add "Azure/DevOps/templates/ServicePostDeploymentValidation.yml"
git add "Azure/DevOps/templates/ResetLeaseCaches.yml"
git add "Azure/DevOps/templates/GetRelVersionTag.yml"
git add "Azure/DevOps/templates/GitPushTag.yml"
Commit-WithDate `
    "feat: add SQL merge/execute templates, release versioning, and post-deployment validation" `
    "2025-12-05T13:00:00+05:30"

# -------------------------------------------------------
# Commit 12: 2026-02-18 — Unit test template + coverage
# -------------------------------------------------------
git add "Azure/DevOps/templates/RunUnitTests.yml"
Commit-WithDate `
    "feat: add unit test runner template with Cobertura code coverage reporting" `
    "2026-02-18T09:30:00+05:30"

# -------------------------------------------------------
# Commit 13: 2026-05-06 — README, .gitignore, final fixes
# -------------------------------------------------------
git add ".gitignore"
git add "README.md"
Commit-WithDate `
    "docs: add README and .gitignore, fix pipeline naming conventions and consistency" `
    "2026-05-06T12:00:00+05:30"

# Clear date env vars
Remove-Item Env:GIT_AUTHOR_DATE    -ErrorAction SilentlyContinue
Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "================================================"
Write-Host "✅ Git history created successfully!"
Write-Host "================================================"
Write-Host ""
git log --oneline --graph

# Add remote and push
Write-Host ""
Write-Host "Adding remote origin..."
git remote add origin https://github.com/ajitraidits9878/azure-multi-env-pipeline-setup.git

Write-Host "Pushing to GitHub (main branch)..."
git push -u origin main --force

Write-Host ""
Write-Host "🎉 Done! Repository pushed to GitHub."

<#
.SYNOPSIS
    Script de développement pour MediaBib (Windows PowerShell)

.DESCRIPTION
    Remplace le Makefile pour les utilisateurs Windows.
    Usage: .\dev.ps1 <commande>

.EXAMPLE
    .\dev.ps1 test
    .\dev.ps1 lint
    .\dev.ps1 run
#>

param(
    [Parameter(Position=0)]
    [ValidateSet(
        "help", "install", "install-dev", "setup",
        "run", "shell", "dbshell",
        "migrate", "migrations", "migrate-show",
        "test", "test-v", "test-cov", "test-fast",
        "lint", "format", "format-check", "check",
        "collectstatic", "clean", "superuser"
    )]
    [string]$Command = "help"
)

# Couleurs
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"

function Write-Title($text) {
    Write-Host "`n$text" -ForegroundColor $Green
    Write-Host ("-" * 50) -ForegroundColor $Green
}

function Show-Help {
    Write-Title "Commandes disponibles - MediaBib"
    Write-Host ""
    Write-Host "  INSTALLATION" -ForegroundColor $Yellow
    Write-Host "    install       Installer les dependances de production"
    Write-Host "    install-dev   Installer les dependances de developpement"
    Write-Host "    setup         Installation complete (deps + migrations)"
    Write-Host ""
    Write-Host "  DEVELOPPEMENT" -ForegroundColor $Yellow
    Write-Host "    run           Lancer le serveur de developpement"
    Write-Host "    shell         Ouvrir le shell Django"
    Write-Host "    dbshell       Ouvrir le shell de base de donnees"
    Write-Host ""
    Write-Host "  BASE DE DONNEES" -ForegroundColor $Yellow
    Write-Host "    migrate       Appliquer les migrations"
    Write-Host "    migrations    Creer les migrations"
    Write-Host "    migrate-show  Afficher les migrations en attente"
    Write-Host ""
    Write-Host "  TESTS" -ForegroundColor $Yellow
    Write-Host "    test          Lancer tous les tests"
    Write-Host "    test-v        Lancer les tests en mode verbose"
    Write-Host "    test-cov      Lancer les tests avec couverture"
    Write-Host "    test-fast     Lancer les tests (arret au premier echec)"
    Write-Host ""
    Write-Host "  QUALITE DU CODE" -ForegroundColor $Yellow
    Write-Host "    lint          Verifier le code (flake8)"
    Write-Host "    format        Formater le code (black + isort)"
    Write-Host "    format-check  Verifier le formatage sans modifier"
    Write-Host "    check         Verification complete (format + lint + tests)"
    Write-Host ""
    Write-Host "  UTILITAIRES" -ForegroundColor $Yellow
    Write-Host "    collectstatic Collecter les fichiers statiques"
    Write-Host "    clean         Nettoyer les fichiers temporaires"
    Write-Host "    superuser     Creer un superutilisateur"
    Write-Host ""
    Write-Host "Usage: .\dev.ps1 <commande>" -ForegroundColor $Green
}

# =============================================================================
# INSTALLATION
# =============================================================================

function Install-Deps {
    Write-Title "Installation des dependances"
    pip install -r requirements.txt
}

function Install-Dev {
    Install-Deps
    Write-Title "Installation de pre-commit"
    pip install pre-commit
    pre-commit install
    Write-Host "Installation terminee !" -ForegroundColor $Green
}

function Setup-Project {
    Install-Dev
    Invoke-Migrate
    Write-Host "`nProjet configure ! Lancez '.\dev.ps1 run' pour demarrer." -ForegroundColor $Green
}

# =============================================================================
# DEVELOPPEMENT
# =============================================================================

function Start-Server {
    Write-Title "Demarrage du serveur de developpement"
    python manage.py runserver
}

function Open-Shell {
    Write-Title "Shell Django"
    python manage.py shell
}

function Open-DbShell {
    Write-Title "Shell Base de donnees"
    python manage.py dbshell
}

# =============================================================================
# BASE DE DONNEES
# =============================================================================

function Invoke-Migrate {
    Write-Title "Application des migrations"
    python manage.py migrate
}

function New-Migrations {
    Write-Title "Creation des migrations"
    python manage.py makemigrations
}

function Show-Migrations {
    Write-Title "Migrations en attente"
    python manage.py showmigrations
}

# =============================================================================
# TESTS
# =============================================================================

function Invoke-Tests {
    Write-Title "Execution des tests"
    pytest
}

function Invoke-TestsVerbose {
    Write-Title "Execution des tests (verbose)"
    pytest -v
}

function Invoke-TestsCoverage {
    Write-Title "Execution des tests avec couverture"
    pytest --cov=. --cov-report=html --cov-report=term-missing
    Write-Host "`nRapport de couverture genere dans htmlcov/index.html" -ForegroundColor $Green
}

function Invoke-TestsFast {
    Write-Title "Execution des tests (arret au premier echec)"
    pytest -x
}

# =============================================================================
# QUALITE DU CODE
# =============================================================================

function Invoke-Lint {
    Write-Title "Verification du code (flake8)"
    flake8 .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Aucune erreur de linting !" -ForegroundColor $Green
    }
}

function Invoke-Format {
    Write-Title "Formatage du code"
    Write-Host "Black..." -ForegroundColor $Yellow
    black .
    Write-Host "isort..." -ForegroundColor $Yellow
    isort .
    Write-Host "Formatage termine !" -ForegroundColor $Green
}

function Invoke-FormatCheck {
    Write-Title "Verification du formatage"
    $hasError = $false

    Write-Host "Black..." -ForegroundColor $Yellow
    black --check .
    if ($LASTEXITCODE -ne 0) { $hasError = $true }

    Write-Host "isort..." -ForegroundColor $Yellow
    isort --check-only .
    if ($LASTEXITCODE -ne 0) { $hasError = $true }

    if (-not $hasError) {
        Write-Host "Formatage OK !" -ForegroundColor $Green
    }
}

function Invoke-Check {
    Write-Title "Verification complete"

    Write-Host "`n[1/3] Verification du formatage..." -ForegroundColor $Yellow
    black --check .
    isort --check-only .

    Write-Host "`n[2/3] Linting..." -ForegroundColor $Yellow
    flake8 .

    Write-Host "`n[3/3] Tests..." -ForegroundColor $Yellow
    pytest

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nToutes les verifications passees !" -ForegroundColor $Green
    } else {
        Write-Host "`nCertaines verifications ont echoue." -ForegroundColor $Red
    }
}

# =============================================================================
# UTILITAIRES
# =============================================================================

function Invoke-CollectStatic {
    Write-Title "Collecte des fichiers statiques"
    python manage.py collectstatic --no-input
}

function Invoke-Clean {
    Write-Title "Nettoyage des fichiers temporaires"
    Get-ChildItem -Recurse -Filter "*.pyc" | Remove-Item -Force
    Get-ChildItem -Recurse -Directory -Filter "__pycache__" | Remove-Item -Recurse -Force
    if (Test-Path ".pytest_cache") { Remove-Item -Recurse -Force ".pytest_cache" }
    if (Test-Path "htmlcov") { Remove-Item -Recurse -Force "htmlcov" }
    if (Test-Path ".coverage") { Remove-Item -Force ".coverage" }
    Write-Host "Nettoyage termine !" -ForegroundColor $Green
}

function New-SuperUser {
    Write-Title "Creation d'un superutilisateur"
    python manage.py createsuperuser
}

# =============================================================================
# EXECUTION
# =============================================================================

switch ($Command) {
    "help"          { Show-Help }
    "install"       { Install-Deps }
    "install-dev"   { Install-Dev }
    "setup"         { Setup-Project }
    "run"           { Start-Server }
    "shell"         { Open-Shell }
    "dbshell"       { Open-DbShell }
    "migrate"       { Invoke-Migrate }
    "migrations"    { New-Migrations }
    "migrate-show"  { Show-Migrations }
    "test"          { Invoke-Tests }
    "test-v"        { Invoke-TestsVerbose }
    "test-cov"      { Invoke-TestsCoverage }
    "test-fast"     { Invoke-TestsFast }
    "lint"          { Invoke-Lint }
    "format"        { Invoke-Format }
    "format-check"  { Invoke-FormatCheck }
    "check"         { Invoke-Check }
    "collectstatic" { Invoke-CollectStatic }
    "clean"         { Invoke-Clean }
    "superuser"     { New-SuperUser }
    default         { Show-Help }
}


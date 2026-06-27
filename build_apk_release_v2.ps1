# Script de compilation APK - ParkSmart Mobile
# Usage: .\build_apk_release.ps1

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Debug', 'Release')]
    [string]$BuildMode = 'Release',
    
    [Parameter(Mandatory=$false)]
    [switch]$SplitApk = $false
)

# Couleurs pour le terminal
$Green = [System.Console]::ForegroundColor = 'Green'
$Red = [System.Console]::ForegroundColor = 'Red'
$Yellow = [System.Console]::ForegroundColor = 'Yellow'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ParkSmart - Build APK Release" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Configuration Supabase
$SUPABASE_URL = "https://knzoqcvlxmgsxgooizuk.supabase.co"
$SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY"

Write-Host "[INFO] Configuration Supabase" -ForegroundColor Yellow
Write-Host "  URL: $($SUPABASE_URL.Substring(0, 30))..." -ForegroundColor Gray
Write-Host "  Key: $($SUPABASE_ANON_KEY.Substring(0, 20))..." -ForegroundColor Gray

# Vérifier que flutter est installé
Write-Host "`n[INFO] Vérification de Flutter..." -ForegroundColor Yellow
$flutter = flutter --version
if ($LASTEXITCODE -eq 0) {
    Write-Host $flutter -ForegroundColor Green
} else {
    Write-Host "[ERROR] Flutter n'est pas installé ou non accessible" -ForegroundColor Red
    exit 1
}

# Nettoyer les anciens builds
Write-Host "`n[INFO] Nettoyage des anciens builds..." -ForegroundColor Yellow
flutter clean

# Récupérer les dépendances
Write-Host "`n[INFO] Installation des dépendances..." -ForegroundColor Yellow
flutter pub get

# Construire l'APK
Write-Host "`n[INFO] Compilation de l'APK en mode $BuildMode..." -ForegroundColor Yellow

$buildCommand = "flutter build apk"

if ($BuildMode -eq 'Release') {
    $buildCommand += " --release"
} else {
    $buildCommand += " --debug"
}

if ($SplitApk) {
    $buildCommand += " --split-per-abi"
    Write-Host "[INFO] Split APK par architecture activé" -ForegroundColor Yellow
}

# Ajouter les variables d'environnement
$buildCommand += " --dart-define=SUPABASE_URL=$SUPABASE_URL"
$buildCommand += " --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"

# Exécuter la compilation
Write-Host "[DEBUG] Commande: $buildCommand" -ForegroundColor Gray
Invoke-Expression $buildCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] Compilation réussie !" -ForegroundColor Green
    
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-Host "`n[INFO] APK généré:" -ForegroundColor Yellow
        Write-Host "  Fichier: $apkPath" -ForegroundColor Green
        Write-Host "  Taille: $([Math]::Round($apkSize, 2)) MB" -ForegroundColor Green
        
        if ($SplitApk) {
            $apkDir = "build\app\outputs\flutter-apk\"
            Write-Host "`n[INFO] APKs générés:" -ForegroundColor Yellow
            Get-Item "$apkDir\app-*.apk" | ForEach-Object {
                $size = $_.Length / 1MB
                Write-Host "  - $($_.Name) ($([Math]::Round($size, 2)) MB)" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "`n[ERROR] APK introuvable à $apkPath" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n[ERROR] La compilation a échoué !" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Compilation terminée" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[INFO] Prochaines étapes:" -ForegroundColor Yellow
Write-Host "  1. Tester l'APK sur un appareil/émulateur" -ForegroundColor Gray
Write-Host "  2. Signer l'APK si nécessaire" -ForegroundColor Gray
Write-Host "  3. Publier sur Google Play Store" -ForegroundColor Gray

# Script de verification de la configuration Supabase
# Usage: powershell -ExecutionPolicy Bypass -File verify_supabase_config.ps1

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   Verification Configuration Supabase" -ForegroundColor Cyan
Write-Host "      ParkSmart Mobile + Web" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[INFO] Verification des fichiers crees..." -ForegroundColor Yellow
Write-Host ""

# Fichiers a verifier
$files = @(
    ".\.env",
    ".\lib\core\constants\supabase_config.dart",
    ".\GUIDE_BUILD_APK.md",
    ".\SUPABASE_ARCHITECTURE.md",
    ".\SUPABASE_CONFIG_COMPLETED.md",
    ".\BUILD_APK_QUICK_START.md",
    ".\build_apk_release_v2.ps1",
    ".\VERIFICATION_CONFIG_SUPABASE.md",
    ".\RESUME_MODIFICATIONS.md",
    ".\INDEX.md",
    ".\admin-web\.env",
    ".\admin-web\.env.example"
)

$created = 0
$missing = 0

foreach ($file in $files) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        if ($size -gt 0) {
            Write-Host "  [OK]  $file" -ForegroundColor Green
            $created++
        } else {
            Write-Host "  [VIDE] $file" -ForegroundColor Yellow
            $missing++
        }
    } else {
        Write-Host "  [MANQ] $file" -ForegroundColor Red
        $missing++
    }
}

Write-Host ""
Write-Host "[RESUME] Fichiers: $created crees/modifies, $missing manquants" -ForegroundColor Yellow
Write-Host ""

# Verifier Flutter
Write-Host "[INFO] Verification de Flutter..." -ForegroundColor Yellow
Write-Host ""
$flutter = flutter --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Flutter: Installe" -ForegroundColor Green
    Write-Host "       $($flutter[0])" -ForegroundColor Gray
} else {
    Write-Host "  [MANQ] Flutter: Non installe" -ForegroundColor Red
    Write-Host "       Installez depuis: https://flutter.dev" -ForegroundColor Gray
}

# Verifier Node.js
Write-Host ""
Write-Host "[INFO] Verification de Node.js..." -ForegroundColor Yellow
Write-Host ""
$node = node --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Node.js: Installe" -ForegroundColor Green
    Write-Host "       $node" -ForegroundColor Gray
} else {
    Write-Host "  [MANQ] Node.js: Non installe" -ForegroundColor Red
    Write-Host "       Installez depuis: https://nodejs.org" -ForegroundColor Gray
}

# Verifier Java (pour Android)
Write-Host ""
Write-Host "[INFO] Verification de Java..." -ForegroundColor Yellow
Write-Host ""
$java = java -version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Java: Installe" -ForegroundColor Green
    Write-Host "       $($java[0])" -ForegroundColor Gray
} else {
    Write-Host "  [INFO] Java: Non trouve (optionnel)" -ForegroundColor Yellow
    Write-Host "       Necessaire pour Android. Installer si besoin" -ForegroundColor Gray
}

# Verifier git
Write-Host ""
Write-Host "[INFO] Verification de Git..." -ForegroundColor Yellow
Write-Host ""
$git = git --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Git: Installe" -ForegroundColor Green
    Write-Host "       $git" -ForegroundColor Gray
} else {
    Write-Host "  [MANQ] Git: Non installe" -ForegroundColor Red
}

# Verifier .env
Write-Host ""
Write-Host "[INFO] Verification de la configuration Supabase..." -ForegroundColor Yellow
Write-Host ""

if (Test-Path ".\.env") {
    $env_content = Get-Content ".\.env"
    $has_url = $env_content -match "SUPABASE_URL="
    $has_key = $env_content -match "SUPABASE_ANON_KEY="
    
    if ($has_url -and $has_key) {
        Write-Host "  [OK] .env: Configuration trouvee" -ForegroundColor Green
        Write-Host "       - SUPABASE_URL: Configuree" -ForegroundColor Green
        Write-Host "       - SUPABASE_ANON_KEY: Configuree" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] .env: Configuration incomplete" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [MANQ] .env: Fichier introuvable" -ForegroundColor Red
}

Write-Host ""

if (Test-Path ".\admin-web\.env") {
    $env_web = Get-Content ".\admin-web\.env"
    $has_url = $env_web -match "VITE_SUPABASE_URL="
    $has_key = $env_web -match "VITE_SUPABASE_ANON_KEY="
    
    if ($has_url -and $has_key) {
        Write-Host "  [OK] admin-web/.env: Configuration trouvee" -ForegroundColor Green
        Write-Host "       - VITE_SUPABASE_URL: Configuree" -ForegroundColor Green
        Write-Host "       - VITE_SUPABASE_ANON_KEY: Configuree" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] admin-web/.env: Configuration incomplete" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [MANQ] admin-web/.env: Fichier introuvable" -ForegroundColor Red
}

# Afficher les commandes rapides
Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   Commandes rapides" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[Compiler l'APK]" -ForegroundColor Green
Write-Host "   .\build_apk_release_v2.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "[Lancer la web admin]" -ForegroundColor Green
Write-Host "   cd admin-web && npm install && npm run dev" -ForegroundColor Gray
Write-Host ""

Write-Host "[Tester le mobile]" -ForegroundColor Green
Write-Host "   flutter run" -ForegroundColor Gray
Write-Host ""

Write-Host "[Documentation]" -ForegroundColor Green
Write-Host "   - INDEX.md (navigation)" -ForegroundColor Gray
Write-Host "   - BUILD_APK_QUICK_START.md (3 etapes)" -ForegroundColor Gray
Write-Host "   - VERIFICATION_CONFIG_SUPABASE.md (test synchro)" -ForegroundColor Gray
Write-Host ""

# Statut final
Write-Host "=================================================" -ForegroundColor Cyan
if ($missing -eq 0) {
    Write-Host "   TOUT EST PRET" -ForegroundColor Green
} else {
    Write-Host "   VERIFIEZ LES DETAILS" -ForegroundColor Yellow
}
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[INFO] Pour plus d'aide, lisez: INDEX.md" -ForegroundColor Yellow
Write-Host ""

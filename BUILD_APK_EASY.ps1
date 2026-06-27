# Script PowerShell pour compiler l'APK release facilement
# Double-cliquez sur ce fichier pour l'exécuter!

Write-Host "========================================" -ForegroundColor Green
Write-Host "📱 Compilation APK Release - ParkSmart" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Step 1: Clean
Write-Host "`n1️⃣  Nettoyage du projet..." -ForegroundColor Yellow
flutter clean

# Step 2: Pub get
Write-Host "`n2️⃣  Téléchargement des dépendances..." -ForegroundColor Yellow
flutter pub get

# Step 3: Build APK
Write-Host "`n3️⃣  Compilation de l'APK release..." -ForegroundColor Yellow
Write-Host "Cela peut prendre 2-5 minutes..." -ForegroundColor Gray

flutter build apk --release `
  --dart-define=SUPABASE_URL=https://knzoqcvlxmgsxgooizuk.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCÈS! APK compilée avec succès!" -ForegroundColor Green
    Write-Host "`n📍 Emplacement de l'APK:" -ForegroundColor Cyan
    Write-Host "   build\app\outputs\apk\release\app-release.apk" -ForegroundColor White
    Write-Host "`n💾 Taille:" -ForegroundColor Cyan
    $apkSize = (Get-Item "build\app\outputs\apk\release\app-release.apk" -ErrorAction SilentlyContinue).Length
    if ($apkSize) {
        Write-Host "   $([Math]::Round($apkSize/1MB, 2)) MB" -ForegroundColor White
    }
    Write-Host "`n🔌 Installer sur téléphone:" -ForegroundColor Cyan
    Write-Host "   adb install -r build\app\outputs\apk\release\app-release.apk" -ForegroundColor White
    Write-Host "`n✨ Compilation terminée!" -ForegroundColor Green
} else {
    Write-Host "`n❌ ERREUR pendant la compilation!" -ForegroundColor Red
    Write-Host "Vérifiez les erreurs ci-dessus." -ForegroundColor Red
}

Write-Host "`nAppuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

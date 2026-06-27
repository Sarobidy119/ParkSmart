@echo off
REM Script CMD pour compiler l'APK release
REM Double-cliquez sur ce fichier pour l'exécuter!

color 0A
echo.
echo ========================================
echo.  Compilation APK Release - ParkSmart
echo ========================================
echo.

REM Step 1: Clean
echo [1/3] Nettoyage du projet...
call flutter clean

REM Step 2: Pub get
echo.
echo [2/3] Telechargement des dependances...
call flutter pub get

REM Step 3: Build
echo.
echo [3/3] Compilation de l'APK release...
echo Cela peut prendre 2-5 minutes...
echo.

call flutter build apk --release --dart-define=SUPABASE_URL=https://knzoqcvlxmgsxgooizuk.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo.  ^[CHECK MARK] SUCCES! APK compilee!
    echo ========================================
    echo.
    echo Emplacement: build\app\outputs\apk\release\app-release.apk
    echo.
    echo Installer sur telephone:
    echo   adb install -r build\app\outputs\apk\release\app-release.apk
    echo.
) else (
    echo.
    echo ========================================
    echo.  ERREUR pendant la compilation!
    echo ========================================
    echo Verifiez les erreurs ci-dessus.
    echo.
)

pause

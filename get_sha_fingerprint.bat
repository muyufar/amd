@echo off
echo Getting SHA-1 and SHA-256 fingerprints for Google Sign-In configuration...
echo.

echo Debug keystore SHA-1:
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | findstr "SHA1"

echo.
echo Debug keystore SHA-256:
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | findstr "SHA256"

echo.
echo Package name: com.andi.digital.andi_digital
echo.
echo Instructions:
echo 1. Copy the SHA-1 and SHA-256 values above
echo 2. Go to Google Cloud Console ^> Credentials ^> OAuth 2.0 Client IDs
echo 3. Find your Android client or create one
echo 4. Add the package name: com.andi.digital.andi_digital
echo 5. Add both SHA-1 and SHA-256 fingerprints
echo 6. Make sure you're using the Web Client ID in AppConfig.googleWebClientId
echo.
pause

# GitHub Actions iOS Build Setup

This repository includes a GitHub Actions workflow for building and testing the Flutter app on iOS using macOS runners.

## What the workflow does:

1. **Builds the iOS app** using Flutter on macOS runners with Xcode pre-installed
2. **Runs the app on iOS Simulator** automatically
3. **Takes screenshots** of the running app
4. **Uploads build artifacts** for download

## How to use:

1. **Push your code** to the `main` or `develop` branch, or create a pull request
2. **Go to the Actions tab** in your GitHub repository
3. **Watch the build progress** in real-time
4. **Download artifacts** including:
   - iOS build files
   - Screenshots from the simulator

## Manual trigger:

You can also manually trigger the workflow:
1. Go to **Actions** tab in GitHub
2. Select **iOS Build and Deploy** workflow
3. Click **Run workflow** button
4. Choose the branch and click **Run workflow**

## Requirements:

- GitHub repository (free tier includes macOS runner minutes)
- No Xcode installation needed on your local machine
- No Apple Developer account needed for simulator testing

## Optional TestFlight deployment:

The workflow includes a disabled TestFlight deployment job. To enable it:
1. Set up Apple Developer account
2. Add required secrets to GitHub repository
3. Change `if: github.ref == 'refs/heads/main' && false` to `if: github.ref == 'refs/heads/main' && true`

## Secrets needed for TestFlight (optional):
- `IOS_P12_BASE64`: Base64 encoded .p12 certificate
- `IOS_P12_PASSWORD`: Password for .p12 certificate  
- `APPSTORE_ISSUER_ID`: App Store Connect API issuer ID
- `APPSTORE_KEY_ID`: App Store Connect API key ID
- `APPSTORE_PRIVATE_KEY`: App Store Connect API private key

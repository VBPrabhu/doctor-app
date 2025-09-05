# Install Doctor App on Your Apple Device

## 🚀 Quick Start Options

### Option 1: Direct IPA Installation (Easiest)
1. **Download IPA** from GitHub Actions artifacts
2. **Upload to Diawi.com** (free service for iOS app distribution)
3. **Scan QR code** on your iPhone/iPad to install

### Option 2: TestFlight (Professional)
- Requires Apple Developer account ($99/year)
- Automatic updates and crash reporting
- Best for ongoing development

### Option 3: Xcode Installation
- Requires Mac with Xcode installed
- Connect device via USB
- Install through Xcode → Devices & Simulators

## 📋 Step-by-Step Instructions

### Using Diawi.com (Recommended for Testing)

1. **Get the IPA file:**
   - Go to: https://github.com/VBPrabhu/doctor-app/actions
   - Click on latest "iOS Device Deployment" workflow
   - Download the `ios-app-xxx` artifact
   - Extract the `doctorapp.ipa` file

2. **Upload to Diawi:**
   - Visit: https://www.diawi.com
   - Drag & drop your `doctorapp.ipa` file
   - Wait for upload to complete
   - Copy the installation link

3. **Install on your device:**
   - Open the Diawi link on your iPhone/iPad
   - Tap "Install" when prompted
   - Go to Settings → General → VPN & Device Management
   - Trust the developer certificate
   - Launch the app from home screen

### Using TestFlight (For Production)

1. **Setup required (one-time):**
   - Apple Developer account ($99/year)
   - Add device UDID to developer portal
   - Configure GitHub secrets (certificates & keys)

2. **Automatic deployment:**
   - Push code to `main` branch
   - GitHub Actions builds and uploads to TestFlight
   - Receive TestFlight invitation email
   - Install TestFlight app and accept invitation

## ⚙️ Current Workflow Status

✅ **GitHub Actions configured** - Builds IPA automatically
✅ **iOS Simulator testing** - Works in cloud environment  
⚠️ **Device installation** - Requires manual IPA download/upload
⚠️ **TestFlight** - Needs Apple Developer account setup

## 🔧 Next Steps

1. **Run the workflow** by pushing code or manual trigger
2. **Download IPA** from Actions artifacts
3. **Use Diawi.com** for easy device installation
4. **Optional:** Set up Apple Developer account for TestFlight

## 📱 Device Requirements

- iOS 12.0 or later
- iPhone, iPad, or iPod touch
- Device must trust developer certificate after installation

# iOS Setup Guide for MySched

This document covers iOS-specific setup required for advanced notification features.

## Required Setup (Must Do Before Building)

### 1. Bundle Identifier ✅ (Already Done)
Bundle ID changed to: `com.ici.mysched`

### 2. Google Sign-In Configuration

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create new **OAuth 2.0 Client ID** with type **iOS**
3. Enter Bundle ID: `com.ici.mysched`
4. Download `GoogleService-Info.plist`
5. Add to `ios/Runner/` directory
6. Add URL scheme to `Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR-IOS-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```

### 3. Apple Sign-In ✅ (Code Ready)

Apple Sign-In is **required by Apple** when you offer Google Sign-In. The code is already implemented!

**Automatic Setup:**
- Button only shows on iOS devices
- Uses Supabase Apple OAuth provider
- Profile completion flow works the same as Google

**Enable in App Store Connect:**
1. Go to [Apple Developer Portal](https://developer.apple.com/account) → Certificates, Identifiers & Profiles
2. Select your App ID (`com.ici.mysched`)
3. Enable **Sign In with Apple** capability
4. In Xcode (or Codemagic), ensure the entitlement is added

**Supabase Configuration:**
1. Go to Supabase Dashboard → Authentication → Providers
2. Enable **Apple** provider
3. Add your Apple Service ID and Secret Key
4. Follow [Supabase Apple Auth Guide](https://supabase.com/docs/guides/auth/social-login/auth-apple)

---

## Optional Advanced Features

### 3. Custom Notification Sound

The app is configured to use `class_alarm.caf` as the notification sound.

**To add a custom sound:**
1. Convert your audio file to CAF format (max 30 seconds):
   ```bash
   afconvert -f caff -d LEI16@44100 input.mp3 class_alarm.caf
   ```
2. Add `class_alarm.caf` to `ios/Runner/` directory
3. In Xcode, add the file to the Runner target's "Copy Bundle Resources"

If the file doesn't exist, iOS will use the default notification sound.

---

### 4. Critical Alerts (Requires Apple Approval)

Critical Alerts bypass Do Not Disturb and silent mode - perfect for class reminders.

**Steps to enable:**

1. **Request Entitlement from Apple:**
   - Go to [Apple Developer Portal](https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/)
   - Submit request explaining:
     - App is for student class scheduling
     - Critical alerts ensure students don't miss important classes
     - Educational/academic use case

2. **After Approval - Add Entitlement:**
   Create `ios/Runner/Runner.entitlements`:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>com.apple.developer.usernotifications.critical-alerts</key>
       <true/>
   </dict>
   </plist>
   ```

3. **Enable in App:**
   In `main.dart` or app initialization:
   ```dart
   LocalNotifs.enableCriticalAlerts();
   ```

---

### 5. Live Activities (iOS 16.1+)

Live Activities show a persistent countdown widget on the lock screen.

**Current Status:** Dart API is ready (`lib/services/live_activities_service.dart`).

**To Complete Setup (Requires Xcode on Mac):**

1. **Create Widget Extension:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - File → New → Target → Widget Extension
   - Name it `MySchedWidget`
   - Check "Include Live Activity"

2. **Create Live Activity Attributes:**
   Create `ClassActivityAttributes.swift`:
   ```swift
   import ActivityKit
   import WidgetKit
   import SwiftUI
   
   struct ClassActivityAttributes: ActivityAttributes {
       public struct ContentState: Codable, Hashable {
           var subject: String
           var room: String
           var startTime: Date
           var status: String?
       }
       
       var classId: Int
   }
   ```

3. **Create Live Activity Widget:**
   ```swift
   struct ClassActivityWidget: Widget {
       var body: some WidgetConfiguration {
           ActivityConfiguration(for: ClassActivityAttributes.self) { context in
               // Lock screen view
               HStack {
                   VStack(alignment: .leading) {
                       Text(context.state.subject)
                           .font(.headline)
                       Text(context.state.room)
                           .font(.subheadline)
                   }
                   Spacer()
                   Text(context.state.startTime, style: .relative)
                       .font(.title2)
               }
               .padding()
           } dynamicIsland: { context in
               DynamicIsland {
                   DynamicIslandExpandedRegion(.leading) {
                       Text(context.state.subject)
                   }
                   DynamicIslandExpandedRegion(.trailing) {
                       Text(context.state.startTime, style: .relative)
                   }
               } compactLeading: {
                   Image(systemName: "book.fill")
               } compactTrailing: {
                   Text(context.state.startTime, style: .timer)
               } minimal: {
                   Image(systemName: "book.fill")
               }
           }
       }
   }
   ```

4. **Add Flutter Platform Channel Handler:**
   Add to `ios/Runner/AppDelegate.swift`:
   ```swift
   import ActivityKit
   
   // In application(_:didFinishLaunchingWithOptions:)
   let controller = window?.rootViewController as! FlutterViewController
   let channel = FlutterMethodChannel(name: "mysched/live_activities",
                                     binaryMessenger: controller.binaryMessenger)
   
   channel.setMethodCallHandler { call, result in
       switch call.method {
       case "startClassActivity":
           // Start Live Activity
           // ...
       case "updateClassActivity":
           // Update Live Activity
           // ...
       case "endClassActivity":
           // End Live Activity
           // ...
       default:
           result(FlutterMethodNotImplemented)
       }
   }
   ```

---

## Testing Without a Mac

Since you don't have a Mac, here's what works out of the box:

| Feature | Works on Codemagic Build? |
|---------|---------------------------|
| Basic notifications | ✅ Yes |
| Time-sensitive interruption | ✅ Yes |
| Custom sound (if file exists) | ✅ Yes |
| Snooze action buttons | ✅ Yes |
| Critical Alerts | ⚠️ Needs Apple approval first |
| Live Activities | ❌ Needs Xcode widget extension |

The app will gracefully degrade - if Live Activities aren't available, users just get regular notifications.

---

## Codemagic Build Notes

When building with Codemagic, these features are automatically available:
- All notification features (except Critical Alerts without entitlement)
- Code signing handled by Codemagic
- TestFlight upload

The Live Activities widget extension must be added via Xcode on a Mac first, then committed to the repo for Codemagic to build.

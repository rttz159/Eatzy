# BAIT2073 Mobile Application Development Assignment

A Flutter project for Mobile Application Development assignment.

### Instructions for Building the Flutter Android App

These instructions will guide you to manually build the app in either **debug** or **release** mode.

---

#### Prerequisites:

1. **Ensure Required Tools Are Installed:**

   - **Java 17:**

     - Verify installation:
       ```bash
       java -version
       ```
       Output should include:
       ```bash
       java version "17.0.x"
       ```

   - **Gradle 8.0:**

     - Verify installation:
       ```bash
       gradle -v
       ```
       Output should include:
       ```bash
       Gradle 8.0
       ```

   - **Flutter:**
     - Verify installation:
       ```bash
       flutter doctor
       ```
       Ensure there are no errors.

2. **Configure Android SDK and NDK Paths:**
   - Confirm that the `local.properties` file in the `android` directory includes the correct SDK and NDK paths.
   - Example `local.properties` file:
     ```
     sdk.dir=/path/to/Android/sdk
     ndk.dir=/path/to/Android/ndk
     ```
   - On Windows, use double backslashes (`\\`) in paths:
     ```
     sdk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\sdk
     ndk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\ndk
     ```

---

#### Steps to Build the App:

1. **Open a Terminal or Command Prompt:**

   - Navigate to the root directory of the Flutter project:
     ```bash
     cd /path/to/your/flutter_project
     ```

2. **Fetch Project Dependencies:**

   - Run the following command to fetch all required dependencies:
     ```bash
     flutter pub get
     ```

3. **Building the App:**

   - **For Debug Build:**

     - Build the app in debug mode:
       ```bash
       flutter build apk --debug
       ```
     - The debug APK will be generated at:
       ```
       build/app/outputs/flutter-apk/app-debug.apk
       ```

   - **For Release Build:**
     - Build the app in release mode:
       ```bash
       flutter build apk --release
       ```
     - The release APK will be generated at:
       ```
       build/app/outputs/flutter-apk/app-release.apk
       ```

4. **Install the APK on Your Device:**
   - Connect your Android device via USB or use an emulator.
   - Use the following command to install the APK:
     ```bash
     flutter install
     ```
   - Alternatively, transfer the APK to your device and install it manually.

---

#### Notes:

- **For Debug Builds:** No signing configuration is required; the app uses the default debug keys.
- **For Release Builds:** Ensure the project has a signing configuration in `android/app/build.gradle` to create a signed APK for production.

---

#### Troubleshooting:

1. **Gradle Sync Issues:**

   - If you encounter Gradle errors, clear the project build cache:
     ```bash
     flutter clean
     flutter pub get
     flutter build apk
     ```

2. **Java Version Conflicts:**

   - If the build fails due to an incorrect Java version, ensure Java 17 is active:
     ```bash
     export JAVA_HOME=/path/to/java17
     ```

3. **SDK/NDK Path Errors:**
   - If the SDK or NDK path is incorrect, update `local.properties` with the correct paths.

---

#### Tested Devices:

The app has been tested on the following devices:

- **Pixel 9** with **Android API 31**.
- **Pixel XL** with **Android API 28**.

These devices were used to ensure compatibility and proper functionality of the application across different Android versions.

---

By following these steps, you can successfully build the Flutter app in either debug or release mode using Java 17 and Gradle 8.0.


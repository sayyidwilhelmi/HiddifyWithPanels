
# What is V2Hiddify ([查看此文档的中文版本](./README.md))

V2Hiddify is a derivative project developed based on [Hiddify-Next](https://github.com/hiddify/hiddify-next). The purpose of this project is to develop a cross-platform client that can integrate directly with V2board (Xboard). Users can log in with their accounts from the VPN service provider, automatically subscribe, and purchase packages.

## Project Progress Update

The project is currently on hold for two days as the payment feature is the only part left incomplete. However, there is no clear solution for integrating different payment platforms at the moment since each platform's integration method varies. If you have good suggestions, feel free to leave a comment in the issue section or submit a PR. You can also join the group chat.

## Join TG Group Chat

Feel free to join the V2Hiddify TG group for discussions and exchanges: [V2Hiddify TG Group](https://t.me/V2Hiidify).

## Features

- [x] **Login with panel account**: Allows users to log in with their panel accounts.
- [x] **Registration**: Provides a user registration feature.
- [x] **Forgot password**: Password recovery function.
- [x] **Automatic subscription**: Automatically adds subscriptions after purchasing a package.
- [x] **Display package information**: Shows the user's current package information.
- [ ] **Payment integration**: Provide integration with payment platforms.
- [ ] **Package purchase**: Allows users to purchase different packages.
- [x] **Auto-subscribe after purchase**: Automatically adds subscriptions after purchasing a package.
- [x] **Logout**: Allows users to log out.
- [x] **Localization support**: Supports both Chinese and English localization.
- [x] **Invite code**: Supports generating and copying invite codes.
- [x] **Wallet**: Supports wallet functionality, transfers, and withdrawals.
- [x] **Reset subscription link**: Supports resetting the subscription link and automatically subscribing to v2hiddify.

## Installation Steps

### 1. Clone the repository

First, clone the repository locally:

```bash
git clone https://github.com/GalenBlabla/Hiddify-with-V2board.git
cd Hiddify-with-V2board
```

### 2. Prepare dependencies

Execute the following commands based on your operating system to prepare the environment:

- **Windows**:

  ```bash
  make windows-prepare
  ```

- **Linux**:

  ```bash
  make linux-prepare
  ```

- **macOS**:

  ```bash
  make macos-prepare
  ```

- **iOS**:

  ```bash
  make ios-prepare
  ```

- **Android**:

  ```bash
  make android-prepare
  ```

### 3. Run the project

After preparing the dependencies, you can run the project with Flutter:

```bash
flutter run
```

### 4. Replace panel domain and panel name

Perform the following replacements in the project directory:

1. **Replace the panel domain**:

   Open `lib/features/panel/v2board/service/auth_service.dart` and replace `_baseUrl` with your target panel address.

2. **Replace panel name**:

   Inside the app, find the language package `assets/translations/strings_zh-CN.i18n.json` and modify the third line `"appTitle": "V2Hiddify"`. This will change the program's internal name and the welcome page name.  
   To change the app's name outside the app (e.g., on the home screen), modify the platform-specific files, such as in the Android example:  
    #### Modify `AndroidManifest.xml`

    In the `android/app/src/main/AndroidManifest.xml` file, locate the `<application>` tag and modify the `android:label` attribute:

    ```xml
    <application
        android:name=".Application"
        android:banner="@mipmap/ic_banner"
        android:icon="@mipmap/ic_launcher"
        android:label="V2Hiddify"
    ```

### 5. Build the application

Package the application for the respective platform as needed. Before packaging, go to the `android` directory, find the `gradle.properties` file, and modify the proxy IP and port to your own. If no proxy is needed, remove the first 5 lines starting with `systemProp`:

  ```properties
  org.gradle.jvmargs=-Xmx4048m -Dfile.encoding=UTF-8
  android.useAndroidX=true
  android.enableJetifier=true

  # HTTP proxy settings
  systemProp.http.proxyHost=192.168.28.36
  systemProp.http.proxyPort=7890

  # HTTPS proxy settings
  systemProp.https.proxyHost=192.168.28.36
  systemProp.https.proxyPort=7890

  # Hosts that don't use proxy (optional)
  systemProp.http.nonProxyHosts=localhost|127.0.0.1
  ```

- Android build:

  ```bash
  flutter build apk
  ```

- iOS build:

  ```bash
  flutter build ios
  ```

- macOS build:

  ```bash
  flutter build macos
  ```

- Windows build:

  ```bash
  flutter build windows
  ```

---

With these steps, you can customize and package the V2Hiddify client for your own panel, making it easier for users to use VPN services.

## V2Hiddify Example Images

### Chinese Interface
<p align="center">
  <img src="./images/login_zh.jpg" alt="Login Example ZH" width="200"/>
  <img src="./images/home_zh.jpg" alt="Home Example ZH" width="200"/>
  <img src="./images/plan_zh.jpg" alt="Plan Example ZH" width="200"/>
  <img src="./images/connect_zh.jpg" alt="Connect Example ZH" width="200"/>
</p>

### English Interface
<p align="center">
  <img src="./images/login_en.jpg" alt="Login Example EN" width="200"/>
  <img src="./images/home_en.jpg" alt="Home Example EN" width="200"/>
  <img src="./images/plan_en.jpg" alt="Plan Example EN" width="200"/>
  <img src="./images/connect_en.jpg" alt="Connect Example EN" width="200"/>
</p>

---

## Build Platform Requirement Overview

V2Hiddify currently has an issue: clients need to be packaged separately for different domains. To simplify this process, I plan to develop an automatic packaging platform. Users will input the target panel domain (e.g., `https://tomato.galen.life`) and the panel name (e.g., "V2Hiddify"), and the platform will automatically generate configuration files and complete the packaging.

### Implementation Idea

1. **Frontend user input**: The user inputs the domain and panel name on the platform.
2. **Generate configuration files**: The backend generates corresponding configuration files based on user input (e.g., `config.toml`).
3. **Trigger packaging script**: The backend calls the packaging script (e.g., `build.sh`) to package according to the configuration file.
4. **Download link**: After packaging is complete, a download link is generated for the user.

---

## Support this project

Developing as an individual can be challenging. If you find this project helpful, feel free to support it.

**Wallet address (USDT-TRC20):**
```
TQuqe1P5G1EDQJmfqqJ6mjPNYBXW5ceKoH
```

<img src="images/usdt_trc20.png" alt="USDT TRC20 QR code" width="500"/>

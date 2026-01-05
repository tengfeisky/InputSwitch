# InputSwitch

InputSwitch is a macOS utility designed to automatically switch input sources based on the active application. It helps you maintain your preferred input method for different apps, enhancing your productivity and typing experience.

## Features

- **Auto-Switch Input Source**: Automatically switches to a configured input source when you switch to a specific application.
- **Menu Bar Integration**: Easily access settings and manage configurations directly from the macOS menu bar.
- **Configurable Rules**: Define custom input source rules for any application installed on your system.
- **Lightweight & Fast**: Built with Swift and optimized for performance.

## Requirements

- macOS 14.0 or later

## Installation

### Download Release

Download the latest `InputSwitch.zip` from [Releases](https://github.com/tengfeisky/InputSwitch/releases), unzip and move `InputSwitch.app` to your Applications folder.

> **⚠️ Security Notice**
>
> Since this app is not signed with an Apple Developer certificate, macOS may block it from opening. To resolve this:
>
> **Option 1: Right-click to open**
> 1. In Finder, right-click (or Control-click) on `InputSwitch.app`
> 2. Select **"Open"** from the menu
> 3. Click **"Open"** in the dialog that appears
>
> **Option 2: Remove quarantine via Terminal**
> ```bash
> xattr -cr /Applications/InputSwitch.app
> ```
>
> **Option 3: System Settings**
> 1. Try to open the app (you'll see a security warning)
> 2. Go to **System Settings → Privacy & Security**
> 3. Scroll down and click **"Open Anyway"**

### Build from Source

1.  Clone the repository:
    ```bash
    git clone https://github.com/tengfeisky/InputSwitch.git
    cd InputSwitch
    ```

2.  Build the project:
    ```bash
    swift build -c release
    ```

3.  Run the application:
    ```bash
    .build/release/InputSwitch
    ```

Alternatively, you can open the project in Xcode and build/run it from there.

## Usage

1.  Launch **InputSwitch**.
2.  Click the keyboard icon in the menu bar.
3.  Use the interface to assign specific input sources to your applications.
4.  The app will now automatically switch input sources as you navigate between apps.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

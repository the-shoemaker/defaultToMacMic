# defaultToMacMic
Fixes the macOS behaviour of automatically switching the input from your internal laptop mic to the broken AirPods ones.

## Why and How
The AirPods mics are very low quality and generally really buggy, that's why I wanted to set the default mic on my Mac to the internal one. But I had to find out that currently there is no option to do this in macOS. So this is a fix for that: just download the Swift project, change the name of the device to the one of your AirPods (I have a terminal command to find that out under setup), compile the script, make a .plist file to automatically run it, and add it to the macOS LaunchAgents.

## Needed Tools
- Xcode: for compiling
- blueutil: to check the name of your device

## Setup

### Install and run
- Install Xcode from the Mac App Store
- Install blueutil
  ```
  brew install blueutil
  ```
  ```
  blueutil --paired
  ```
  - Find the paired device and get its name.

### Download and modify
- Download the Swift project and modify the name of the device with the one you just found: `let airPodsName = "Your Device Name"` (line: 109)
  - Then run this to compile the script:
    ```
    cd "/Your/Script/Path"
    swiftc -framework CoreAudio -framework IOBluetooth main.swift -o defaultToMacMic
    ```
- Download: `com.YOURNAME.defaultToMacMic`
  - Change path under `<string>/Your/Compiled/Script/Path</string>` (line: 11)
  - Save in folder: `~/Library/LaunchAgents/`
  - Launch:
    ```
    launchctl load ~/Library/LaunchAgents/com.YOURNAME.defaultToMacMic.plist
    ```
  To unload, use:
    ```
    launchctl unload ~/Library/LaunchAgents/com.YOURNAME.defaultToMacMic.plist
    ```

## You're done!
This should now automatically change the input device back to your Mac’s mic, max 30 sec after connecting your AirPods.

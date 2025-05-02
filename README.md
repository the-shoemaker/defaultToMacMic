# defaultToMacMic
Fixes the macOS behaviour of automatically switching the input from your internal laptop mic to the broken AirPods ones.


## Why and How
The AirPods mics are very low quality and generally really buggy, that's why I wanted to set the default mic on my Mac to the internal one. But I had to find out that currently there is no option to do this in macOS. So this is a fix for that: just download the Swift project, change the name of the device to the one of your AirPods (I have a terminal command to find that out under setup), compile the script, make a .plist file to automatically run it, and add it to the macOS LaunchAgents.

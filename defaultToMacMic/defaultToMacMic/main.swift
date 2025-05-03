import Foundation
import CoreAudio
import IOBluetooth

// MARK: - Audio Input Management

func getAllInputDevices() -> [AudioDeviceID] {
    var size: UInt32 = 0
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size)

    let deviceCount = Int(size) / MemoryLayout<AudioDeviceID>.size
    var devices = [AudioDeviceID](repeating: 0, count: deviceCount)

    AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &devices)

    return devices
}

func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
    var name: CFString? = nil
    var size = UInt32(MemoryLayout<CFString?>.size)
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioObjectPropertyName,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    let status = withUnsafeMutablePointer(to: &name) {
        AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, $0)
    }

    if status == noErr, let name = name {
        return name as String
    }

    return nil
}

func isInputDevice(_ deviceID: AudioDeviceID) -> Bool {
    var channels: UInt32 = 0
    var size = UInt32(MemoryLayout<UInt32>.size)
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyStreamConfiguration,
        mScope: kAudioDevicePropertyScopeInput,
        mElement: kAudioObjectPropertyElementMain
    )

    let status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &size)
    if status != noErr { return false }

    let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(size))
    defer { bufferList.deallocate() }

    AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, bufferList)

    for _ in 0..<Int(bufferList.pointee.mNumberBuffers) {
        channels += bufferList.pointee.mBuffers.mNumberChannels
    }

    return channels > 0
}

func setDefaultInputDevice(_ deviceID: AudioDeviceID) {
    var deviceID = deviceID
    let size = UInt32(MemoryLayout<AudioDeviceID>.size)
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    let status = AudioObjectSetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &address,
        0,
        nil,
        size,
        &deviceID
    )

    if status == noErr {
        print("✅ Internal mic set as default input.")
    } else {
        print("❌ Failed to set input device.")
    }
}

// MARK: - Bluetooth Detection

func airPodsAreConnected(named targetName: String) -> Bool {
    guard let devices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] else { return false }

    for device in devices {
        if let name = device.name, name.contains(targetName), device.isConnected() {
            return true
        }
    }
    return false
}

// MARK: - Main Execution

let airPodsName = "AirPods Pro" // 🔁 Change this to your AirPods name exactly as shown in blueutil

if airPodsAreConnected(named: airPodsName) {
    let allDevices = getAllInputDevices()
    for device in allDevices {
        if isInputDevice(device), let name = getDeviceName(device) {
            if name.contains("MacBook") || name.contains("Built-in") {
                setDefaultInputDevice(device)
                exit(0)
            }
        }
    }
    print("⚠️ No internal mic found.")
} else {
    // Silent exit if AirPods not connected
    exit(0)
}

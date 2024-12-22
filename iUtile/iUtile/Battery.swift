//
//  Battery.swift
//  iUtile
//
//  Created by Bogdan Garmash on 03.12.2024.
//
import Foundation
import IOKit
import IOKit.ps
import Darwin


public func getBatteryStatus() {
    let greenText = "\u{001B}[0;32m" // Зеленый цвет
    let redText = "\u{001B}[0;31m" // Красный цвет
    let resetText = "\u{001B}[0m"  // Сброс цвета

    guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
          let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
        print("\(redText)Error: Unable to fetch battery information\(resetText)")
        return
    }
    
    for source in sources {
        if let info = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] {
            if let name = info[kIOPSNameKey as String] as? String,
               let currentCapacity = info[kIOPSCurrentCapacityKey as String] as? Int,
               let maxCapacity = info[kIOPSMaxCapacityKey as String] as? Int,
               let isCharging = info[kIOPSIsChargingKey as String] as? Bool {
                
                let chargePercentage = Int((Double(currentCapacity) / Double(maxCapacity)) * 100)
                let chargingStatus = isCharging ? "Charging" : "Not Charging"
                
                print("\(greenText)Battery Status:\(resetText)")
                print("Name: \(name)")
                print("Charge: \(chargePercentage)%")
                print("Status: \(chargingStatus)")
                
                if let timeRemaining = info[kIOPSTimeToEmptyKey as String] as? Int, timeRemaining != -1 {
                    print("Time Remaining: \(timeRemaining / 60) hours \(timeRemaining % 60) minutes")
                } else if let timeToFull = info[kIOPSTimeToFullChargeKey as String] as? Int, timeToFull != -1 {
                    print("Time to Full Charge: \(timeToFull / 60) hours \(timeToFull % 60) minutes")
                } else {
                    print("Time Remaining: Calculating...")
                }
                return
            }
        }
    }
    
    print("\(redText)No battery information available\(resetText)")
}

func enablePowerSavingMode() {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["sudo", "pmset", "lowpowermode", "1"]

    do {
        try process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            print("powersafe enable")
        } else {
            print("error")
        }
    } catch {
        print("error: \(error.localizedDescription)")
    }
}

func disablePowerSavingMode() {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["sudo", "pmset", "lowpowermode", "0"]

    do {
        try process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            print("powersafe diseble")
        } else {
            print("error.")
        }
    } catch {
        print("error: \(error.localizedDescription)")
    }
}


func readBatteryInfoManually() {
    
    let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
    
    if service == 0 {
        print("can not find service AppleSmartBattery")
        return
    }
    
   
    var properties: Unmanaged<CFMutableDictionary>?
    let result = IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0)
    
    if result == KERN_SUCCESS, let props = properties?.takeRetainedValue() as? [String: Any] {
        
        if let currentCapacity = props["CurrentCapacity"] as? Int,
           let maxCapacity = props["MaxCapacity"] as? Int,
           let isCharging = props["IsCharging"] as? Bool {
            
            let chargePercentage = (Double(currentCapacity) / Double(maxCapacity)) * 100
            print("Capacity: \(currentCapacity) mAh")
            print("Max cap: \(maxCapacity) mAh")
            print("Charge: \(chargePercentage)%")
            print("status: \(isCharging ? "charging" : "not charging")")
        } else {
            print("can not get battery properties")
        }
    } else {
        print("Error")
    }
    
    IOObjectRelease(service) 
}


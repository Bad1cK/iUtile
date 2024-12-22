
import Foundation
import IOKit
import IOKit.ps

let greenText = "\u{001B}[0;32m"
let redText = "\u{001B}[0;31m"
let resetText = "\u{001B}[0m"

let HOST_CPU_LOAD_INFO = host_flavor_t(3)
let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size

func getCPUUsageU() {
    var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
    var cpuLoad = host_cpu_load_info_data_t()

    let result = withUnsafeMutablePointer(to: &cpuLoad) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
        }
    }

    if result == KERN_SUCCESS {
        let user = Double(cpuLoad.cpu_ticks.0)
        let system = Double(cpuLoad.cpu_ticks.1)
        let idle = Double(cpuLoad.cpu_ticks.2)
        let total = user + system + idle

        let userUsage = round((user / total) * 100 * 100) / 100
        let systemUsage = round((system / total) * 100 * 100) / 100
        let idleUsage = round((idle / total) * 100 * 100) / 100


        print("\(greenText)CPU Usage: \n ---User: \(userUsage)\n ---System: \(systemUsage)\n ---Idle: \(idleUsage)%\(resetText)")
    } else {
        print("\(redText)Error: Unable to fetch CPU usage\(resetText)")
    }
}

func getMemoryUsage() {
    var vmStats = vm_statistics64()
    var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

    let result = withUnsafeMutablePointer(to: &vmStats) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
        }
    }

    if result == KERN_SUCCESS {
        let pageSize = vm_kernel_page_size
        let freeMemory = round(Double(vmStats.free_count) * Double(pageSize) / 1_048_576 * 100) / 100
        let activeMemory = round(Double(vmStats.active_count) * Double(pageSize) / 1_048_576 * 100) / 100
        let inactiveMemory = round(Double(vmStats.inactive_count) * Double(pageSize) / 1_048_576 * 100) / 100
        let wiredMemory = round(Double(vmStats.wire_count) * Double(pageSize) / 1_048_576 * 100) / 100
        let totalMemory = round((freeMemory + activeMemory + inactiveMemory + wiredMemory) * 100) / 100


        print("\(greenText)Memory Usage:\n Total: \(totalMemory) \n --MB Free: \(freeMemory) \n --MB Active: \(activeMemory) \n --MB Inactive: \(inactiveMemory) \n --MB Wired: \(wiredMemory)\(resetText)")
    } else {
        print("\(redText)Error: Unable to fetch memory usage\(resetText)")
    }
}

let arguments = CommandLine.arguments

if arguments.count > 1 {
    switch arguments[1] {
    case "cpu-usage":
        getCPUUsageU()
    case "memory-usage":
        getMemoryUsage()
    case "battery-status":
            getBatteryStatus()
    case "enable-powersave":
        enablePowerSavingMode()
    case "disable-powersave":
        disablePowerSavingMode()
    case "battery-plus":
        readBatteryInfoManually()
    case "list-process":
        getTopCPUProcessesWithImpact()
   
    default:
        print("-- ERORR: Unknown command")
    }
} else {
    print("Usage: ./iUtile <command>")
    print("Available commands: cpu-usage, memory-usage")
}

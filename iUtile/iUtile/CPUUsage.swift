//
//  CPUUsage.swift
//  iUtile
//
//  Created by Oleh Bielous on 26/11/2024.
//

import Foundation
import IOKit
import IOKit.ps

let HOST_CPU_LOAD_INFO = host_flavor_t(3)
let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size

func getCPUUsage() {
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

        print("CPU Usage: User: \(userUsage)% System: \(systemUsage)% Idle: \(idleUsage)%")
    } else {
        print("Error: Unable to fetch CPU usage")
    }
}

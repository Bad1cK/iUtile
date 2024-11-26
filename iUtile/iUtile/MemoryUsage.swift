//
//  MemoryUsage.swift
//  iUtile
//
//  Created by Oleh Bielous on 26/11/2024.
//

import Foundation
import IOKit
import IOKit.ps

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

        print(String(format: "Memory Usage: Total: %.2f MB Free: %.2f MB Active: %.2f MB Inactive: %.2f MB Wired: %.2f MB", totalMemory, freeMemory, activeMemory, inactiveMemory, wiredMemory))
    } else {
        print("Error: Unable to fetch memory usage")
    }
}

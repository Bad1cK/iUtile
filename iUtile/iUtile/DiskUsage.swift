//
//  DiskUsage.swift
//  iUtile
//
//  Created by Oleh Bielous on 26/11/2024.
//

import Foundation

func getDiskUsage(for path: String) {
    let fileManager = FileManager.default
    let url = URL(fileURLWithPath: path)
    
    guard fileManager.fileExists(atPath: path) else {
        print("Error: Path '\(path)' does not exist.")
        return
    }

    do {
        let resourceValues = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
        
        if let available = resourceValues.volumeAvailableCapacityForImportantUsage,
           let total = resourceValues.volumeTotalCapacity {
            let used = Double(total) - Double(available)
            let usedMB = round(Double(used) / 1_048_576 * 100) / 100
            let availableMB = round(Double(available) / 1_048_576 * 100) / 100
            let totalMB = round(Double(total) / 1_048_576 * 100) / 100

            print(String(format: "Disk Usage for path '%@':\n- Total: %.2f MB\n- Used: %.2f MB\n- Available: %.2f MB", path, totalMB, usedMB, availableMB))
        } else {
            print("Unable to retrieve disk usage for path: \(path)")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

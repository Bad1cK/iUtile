//
//  ProcessMonitoring.swift
//  iUtile
//
//  Created by Bogdan Garmash on 11.12.2024.
//
import Foundation
import IOKit
import IOKit.ps
import Darwin




func getTopCPUProcessesWithImpact() {

    let coreCount = ProcessInfo.processInfo.processorCount

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    process.arguments = ["-c", "ps axo pid,pcpu,comm | sort -k 2 -nr | head -n 10"]

    let pipe = Pipe()
    process.standardOutput = pipe

    do {
        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print("Top 10 apps for CPU:")
            print("CPU Cores: \(coreCount)")
            print(output)

           
            let lines = output.split(separator: "\n")
            for line in lines {
                let components = line.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                if components.count == 3,
                   let cpuUsage = Double(components[1]) {
                    let impact = cpuUsage / Double(coreCount)
                    print("PID: \(components[0]), CPU: \(cpuUsage)%, Command: \(components[2])")
                    print("CPU usage: ~\(impact * 10)% core usage\n")
                }
            }
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}


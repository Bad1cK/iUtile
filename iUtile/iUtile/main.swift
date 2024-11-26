import Foundation

let arguments = CommandLine.arguments

if arguments.count > 1 {
    switch arguments[1] {
    case "cpu-usage":
        getCPUUsage()
    case "memory-usage":
        getMemoryUsage()
    case "disk-usage":
        if arguments.count > 2 {
            getDiskUsage(for: arguments[2])
        } else {
            print("Usage: ./iUtile disk-usage <path>")
        }
    case "list-processes":
        listProcesses()
    default:
        print("Unknown command")
    }
} else {
    print("Usage: ./iUtile <command>")
    print("Available commands: cpu-usage, memory-usage, disk-usage, list-processes")
}


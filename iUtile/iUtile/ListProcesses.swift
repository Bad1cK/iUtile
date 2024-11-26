import Foundation

func listProcesses() {
    var length = Int(0)
    let name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL]

    // Узнаем размер данных, которые вернет sysctl
    sysctl(UnsafeMutablePointer(mutating: name), 3, nil, &length, nil, 0)

    // Создаем буфер для данных
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: length, alignment: MemoryLayout<kinfo_proc>.alignment)
    defer { buffer.deallocate() }

    // Заполняем буфер данными о процессах
    sysctl(UnsafeMutablePointer(mutating: name), 3, buffer, &length, nil, 0)

    let procCount = length / MemoryLayout<kinfo_proc>.size
    let procList = buffer.bindMemory(to: kinfo_proc.self, capacity: procCount)

    // Заголовок таблицы
    print(String(format: "%-10s %-50s %-8s", "PID", "COMMAND", "PPID"))
    print(String(repeating: "-", count: 70))

    // Перебираем все процессы
    for i in 0..<procCount {
        var process = procList[i] // Создаем изменяемую копию process
        let pid = process.kp_proc.p_pid

        // Читаем команду (имя процесса) безопасно
        let command = String(cString: &process.kp_proc.p_comm.0)
        let ppid = process.kp_eproc.e_ppid

        // Фильтруем только активные процессы
        if pid > 0 {
            print(String(format: "%-10d %-50s %-8d", pid, command, ppid))
        }
    }
}

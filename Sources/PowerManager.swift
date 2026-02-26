import Foundation

final class PowerManager {
    private var caffeinateProcess: Process?

    var isEnabled: Bool {
        let output = shell("/usr/bin/pmset", "-g")
        return output.contains("SleepDisabled\t\t1") || output.contains("SleepDisabled        1")
    }

    func enable() {
        // Prevent sleep (including lid close)
        shell("/usr/bin/sudo", "-n", "/usr/bin/pmset", "-a", "disablesleep", "1")
        // Prevent disk sleep
        shell("/usr/bin/sudo", "-n", "/usr/bin/pmset", "-a", "disksleep", "0")
        // Let display sleep normally
        shell("/usr/bin/sudo", "-n", "/usr/bin/pmset", "-b", "displaysleep", "1")
        shell("/usr/bin/sudo", "-n", "/usr/bin/pmset", "-c", "displaysleep", "5")

        startCaffeinate()
    }

    func disable() {
        stopCaffeinate()

        // Restore defaults
        shell("/usr/bin/sudo", "-n", "/usr/bin/pmset", "-a", "disablesleep", "0")
        shell("/usr/bin/sudo", "-n", "/usr/bin/pmset", "-b", "sleep", "1")
        shell("/usr/bin/sudo", "-n", "/usr/bin/pmset", "-b", "disksleep", "10")
        shell("/usr/bin/sudo", "-n", "/usr/bin/pmset", "-b", "displaysleep", "2")
    }

    func sleepNow() {
        shell("/usr/bin/sudo", "-n", "/usr/bin/pmset", "sleepnow")
    }

    private func startCaffeinate() {
        stopCaffeinate()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-ims"]
        try? process.run()
        caffeinateProcess = process
    }

    private func stopCaffeinate() {
        if let process = caffeinateProcess, process.isRunning {
            process.terminate()
            caffeinateProcess = nil
        }
    }

    @discardableResult
    private func shell(_ args: String...) -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: args[0])
        process.arguments = Array(args.dropFirst())
        process.standardOutput = pipe
        process.standardError = pipe
        try? process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

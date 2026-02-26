import Foundation
import IOKit.ps
import UserNotifications

final class BatteryMonitor {
    private var timer: Timer?
    private let interval: TimeInterval = 60
    private let criticalThreshold = 5
    private let warningThreshold = 10

    var onBatteryUpdate: ((Int, Bool) -> Void)?  // (percentage, isOnAC)
    var onCriticalBattery: ((Bool) -> Void)?       // (isClamshellClosed)

    struct BatteryInfo {
        let percentage: Int
        let isOnAC: Bool
        var hasBattery: Bool { percentage >= 0 }
    }

    func start() {
        checkBattery()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkBattery()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func currentInfo() -> BatteryInfo {
        return readBattery()
    }

    private func checkBattery() {
        let info = readBattery()
        onBatteryUpdate?(info.percentage, info.isOnAC)

        // Desktop Macs have no battery — skip all battery logic
        guard info.hasBattery, !info.isOnAC else { return }

        if info.percentage <= criticalThreshold {
            let clamshell = isClamshellClosed()
            onCriticalBattery?(clamshell)
        } else if info.percentage <= warningThreshold {
            sendNotification(
                title: "AlwaysOn",
                body: "Battery at \(info.percentage)% — will act at \(criticalThreshold)%"
            )
        }
    }

    private func readBattery() -> BatteryInfo {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [Any],
              let first = sources.first,
              let desc = IOPSGetPowerSourceDescription(snapshot, first as CFTypeRef)?.takeUnretainedValue() as? [String: Any]
        else {
            // No power source info — desktop Mac or error
            return BatteryInfo(percentage: -1, isOnAC: true)
        }

        let capacity = desc[kIOPSCurrentCapacityKey] as? Int ?? -1
        let source = desc[kIOPSPowerSourceStateKey] as? String ?? ""
        let isOnAC = (source == kIOPSACPowerValue)

        return BatteryInfo(percentage: capacity, isOnAC: isOnAC)
    }

    private func isClamshellClosed() -> Bool {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/ioreg")
        process.arguments = ["-r", "-k", "AppleClamshellState", "-d", "4"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return output.contains("\"AppleClamshellState\" = Yes")
    }

    private func sendNotification(title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        center.add(request)
    }
}

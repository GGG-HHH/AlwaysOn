import Foundation
import ServiceManagement

final class LoginItemManager {
    private let launchAgentLabel = "com.gw.alwayson"
    private var launchAgentPath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Library/LaunchAgents/\(launchAgentLabel).plist"
    }

    var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            }
            return FileManager.default.fileExists(atPath: launchAgentPath)
        }
    }

    func setEnabled(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
                return
            } catch {
                // Fallback to LaunchAgent
                NSLog("SMAppService failed: \(error), falling back to LaunchAgent")
            }
        }

        if enabled {
            installLaunchAgent()
        } else {
            removeLaunchAgent()
        }
    }

    private func installLaunchAgent() {
        guard let appPath = Bundle.main.bundlePath as String? else { return }
        let plist: [String: Any] = [
            "Label": launchAgentLabel,
            "ProgramArguments": ["\(appPath)/Contents/MacOS/AlwaysOn"],
            "RunAtLoad": true,
            "KeepAlive": false
        ]

        let dir = (launchAgentPath as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

        let data = try? PropertyListSerialization.data(
            fromPropertyList: plist, format: .xml, options: 0
        )
        FileManager.default.createFile(atPath: launchAgentPath, contents: data)
    }

    private func removeLaunchAgent() {
        try? FileManager.default.removeItem(atPath: launchAgentPath)
    }
}

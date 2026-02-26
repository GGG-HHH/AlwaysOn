import Foundation
import AppKit

final class PrivilegeManager {
    static let sudoersPath = "/etc/sudoers.d/pmset"
    static let sudoersRule = "%admin ALL=(ALL) NOPASSWD: /usr/bin/pmset"

    /// Returns true if `sudo -n pmset -g` works without a password
    static func hasPasswordlessPmset() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = ["-n", "/usr/bin/pmset", "-g"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
        return process.terminationStatus == 0
    }

    /// Shows a dialog explaining the privilege requirement, then uses osascript
    /// to trigger the macOS native password prompt and write the sudoers rule.
    /// Returns true on success.
    @discardableResult
    static func requestPrivileges() -> Bool {
        let alert = NSAlert()
        alert.messageText = "AlwaysOn Needs Permission"
        alert.informativeText = """
            AlwaysOn needs to control system sleep settings using pmset.

            Clicking "Grant Access" will prompt for your password once \
            to configure passwordless access for pmset only.

            This creates /etc/sudoers.d/pmset — no other commands are affected.
            """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Grant Access")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return false }

        return installSudoersRule()
    }

    private static func installSudoersRule() -> Bool {
        // Use osascript to run a shell command with admin privileges
        // This triggers the native macOS password dialog
        let script = """
            do shell script \
            "echo '\(sudoersRule)' > \(sudoersPath) && chmod 0440 \(sudoersPath)" \
            with administrator privileges
            """

        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        process.standardOutput = pipe
        process.standardError = pipe
        try? process.run()
        process.waitUntilExit()

        return process.terminationStatus == 0
    }
}

import AppKit
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let powerManager = PowerManager()
    private let batteryMonitor = BatteryMonitor()
    private let loginItemManager = LoginItemManager()

    // Menu items that need updating
    private var toggleMenuItem: NSMenuItem!
    private var batteryMenuItem: NSMenuItem!
    private var powerSourceMenuItem: NSMenuItem!
    private var loginMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permission early
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        // Check privileges
        if !PrivilegeManager.hasPasswordlessPmset() {
            let granted = PrivilegeManager.requestPrivileges()
            if !granted {
                let alert = NSAlert()
                alert.messageText = "Permission Required"
                alert.informativeText = "AlwaysOn cannot function without pmset access. The app will quit."
                alert.alertStyle = .critical
                alert.addButton(withTitle: "Quit")
                alert.runModal()
                NSApp.terminate(nil)
                return
            }
        }

        setupStatusItem()
        setupBatteryMonitor()
        updateMenuState()
    }

    // MARK: - Status Bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "bolt.slash.fill", accessibilityDescription: "AlwaysOn")
        button.imagePosition = .imageLeading

        let menu = NSMenu()

        toggleMenuItem = NSMenuItem(title: "Enable AlwaysOn", action: #selector(toggleAlwaysOn), keyEquivalent: "")
        toggleMenuItem.target = self
        menu.addItem(toggleMenuItem)

        menu.addItem(NSMenuItem.separator())

        batteryMenuItem = NSMenuItem(title: "Battery: --", action: nil, keyEquivalent: "")
        batteryMenuItem.isEnabled = false
        menu.addItem(batteryMenuItem)

        powerSourceMenuItem = NSMenuItem(title: "Power: --", action: nil, keyEquivalent: "")
        powerSourceMenuItem.isEnabled = false
        menu.addItem(powerSourceMenuItem)

        menu.addItem(NSMenuItem.separator())

        loginMenuItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLoginItem), keyEquivalent: "")
        loginMenuItem.target = self
        menu.addItem(loginMenuItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Battery Monitor

    private func setupBatteryMonitor() {
        batteryMonitor.onBatteryUpdate = { [weak self] percentage, isOnAC in
            DispatchQueue.main.async {
                self?.updateBatteryDisplay(percentage: percentage, isOnAC: isOnAC)
            }
        }

        batteryMonitor.onCriticalBattery = { [weak self] isClamshellClosed in
            DispatchQueue.main.async {
                self?.handleCriticalBattery(clamshellClosed: isClamshellClosed)
            }
        }

        batteryMonitor.start()
    }

    private func updateBatteryDisplay(percentage: Int, isOnAC: Bool) {
        let pctText = percentage >= 0 ? "\(percentage)%" : "--"
        batteryMenuItem.title = "Battery: \(pctText)"
        powerSourceMenuItem.title = "Power: \(isOnAC ? "AC" : "Battery")"

        // Update status bar button text
        if powerManager.isEnabled && percentage >= 0 {
            statusItem.button?.title = " \(pctText)"
        }
    }

    private func handleCriticalBattery(clamshellClosed: Bool) {
        guard powerManager.isEnabled else { return }

        if clamshellClosed {
            // Lid closed + critical battery → sleep to protect battery
            powerManager.disable()
            powerManager.sleepNow()
            updateMenuState()
        } else {
            // Lid open + critical battery → notify, don't force sleep
            sendCriticalNotification()
        }
    }

    private func sendCriticalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "AlwaysOn — Critical Battery"
        content.body = "Battery at 5% or below. Connect charger or disable AlwaysOn."
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "critical-battery",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - State Management

    private func updateMenuState() {
        let enabled = powerManager.isEnabled
        let info = batteryMonitor.currentInfo()
        let pctText = info.percentage >= 0 ? "\(info.percentage)%" : "--"

        toggleMenuItem.title = enabled ? "Disable AlwaysOn" : "Enable AlwaysOn"
        loginMenuItem.state = loginItemManager.isEnabled ? .on : .off

        if enabled {
            statusItem.button?.image = NSImage(
                systemSymbolName: "bolt.fill",
                accessibilityDescription: "AlwaysOn Active"
            )
            statusItem.button?.title = " \(pctText)"
        } else {
            statusItem.button?.image = NSImage(
                systemSymbolName: "bolt.slash.fill",
                accessibilityDescription: "AlwaysOn Inactive"
            )
            statusItem.button?.title = ""
        }

        batteryMenuItem.title = "Battery: \(pctText)"
        powerSourceMenuItem.title = "Power: \(info.isOnAC ? "AC" : "Battery")"
    }

    // MARK: - Actions

    @objc private func toggleAlwaysOn() {
        if powerManager.isEnabled {
            powerManager.disable()
        } else {
            powerManager.enable()
        }
        updateMenuState()
    }

    @objc private func toggleLoginItem() {
        let newState = !loginItemManager.isEnabled
        loginItemManager.setEnabled(newState)
        loginMenuItem.state = newState ? .on : .off
    }

    @objc private func quitApp() {
        if powerManager.isEnabled {
            powerManager.disable()
        }
        batteryMonitor.stop()
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        if powerManager.isEnabled {
            powerManager.disable()
        }
        batteryMonitor.stop()
    }
}

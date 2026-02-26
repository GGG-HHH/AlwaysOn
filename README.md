# ⚡ AlwaysOn

**Your Mac Never Sleeps.**

In the age of AI agents, your laptop should run forever. AlwaysOn is a 52KB native macOS menu bar app that prevents sleep — including lid close — with smart battery protection.

[Download](https://github.com/GGG-HHH/AlwaysOn/releases/latest/download/AlwaysOn.zip) · [Website](https://ggg-hhh.github.io/AlwaysOn/)

---

## Features

- **One-Click Sleep Prevention** — Disables system sleep entirely, including lid close. AI agents, builds, and downloads keep running.
- **Smart Battery Protection** — Monitors every 60s. Lid closed + ≤5% → auto sleep. Lid open → notification only. Warning at 10%.
- **Zero-Config Privileges** — First launch triggers native macOS password dialog. One password, forever passwordless. Only `pmset`.
- **Menu Bar Native** — SF Symbols icon with live battery %. Toggle on/off, launch at login. No Dock icon, no bloat.

## Setup

1. **Download** — [AlwaysOn.zip](https://github.com/GGG-HHH/AlwaysOn/releases/latest/download/AlwaysOn.zip), unzip, drag to `/Applications`
2. **First launch** — Right-click → Open (Gatekeeper bypass, one-time only)
3. **Grant permission** — Enter password once in the native macOS dialog
4. **Click Enable** — Done. Your Mac stays awake with lid closed.

## Menu

```
⚡ 78%
├── Enable/Disable AlwaysOn
├── ──────────────
├── Battery: 78%
├── Power: AC / Battery
├── ──────────────
├── ✓ Launch at Login
├── ──────────────
└── Quit
```

## Under the Hood

| | |
|---|---|
| Language | Pure Swift |
| Binary | 52KB, Universal (arm64 + x86_64) |
| Frameworks | AppKit, IOKit, ServiceManagement |
| Sleep control | `pmset disablesleep` + `caffeinate -ims` |
| Privilege | `/etc/sudoers.d/pmset` (NOPASSWD for pmset only) |
| Login item | SMAppService (macOS 13+) with LaunchAgent fallback |
| Signing | Ad-hoc codesigned |
| Min OS | macOS 13.0 (Ventura) |

## Build from Source

```bash
git clone https://github.com/GGG-HHH/AlwaysOn.git
cd AlwaysOn
./build.sh
open AlwaysOn.app
```

## Uninstall

1. Click "Disable" → "Quit" in the menu bar (restores power defaults)
2. Delete `AlwaysOn.app` from Applications
3. Optional: `sudo rm /etc/sudoers.d/pmset`

## FAQ

**macOS says "can't verify the developer"**
Right-click → Open → Open. One-time only.

**What does the password prompt do?**
Creates `/etc/sudoers.d/pmset` to allow passwordless `pmset`. Nothing else.

**Force-quit without disabling?**
Run `sudo pmset -a disablesleep 0` in Terminal, or relaunch the app and click Disable.

## License

MIT

---

# ⚡ AlwaysOn

**让你的 Mac 永不休眠。**

AI Agent 时代，你的笔记本应该永远在线。AlwaysOn 是一个 52KB 的原生 macOS 菜单栏应用，防止系统休眠（包括合盖），并内置智能电池保护。

[下载](https://github.com/GGG-HHH/AlwaysOn/releases/latest/download/AlwaysOn.zip) · [官网](https://ggg-hhh.github.io/AlwaysOn/)

---

## 功能

- **一键防休眠** — 完全禁用系统休眠，包括合盖。AI Agent、长时间编译、通宵下载不中断。
- **智能电池保护** — 每 60 秒检测电量。合盖 + ≤5% → 自动休眠。开盖 → 仅通知。10% 时警告。
- **零配置权限** — 首次启动弹出 macOS 原生密码框，输入一次即永久免密。仅授权 `pmset`。
- **原生菜单栏** — SF Symbols 图标 + 实时电量。开关切换，支持开机自启。无 Dock 图标。

## 安装

1. **下载** — [AlwaysOn.zip](https://github.com/GGG-HHH/AlwaysOn/releases/latest/download/AlwaysOn.zip)，解压后拖入 `/Applications`
2. **首次启动** — 右键 → 打开（绕过 Gatekeeper，仅需一次）
3. **授予权限** — 在 macOS 原生密码弹窗中输入密码（仅一次）
4. **点击启用** — 完成。Mac 合盖后保持唤醒。

## 从源码构建

```bash
git clone https://github.com/GGG-HHH/AlwaysOn.git
cd AlwaysOn
./build.sh
open AlwaysOn.app
```

## 卸载

1. 菜单栏点击 "Disable" → "Quit"（自动恢复电源默认设置）
2. 删除应用程序中的 AlwaysOn.app
3. 可选：`sudo rm /etc/sudoers.d/pmset`

## 常见问题

**macOS 提示「无法验证开发者」**
右键 → 打开 → 打开。仅需一次。

**密码弹窗做了什么？**
创建 `/etc/sudoers.d/pmset`，仅允许免密执行 `pmset`，不影响其他命令。

**强制退出后怎么恢复？**
终端执行 `sudo pmset -a disablesleep 0`，或重新打开 App 点击 Disable。

## 许可证

MIT

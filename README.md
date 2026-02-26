<p align="center">
  <img src="site/icon.svg" width="120" height="120" alt="AlwaysOn">
</p>

<h1 align="center">AlwaysOn</h1>

<p align="center">
  <strong>Your Mac Never Sleeps.</strong><br>
  In the age of AI agents, your Mac should run forever.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-000?style=flat-square&logo=apple&logoColor=fff" alt="macOS 13+">
  <img src="https://img.shields.io/badge/arch-Universal%20Binary-000?style=flat-square" alt="Universal Binary">
  <img src="https://img.shields.io/badge/size-83KB-000?style=flat-square" alt="83KB">
  <img src="https://img.shields.io/badge/language-Swift-000?style=flat-square&logo=swift&logoColor=F05138" alt="Swift">
  <img src="https://img.shields.io/badge/license-MIT-000?style=flat-square" alt="MIT">
</p>

<p align="center">
  <a href="https://github.com/GGG-HHH/AlwaysOn/releases/latest/download/AlwaysOn.zip"><strong>Download</strong></a> · <a href="https://ggg-hhh.github.io/AlwaysOn/">Website</a> · <a href="#build-from-source">Build from Source</a>
</p>

<p align="center">
  <sub>Works on all Macs: MacBook · Mac mini · iMac · Mac Studio · Mac Pro</sub>
</p>

---

## Features

> **One-Click Sleep Prevention** — Disables system sleep entirely, including lid close. AI agents, builds, and downloads keep running.

> **Smart Battery Protection** — Monitors every 60s. Lid closed + ≤5% → auto sleep. Lid open → notification only. Warning at 10%.

> **Zero-Config Privileges** — First launch triggers native macOS password dialog. One password, forever passwordless. Only `pmset`.

> **Menu Bar Native** — SF Symbols icon with live battery %. Toggle on/off, launch at login. No Dock icon, no bloat.

## Setup

```
1. Download → Unzip → Drag to /Applications
2. Right-click → Open (first time only)
3. Enter password once
4. Click Enable ⚡ Done.
```

## Menu Bar

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
|:--|:--|
| **Language** | Pure Swift |
| **Binary** | 83KB, Universal (arm64 + x86_64) |
| **Frameworks** | AppKit, IOKit, ServiceManagement |
| **Sleep control** | `pmset disablesleep` + `caffeinate -ims` |
| **Privilege** | `/etc/sudoers.d/pmset` (NOPASSWD for pmset only) |
| **Login item** | SMAppService (macOS 13+) with LaunchAgent fallback |
| **Signing** | Ad-hoc codesigned |
| **Min OS** | macOS 13.0 (Ventura) |

## Build from Source

```bash
git clone https://github.com/GGG-HHH/AlwaysOn.git
cd AlwaysOn
./build.sh
open AlwaysOn.app
```

## Uninstall

1. Click **Disable** → **Quit** in the menu bar (restores power defaults)
2. Delete `AlwaysOn.app` from Applications
3. Optional: `sudo rm /etc/sudoers.d/pmset`

## FAQ

<details>
<summary><b>Why can't I open the app?</b></summary>
<br>
Right-click → Open → Open. One-time only.<br><br>
If it still won't open: <b>System Settings → Privacy & Security → Security</b>, click <b>"Open Anyway"</b>.
</details>

<details>
<summary><b>What does the password prompt do?</b></summary>
<br>
Creates <code>/etc/sudoers.d/pmset</code> to allow passwordless <code>pmset</code>. Nothing else.
</details>

<details>
<summary><b>Can't see the menu bar icon?</b></summary>
<br>
On notch MacBooks, too many icons can push it behind the camera. Hold <code>⌘</code> to drag and reorder icons, or use <a href="https://github.com/jordanbaird/Ice">Ice</a> (free & open source) to manage overflow.
</details>

<details>
<summary><b>Force-quit without disabling?</b></summary>
<br>
Run <code>sudo pmset -a disablesleep 0</code> in Terminal, or relaunch the app and click Disable.
</details>

## License

MIT

---

<p align="center">
  <img src="site/icon.svg" width="120" height="120" alt="AlwaysOn">
</p>

<h1 align="center">AlwaysOn</h1>

<p align="center">
  <strong>让你的 Mac 永不休眠。</strong><br>
  AI Agent 时代，你的 Mac 应该永远在线。
</p>

<p align="center">
  <a href="https://github.com/GGG-HHH/AlwaysOn/releases/latest/download/AlwaysOn.zip"><strong>下载</strong></a> · <a href="https://ggg-hhh.github.io/AlwaysOn/">官网</a> · <a href="#从源码构建">从源码构建</a>
</p>

<p align="center">
  <sub>支持所有 Mac：MacBook · Mac mini · iMac · Mac Studio · Mac Pro</sub>
</p>

---

## 功能

> **一键防休眠** — 完全禁用系统休眠，包括合盖。AI Agent、长时间编译、通宵下载不中断。

> **智能电池保护** — 每 60 秒检测电量。合盖 + ≤5% → 自动休眠。开盖 → 仅通知。10% 时警告。

> **零配置权限** — 首次启动弹出 macOS 原生密码框，输入一次即永久免密。仅授权 `pmset`。

> **原生菜单栏** — SF Symbols 图标 + 实时电量。开关切换，支持开机自启。无 Dock 图标。

## 安装

```
1. 下载 → 解压 → 拖入 /Applications
2. 右键 → 打开（仅首次）
3. 输入一次密码
4. 点击启用 ⚡ 搞定。
```

## 从源码构建

```bash
git clone https://github.com/GGG-HHH/AlwaysOn.git
cd AlwaysOn
./build.sh
open AlwaysOn.app
```

## 卸载

1. 菜单栏点击 **Disable** → **Quit**（自动恢复电源默认设置）
2. 删除应用程序中的 AlwaysOn.app
3. 可选：`sudo rm /etc/sudoers.d/pmset`

## 常见问题

<details>
<summary><b>为什么打不开 App？</b></summary>
<br>
右键 → 打开 → 打开。仅需一次。<br><br>
如果仍然无法打开：<b>系统设置 → 隐私与安全性 → 安全性</b>，点击<b>「仍要打开」</b>。
</details>

<details>
<summary><b>密码弹窗做了什么？</b></summary>
<br>
创建 <code>/etc/sudoers.d/pmset</code>，仅允许免密执行 <code>pmset</code>，不影响其他命令。
</details>

<details>
<summary><b>菜单栏看不到图标？</b></summary>
<br>
刘海屏 MacBook 上图标过多会被挤到摄像头后面。按住 <code>⌘</code> 拖拽重新排列，或使用 <a href="https://github.com/jordanbaird/Ice">Ice</a>（免费开源）管理菜单栏。
</details>

<details>
<summary><b>强制退出后怎么恢复？</b></summary>
<br>
终端执行 <code>sudo pmset -a disablesleep 0</code>，或重新打开 App 点击 Disable。
</details>

## 许可证

MIT

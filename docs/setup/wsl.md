# WSLを使うメリットとインストール方法

## WSLとは
Windows上でLinux環境を動かせる仕組み（Windows Subsystem for Linux）。

## 使うメリット
- **Linuxコマンド/ツールがそのまま使える**
  - `bash`, `grep`, `ssh`, `curl`, `git`, `make` など開発・運用が楽
- **開発環境が揃えやすい**
  - Node.js / Python / Docker / 各種CLI をLinux前提で揃えられる
- **Windowsアプリと併用できる**
  - VS Code、ブラウザ、Slack等はWindows側のまま、開発はLinux側で快適
- **軽量でセットアップが速い（VMより手軽）**
  - フルVMより起動/運用の負担が少ない

## インストール方法（Windows 11 / 10）
### 1 管理者権限でPowerShellを開く
スタートメニュー → 「PowerShell」→ 右クリック → **管理者として実行**

### 2 WSLをインストール
```powershell
wsl --install
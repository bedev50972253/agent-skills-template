# 🤖 Agent Skills 自動化部署腳本

此目錄包含自動化腳本,用於將 Agent Skills 結構應用到現有或新的倉庫。

## 📜 腳本列表

### 1. `apply-to-repo.ps1` - PowerShell 腳本 (Windows / Mac / Linux)

將 Agent Skills 模板應用到指定倉庫。

**使用方式**:
```powershell
# 應用到本地現有倉庫
.\scripts\apply-to-repo.ps1 -RepoPath "C:\Projects\MyProject"

# 應用到當前目錄
.\scripts\apply-to-repo.ps1

# 僅複製特定資料夾
.\scripts\apply-to-repo.ps1 -RepoPath "." -OnlySkills
```

### 2. `sync-from-template.ps1` - 同步更新腳本

從模板倉庫同步最新的 Agent Skills 結構,不覆蓋自訂技能。

**使用方式**:
```powershell
.\scripts\sync-from-template.ps1 -TemplateRepo "bedev50972253/agent-skills-template"
```

### 3. `validate-skills.ps1` - 驗證腳本

檢查 Skills YAML frontmatter 格式是否正確。

**使用方式**:
```powershell
.\scripts\validate-skills.ps1
```

## 🚀 快速開始

### 步驟 1: 克隆模板倉庫

```bash
gh repo clone bedev50972253/agent-skills-template
cd agent-skills-template
```

### 步驟 2: 應用到您的專案

```powershell
# 假設您的專案位於 C:\Projects\MyApp
.\scripts\apply-to-repo.ps1 -RepoPath "C:\Projects\MyApp"
```

### 步驟 3: 提交變更

```bash
cd C:\Projects\MyApp
git add .
git commit -m "feat: 新增 Agent Skills 結構"
git push
```

## 🔄 定期同步

在專案中使用 GitHub Actions 自動同步模板更新:

```yaml
# .github/workflows/sync-agent-skills.yml
name: Sync Agent Skills

on:
  schedule:
    - cron: '0 0 * * 0'  # 每週日午夜
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Sync from template
        run: |
          # 下載最新模板...
```

## 📚 相關資源

- [GitHub CLI 文件](https://cli.github.com/manual/)
- [模板倉庫](https://github.com/bedev50972253/agent-skills-template)

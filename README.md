# README.md

<div align="center">

# 🤖 Agent Skills Template

**自動化建立符合 [agentskills.io](https://agentskills.io/) 標準的 MCP、Copilot Agents 與 Skills 架構**

[![GitHub](https://img.shields.io/badge/GitHub-bedev50972253-blue?logo=github)](https://github.com/bedev50972253/agent-skills-template)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-v1.0.0-orange)](https://agentskills.io/)

</div>

---

## 📋 專案簡介

此模板倉庫提供標準化的 **Agent Skills** 結構,讓每個專案都能快速建立符合業界標準的 AI Coding Agent 架構,支援:

- ✅ **GitHub Copilot** (VS Code / CLI / Workspace)
- ✅ **Claude Desktop** (MCP 整合)
- ✅ **Azure AI Foundry** (Agents Service)
- ✅ **多模型通用** (依循 agentskills.io 開放標準)

## 🎯 核心功能

### 1. 完整的 Agent 架構

```
📁 專案根目錄/
├── AGENTS.md                      # Agent 總覽與索引
├── .github/
│   ├── agents/                    # 自訂代理定義
│   │   ├── planner.agent.md
│   │   ├── backend.agent.md
│   │   ├── frontend.agent.md
│   │   ├── database.agent.md
│   │   ├── infra.agent.md
│   │   └── security.agent.md
│   ├── prompts/                   # 可重用提示模板
│   │   ├── migration.prompt.md
│   │   └── ui-component.prompt.md
│   ├── instructions/              # 編碼規範與檢查點
│   │   ├── coding-standards.instructions.md
│   │   └── ssldlc-checklist.instructions.md
│   └── workflows/                 # GitHub Actions
│       └── sync-agent-skills.yml
└── skills/                        # 技能庫
    ├── template-skill/            # 技能範本
    ├── clean-architecture/
    ├── efcore-migration/
    ├── bootstrap5-ui/
    ├── azure-deployment/
    └── cqrs-mediatr/
```

### 2. 自動化腳本

- **`scripts/apply-to-repo.ps1`**: 將模板應用到現有專案
- **`scripts/sync-from-template.ps1`**: 同步模板更新
- **GitHub Actions**: 自動檢查並同步最新模板

### 3. 最佳實踐範例

- **6 個預建 Agent**: Planner、Backend、Frontend、Database、Infra、Security
- **多個 Skills**: Clean Architecture、EF Core、CQRS、Azure 部署
- **編碼規範**: C#、TypeScript、SQL 命名與註解標準
- **SSLDLC 檢查清單**: 完整的安全開發生命週期指南

## 🚀 快速開始

### 方法 1: 使用模板建立新倉庫

1. **點擊「Use this template」按鈕** 建立新倉庫
2. **克隆您的新倉庫**
   ```bash
   gh repo clone YOUR_USERNAME/YOUR_NEW_REPO
   cd YOUR_NEW_REPO
   ```
3. **根據專案需求修改技能**
   - 編輯 `AGENTS.md`
   - 新增自訂 Skills 到 `skills/` 目錄
   - 調整 Agent 定義

### 方法 2: 應用到現有專案

使用 PowerShell 腳本:

```powershell
# 克隆模板倉庫
gh repo clone bedev50972253/agent-skills-template
cd agent-skills-template

# 應用到您的專案
.\scripts\apply-to-repo.ps1 -RepoPath "C:\Path\To\Your\Project"
```

### 方法 3: 手動複製

```bash
# 1. 複製核心檔案到您的專案
cp AGENTS.md YOUR_PROJECT/
cp -r .github/agents YOUR_PROJECT/.github/
cp -r skills YOUR_PROJECT/

# 2. 提交變更
cd YOUR_PROJECT
git add .
git commit -m "feat: 新增 Agent Skills 結構"
git push
```

## 📖 使用指南

### 建立新技能

1. **複製範本**:
   ```bash
   cp -r skills/template-skill skills/your-skill-name
   ```

2. **編輯 SKILL.md**:
   ```yaml
   ---
   name: your-skill-name
   description: 技能簡短描述
   version: 1.0.0
   category: backend
   tags:
     - dotnet
     - webapi
   ---
   ```

3. **更新 AGENTS.md**:
   在技能清單新增連結

### 自訂 Agent

編輯 `.github/agents/*agent.md` 檔案,調整:
- 核心能力
- 使用範例
- 技術堆疊
- 相關技能連結

### 啟用自動同步

模板已包含 GitHub Actions 工作流程,每週自動檢查模板更新:

```yaml
# .github/workflows/sync-agent-skills.yml
on:
  schedule:
    - cron: '0 0 * * 0'  # 每週日
```

## 🔗 參考資源

### 官方標準
- [agentskills.io](https://agentskills.io/) - Agent Skills 開放標準
- [GitHub Copilot Agents](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- [VS Code Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Anthropic Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)

### 社群範例
- [github/awesome-copilot](https://github.com/github/awesome-copilot)
- [vercel-labs/skills](https://github.com/vercel-labs/skills)
- [microsoft/agent-skills](https://github.com/microsoft/agent-skills)
- [heilcheng/awesome-agent-skills](https://github.com/heilcheng/awesome-agent-skills)
- [agentskills GitHub](https://github.com/agentskills)

### 最佳實踐
- [如何撰寫優秀的 AGENTS.md](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)

## 🤝 貢獻

歡迎貢獻！請:

1. Fork 此倉庫
2. 建立功能分支 (`git checkout -b feature/new-skill`)
3. 提交變更 (`git commit -m 'feat: add new skill'`)
4. 推送到分支 (`git push origin feature/new-skill`)
5. 開啟 Pull Request

### 貢獻指南

- **新增技能**: 遵循 `skills/template-skill/SKILL.md` 格式
- **Agent 定義**: 使用正體中文,包含具體範例
- **編碼規範**: 參考 `.github/instructions/coding-standards.instructions.md`

## 📄 授權

本專案採用 **MIT License** - 詳見 [LICENSE](LICENSE) 檔案

## 🙏 致謝

本專案參考並整合了以下優秀資源:

- [GitHub Copilot Documentation](https://docs.github.com/copilot)
- [Microsoft Agent Framework](https://github.com/microsoft/agent-skills)
- [Anthropics Skills](https://github.com/anthropics/skills)
- [Vercel Labs Skills](https://github.com/vercel-labs/skills)

## 📞 聯絡方式

- **GitHub**: [@bedev50972253](https://github.com/bedev50972253)
- **Issues**: [提交問題](https://github.com/bedev50972253/agent-skills-template/issues)

---

<div align="center">

**Made with ❤️ by BlueWhale Development Team**

⭐ 如果這個專案對您有幫助,請給它一顆星！

</div>

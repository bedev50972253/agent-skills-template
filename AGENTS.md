# 🤖 Agent Skills 總覽

> **本專案遵循 [agentskills.io](https://agentskills.io/) 開放標準**  
> 整合 GitHub Copilot、Claude、Azure AI Foundry 等多平台 Agent 支援

## 📋 可用代理 (Agents)

本專案提供以下專業代理協助開發：

### 🎯 規劃代理 (Planner Agent)
- **檔案**: [.github/agents/planner.agent.md](.github/agents/planner.agent.md)
- **專長**: 需求分析、架構設計、多步驟計劃制定
- **使用時機**: 專案啟動、功能規劃、技術選型

### 💻 前端代理 (Frontend Agent)
- **檔案**: [.github/agents/frontend.agent.md](.github/agents/frontend.agent.md)
- **專長**: React、Vue、Angular、Bootstrap、Tailwind CSS
- **使用時機**: UI/UX 開發、前端最佳實踐

### ⚙️ 後端代理 (Backend Agent)
- **檔案**: [.github/agents/backend.agent.md](.github/agents/backend.agent.md)
- **專長**: .NET、Java、Python、Node.js、Clean Architecture
- **使用時機**: API 開發、商業邏輯實作、架構設計

### 🗄️ 資料庫代理 (Database Agent)
- **檔案**: [.github/agents/database.agent.md](.github/agents/database.agent.md)
- **專長**: EF Core、SQL Server、PostgreSQL、MongoDB
- **使用時機**: 資料模型設計、Migration、查詢最佳化

### ☁️ 基礎設施代理 (Infrastructure Agent)
- **檔案**: [.github/agents/infra.agent.md](.github/agents/infra.agent.md)
- **專長**: Azure、Docker、Kubernetes、Bicep、Terraform
- **使用時機**: 雲端部署、DevOps、CI/CD 配置

### 🔒 安全代理 (Security Agent)
- **檔案**: [.github/agents/security.agent.md](.github/agents/security.agent.md)
- **專長**: SSLDLC、OWASP、驗證授權、資料保護
- **使用時機**: 安全審查、漏洞修復、合規檢查

## 🛠️ 技能清單 (Skills)

### 核心技能
- [Clean Architecture](skills/clean-architecture/SKILL.md) - 整潔架構模式
- [EF Core Migration](skills/efcore-migration/SKILL.md) - Entity Framework Core 遷移
- [CQRS + MediatR](skills/cqrs-mediatr/SKILL.md) - 命令查詢責任分離
- [Azure Deployment](skills/azure-deployment/SKILL.md) - Azure 雲端部署
- [Bootstrap 5 UI](skills/bootstrap5-ui/SKILL.md) - Bootstrap 5 介面設計

### 建立自訂技能
參考 [skills/template-skill/SKILL.md](skills/template-skill/SKILL.md) 範本建立專案特定技能。

## 📝 提示模板 (Prompts)

可重用的提示範本位於 `.github/prompts/` 目錄：
- [migration.prompt.md](.github/prompts/migration.prompt.md) - 資料庫遷移提示
- [ui-component.prompt.md](.github/prompts/ui-component.prompt.md) - UI 元件生成提示

## 📖 編碼指南 (Instructions)

專案特定規範與檢查點位於 `.github/instructions/` 目錄：
- [coding-standards.instructions.md](.github/instructions/coding-standards.instructions.md) - 編碼標準
- [ssldlc-checklist.instructions.md](.github/instructions/ssldlc-checklist.instructions.md) - 安全開發生命週期檢查
- [chinese-comments.instructions.md](.github/instructions/chinese-comments.instructions.md) - 正體中文註解規範

## 🚀 快速開始

### 在專案中使用代理

```bash
# GitHub Copilot (VS Code / CLI)
@workspace /new 使用 Clean Architecture 建立訂單管理 API

# Claude Desktop (MCP)
請使用 Backend Agent 與 Database Agent 建立 CQRS 架構
```

### 新增自訂技能

1. 複製 `skills/template-skill/` 目錄
2. 編輯 `SKILL.md` 檔案（YAML frontmatter + 正體中文說明）
3. 在此文件新增技能連結

## 📚 參考資源

### 官方標準與文件
1. [agentskills.io](https://agentskills.io/) - Agent Skills 開放標準
2. [GitHub Copilot Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
3. [VS Code Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
4. [Anthropic Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)

### 社群範例
- [github/awesome-copilot](https://github.com/github/awesome-copilot)
- [vercel-labs/skills](https://github.com/vercel-labs/skills)
- [microsoft/agent-skills](https://github.com/microsoft/agent-skills)
- [agentskills GitHub](https://github.com/agentskills)
- [heilcheng/awesome-agent-skills](https://github.com/heilcheng/awesome-agent-skills)
- [anthropics/skills](https://github.com/anthropics/skills)
- [google-gemini/gemini-skills](https://github.com/google-gemini/gemini-skills)

### 最佳實踐
- [如何撰寫優秀的 AGENTS.md](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)

## 🔄 自動化更新

本專案使用 GitHub Actions 自動檢查並同步最新的 Agent Skills 標準。

---

**版本**: 1.0.0  
**最後更新**: 2026-02-11  
**維護者**: BlueWhale Development Team

---
name: template-skill
description: Agent Skill 範本，用於建立新技能
version: 1.0.0
category: template
tags:
  - template
  - boilerplate
  - skill-creation
author: BlueWhale Development Team
platform:
  - github-copilot
  - claude-desktop
  - azure-ai-foundry
---

# Template Skill - Agent Skill 範本

## 📋 技能描述

這是一個標準化的 Agent Skill 範本檔案，用於建立符合 [agentskills.io](https://agentskills.io/) 開放標準的技能定義。

## 🎯 使用時機

當需要建立新的專案特定技能時，複製此範本並依照以下步驟修改：

## 🛠️ 建立步驟

### 1. 複製範本目錄

```bash
# 複製範本資料夾
cp -r skills/template-skill skills/your-skill-name

# 進入新技能目錄
cd skills/your-skill-name
```

### 2. 編輯 YAML Frontmatter

修改檔案開頭的 YAML 區塊：

```yaml
---
name: your-skill-name               # 技能唯一識別名稱（小寫、連字號分隔）
description: 技能簡短描述            # 一句話說明技能用途
version: 1.0.0                      # 語意化版本號
category: backend                    # 技能分類（frontend/backend/database/infra/security）
tags:                               # 相關標籤（協助搜尋與分類）
  - dotnet
  - webapi
  - rest
author: Your Name                   # 作者或團隊名稱
platform:                           # 支援的平台
  - github-copilot
  - claude-desktop
  - azure-ai-foundry
---
```

### 3. 撰寫技能內容

使用 Markdown 格式，建議包含以下章節：

#### 必要章節

- **技能描述**: 詳細說明技能功能與目的
- **使用時機**: 何時應該使用此技能
- **核心概念**: 技能涵蓋的關鍵技術或模式
- **使用範例**: 具體的程式碼範例或操作步驟

#### 選用章節

- **最佳實踐**: 推薦的使用方式
- **常見錯誤**: 應避免的反模式
- **相關技能**: 連結到其他相關技能
- **參考資源**: 外部文件連結

## 📝 範例結構

```markdown
# Your Skill Name

## 📋 技能描述

此技能專注於... （詳細描述）

## 🎯 使用時機

當您需要：
- 功能需求 1
- 功能需求 2
- 功能需求 3

## 🧩 核心概念

### 概念 1: 標題
說明內容...

### 概念 2: 標題
說明內容...

## 💡 使用範例

### 範例 1: 場景描述

**輸入提示:**
```
@agent 使用此技能完成某任務
```

**輸出結果:**
```csharp
// 程式碼範例
public class Example { }
```

**說明:**
解釋程式碼的關鍵點...

## ✅ 最佳實踐

1. **實踐 1**: 說明
2. **實踐 2**: 說明

## ❌ 常見錯誤

- **錯誤 1**: 說明與正確做法
- **錯誤 2**: 說明與正確做法

## 🔗 相關技能

- [另一個技能](../other-skill/SKILL.md)

## 📚 參考資源

- [官方文件](https://example.com)
- [教學文章](https://example.com)
```

## 🎨 Markdown 樣式指南

### 標題層級

```markdown
# H1 - 技能名稱（僅用於檔案標題）
## H2 - 主要章節
### H3 - 子章節
#### H4 - 細節說明
```

### 程式碼區塊

````markdown
```csharp
// C# 範例
public class Sample { }
```

```typescript
// TypeScript 範例
const sample: string = "Hello";
```
````

### 強調與提示

```markdown
**粗體** - 重要術語
*斜體* - 強調
`程式碼` - 變數、方法名稱

> 💡 **提示**: 有用的建議
> ⚠️ **警告**: 需要注意的事項
> ✅ **推薦**: 最佳實踐
> ❌ **避免**: 不建議的做法
```

### 清單

```markdown
- 無序清單項目 1
- 無序清單項目 2

1. 有序清單項目 1
2. 有序清單項目 2

- [ ] 待辦事項 1
- [x] 已完成事項 2
```

## 🔍 品質檢查清單

建立新技能後，請確認：

- [ ] YAML frontmatter 格式正確
- [ ] `name` 使用小寫與連字號（符合 URL 友善格式）
- [ ] `description` 清晰且簡潔（少於 100 字）
- [ ] `tags` 包含相關關鍵字
- [ ] 至少包含一個具體的程式碼範例
- [ ] 所有程式碼區塊指定語言（語法高亮）
- [ ] 正體中文內容無錯別字
- [ ] 連結可正常存取（內部連結使用相對路徑）
- [ ] 在 `AGENTS.md` 新增此技能的連結

## 📦 整合到專案

### 1. 更新 AGENTS.md

在 `AGENTS.md` 的技能清單新增項目：

```markdown
## 🛠️ 技能清單 (Skills)

### 核心技能
- [Your Skill Name](skills/your-skill-name/SKILL.md) - 技能簡短描述
```

### 2. 標記為範本倉庫（可選）

如果此倉庫是模板倉庫，確保 GitHub 設定中啟用「Template repository」選項。

### 3. 測試技能

在支援的平台測試技能是否正常工作：

```bash
# GitHub Copilot
@workspace 使用 your-skill-name 技能完成任務

# Claude Desktop（需設定 MCP）
請使用 your-skill-name 技能協助我...
```

## 🌍 多語言支援

如果需要支援多語言，可建立以下結構：

```
skills/your-skill-name/
├── SKILL.md          # 預設語言（正體中文）
├── SKILL.en.md       # 英文版本
├── SKILL.ja.md       # 日文版本
└── examples/         # 共用範例程式碼
    └── sample.cs
```

## 📄 授權聲明

根據專案需求，可在技能檔案末尾加入授權資訊：

```markdown
---

**授權**: MIT License  
**維護者**: Your Name <email@example.com>  
**最後更新**: 2026-02-11
```

## 🚀 發佈技能

### 分享到社群

1. 提交 Pull Request 到 [awesome-agent-skills](https://github.com/heilcheng/awesome-agent-skills)
2. 在 [agentskills](https://github.com/agentskills) 組織註冊技能
3. 分享到 [skillhub.club](https://www.skillhub.club/)

### 版本管理

遵循語意化版本號 (Semantic Versioning)：

- `1.0.0` - 首次發佈
- `1.1.0` - 新增功能（向後相容）
- `1.0.1` - 錯誤修復
- `2.0.0` - 重大變更（不向後相容）

## 🤝 貢獻指南

歡迎社群貢獻！請：

1. Fork 此倉庫
2. 建立功能分支 (`git checkout -b feature/new-skill`)
3. 提交變更 (`git commit -m 'Add new skill: xxx'`)
4. 推送到分支 (`git push origin feature/new-skill`)
5. 開啟 Pull Request

## 📞 支援與回饋

如有問題或建議：

- 開啟 GitHub Issue
- 聯絡專案維護者
- 參考 [Agent Skills 官方標準](https://agentskills.io/)

---

**版本**: 1.0.0  
**最後更新**: 2026-02-11  
**維護者**: BlueWhale Development Team

# 🔧 GitHub Repository Rules 設定指南

## 📋 概述

GitHub Repository Rules 允許您在組織或倉庫層級強制執行代碼品質標準和結構要求。本指南說明如何使用此功能確保所有專案都包含標準化的 Agent Skills 結構。

## 🎯 目標

使用 Repository Rules 強制要求：
- ✅ 所有倉庫必須包含 `AGENTS.md`
- ✅ 必須有 `.github/agents/` 目錄與 Agent 定義
- ✅ 必須有 `skills/` 目錄與至少一個技能
- ✅ SKILL.md 必須包含有效的 YAML frontmatter

## 🚀 快速開始

### 方法 1: 使用自動化腳本（推薦）

```powershell
# 1. 進入模板倉庫目錄
cd agent-skills-template

# 2. 執行設定腳本
.\scripts\setup-repo-rules.ps1 -OrgName "bedev50972253" -Scope "organization" -Enforcement "active"
```

### 方法 2: 手動使用 GitHub CLI

```bash
# 1. 確認 GitHub CLI 已安裝並登入
gh auth status

# 2. 建立組織層級 Repository Ruleset
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /orgs/YOUR_ORG/rulesets \
  -f name='Agent Skills Required' \
  -f target='branch' \
  -f enforcement='active' \
  -f conditions[ref_name][include][]=refs/heads/main \
  -f conditions[ref_name][include][]=refs/heads/master \
  -F rules='[
    {
      "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [
          {
            "context": "agent-skills/validate-structure"
          }
        ],
        "strict_required_status_checks_policy": true
      }
    },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true
      }
    }
  ]'
```

### 方法 3: 使用 GitHub Web UI

1. **進入組織設定**
   - 前往 `https://github.com/organizations/YOUR_ORG/settings/rules`

2. **建立新 Ruleset**
   - 點擊 "New ruleset" → "New branch ruleset"
   - 名稱: `Agent Skills Required`

3. **設定目標分支**
   - Include: `main`, `master`
   - Enforcement status: `Active`

4. **新增規則**
   - ✅ Require status checks to pass
     - Add check: `agent-skills/validate-structure`
   - ✅ Require a pull request before merging
     - Required approvals: 1
   - ✅ Block force pushes

5. **儲存規則**

## 📦 必要步驟：建立驗證工作流程

Repository Rules 依賴 GitHub Actions 狀態檢查，需要建立驗證工作流程：

### 1. 複製驗證工作流程

```bash
# 從模板倉庫複製
cp agent-skills-template/.github/workflows/validate-agent-skills.yml \
   YOUR_PROJECT/.github/workflows/
```

### 2. 或手動建立

在您的專案中建立 `.github/workflows/validate-agent-skills.yml`:

```yaml
name: Validate Agent Skills Structure

on:
  pull_request:
    branches: [main, master]
  push:
    branches: [main, master]

jobs:
  validate:
    runs-on: ubuntu-latest
    name: agent-skills/validate-structure
    steps:
      - uses: actions/checkout@v4
      
      - name: 檢查 AGENTS.md
        run: |
          if [ ! -f "AGENTS.md" ]; then
            echo "❌ 缺少 AGENTS.md"
            exit 1
          fi
          echo "✅ AGENTS.md 存在"
      
      - name: 檢查 .github/agents/
        run: |
          if [ ! -d ".github/agents" ]; then
            echo "❌ 缺少 .github/agents/ 目錄"
            exit 1
          fi
          agent_count=$(find .github/agents -name "*.agent.md" | wc -l)
          if [ $agent_count -eq 0 ]; then
            echo "❌ 需要至少一個 .agent.md 檔案"
            exit 1
          fi
          echo "✅ 找到 $agent_count 個 Agent"
      
      - name: 檢查 skills/
        run: |
          if [ ! -d "skills" ]; then
            echo "❌ 缺少 skills/ 目錄"
            exit 1
          fi
          skill_count=$(find skills -name "SKILL.md" | wc -l)
          if [ $skill_count -eq 0 ]; then
            echo "❌ 需要至少一個 SKILL.md"
            exit 1
          fi
          echo "✅ 找到 $skill_count 個技能"
```

### 3. 提交工作流程

```bash
git add .github/workflows/validate-agent-skills.yml
git commit -m "feat: 新增 Agent Skills 結構驗證"
git push
```

## 🔍 驗證規則是否生效

### 測試 1: 建立不符合規則的 Pull Request

```bash
# 1. 建立新分支
git checkout -b test-without-agents

# 2. 移除 AGENTS.md（故意違反規則）
git rm AGENTS.md
git commit -m "test: 移除 AGENTS.md"

# 3. 推送並建立 PR
git push origin test-without-agents
gh pr create --title "測試: 不包含 AGENTS.md"
```

**預期結果**:
- ❌ PR 狀態檢查失敗
- ❌ 無法合併到 main
- 📝 顯示錯誤: "Required status check 'agent-skills/validate-structure' is failing"

### 測試 2: 建立符合規則的 Pull Request

```bash
# 1. 還原 AGENTS.md
git checkout main -- AGENTS.md
git commit -m "fix: 還原 AGENTS.md"
git push

# 2. 查看 PR 狀態
gh pr view
```

**預期結果**:
- ✅ 所有狀態檢查通過
- ✅ 可以合併

## ⚙️ 進階設定

### 1. 自訂驗證規則

編輯 `.github/workflows/validate-agent-skills.yml` 新增更多檢查:

```yaml
- name: 檢查必要的 Agent 檔案
  run: |
    required_agents=(
      "backend.agent.md"
      "frontend.agent.md"
      "database.agent.md"
    )
    
    for agent in "${required_agents[@]}"; do
      if [ ! -f ".github/agents/$agent" ]; then
        echo "❌ 缺少必要的 Agent: $agent"
        exit 1
      fi
    done
```

### 2. 驗證 YAML Frontmatter

```yaml
- name: 驗證 SKILL.md YAML
  run: |
    # 安裝 yq
    sudo wget -qO /usr/local/bin/yq \
      https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    sudo chmod +x /usr/local/bin/yq
    
    # 驗證每個 SKILL.md
    for skill in $(find skills -name "SKILL.md"); do
      yaml=$(sed -n '/^---$/,/^---$/p' "$skill" | sed '1d;$d')
      
      # 檢查必要欄位
      echo "$yaml" | yq eval '.name' - > /dev/null || exit 1
      echo "$yaml" | yq eval '.description' - > /dev/null || exit 1
      echo "$yaml" | yq eval '.version' - > /dev/null || exit 1
    done
```

### 3. 設定不同的執行模式

```bash
# Evaluate 模式（僅警告，不阻擋）
.\scripts\setup-repo-rules.ps1 -Enforcement "evaluate"

# Active 模式（強制執行）
.\scripts\setup-repo-rules.ps1 -Enforcement "active"

# Disabled 模式（停用）
.\scripts\setup-repo-rules.ps1 -Enforcement "disabled"
```

## 📊 管理現有規則

### 查看所有 Rulesets

```bash
# 組織層級
gh api /orgs/YOUR_ORG/rulesets | jq '.[] | {id, name, enforcement}'

# 倉庫層級
gh api /repos/YOUR_ORG/YOUR_REPO/rulesets | jq '.[] | {id, name, enforcement}'
```

### 更新 Ruleset

```bash
# 取得 Ruleset ID
RULESET_ID=$(gh api /orgs/YOUR_ORG/rulesets | jq '.[] | select(.name=="Agent Skills Required") | .id')

# 更新規則
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  /orgs/YOUR_ORG/rulesets/$RULESET_ID \
  -f enforcement='evaluate'
```

### 刪除 Ruleset

```bash
gh api \
  --method DELETE \
  -H "Accept: application/vnd.github+json" \
  /orgs/YOUR_ORG/rulesets/$RULESET_ID
```

## 🎓 最佳實踐

### 1. 分階段推行

```
第 1 週: Evaluate 模式（僅警告）
  ↓ 觀察團隊適應狀況
第 2-3 週: Active 模式 + 例外清單
  ↓ 逐步收緊例外
第 4 週: 完全強制執行
```

### 2. 設定例外（Bypass）

允許特定角色繞過規則:

```json
{
  "bypass_actors": [
    {
      "actor_id": 5,
      "actor_type": "RepositoryRole",
      "bypass_mode": "always"
    }
  ]
}
```

Actor Types:
- `RepositoryRole`: 倉庫角色（ID: 5 = Admin）
- `Team`: 團隊
- `Application`: GitHub App

### 3. 文檔與溝通

在 `CONTRIBUTING.md` 說明規則:

```markdown
## Agent Skills 結構要求

本專案使用 Agent Skills 標準化結構。所有 Pull Request 必須包含：

- ✅ `AGENTS.md` - Agent 總覽
- ✅ `.github/agents/*.agent.md` - Agent 定義
- ✅ `skills/*/SKILL.md` - 技能定義

參考模板: https://github.com/bedev50972253/agent-skills-template
```

## 🚨 疑難排解

### 問題 1: 權限不足

```
Error: Must have admin rights to Repository
```

**解決方案**:
- 確認您是 Organization Owner 或 Repository Admin
- 檢查 Personal Access Token 權限包含 `admin:org`

### 問題 2: API 版本不支援

```
Error: Resource not found
```

**解決方案**:
- 確認 Organization 已啟用 Repository Rules（需要 GitHub Enterprise 或 Team 方案）
- 更新 GitHub CLI: `gh upgrade`

### 問題 3: 狀態檢查未執行

```
Required status check 'agent-skills/validate-structure' is expected but not found
```

**解決方案**:
1. 確認 `.github/workflows/validate-agent-skills.yml` 存在
2. 確認 job name 正確: `name: agent-skills/validate-structure`
3. 手動觸發工作流程測試: `gh workflow run validate-agent-skills.yml`

## 📚 參考資源

### 官方文件
- [GitHub Repository Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub Actions: Required Status Checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks)

### 相關工具
- [yq - YAML 處理工具](https://github.com/mikefarah/yq)
- [jq - JSON 處理工具](https://stedolan.github.io/jq/)

### Agent Skills 標準
- [agentskills.io](https://agentskills.io/)
- [模板倉庫](https://github.com/bedev50972253/agent-skills-template)

---

**版本**: 1.0.0  
**最後更新**: 2026-02-11  
**維護者**: BlueWhale Development Team

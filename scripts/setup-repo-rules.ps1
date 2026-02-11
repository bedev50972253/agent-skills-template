<#
.SYNOPSIS
設定 GitHub Repository Rules，要求所有倉庫包含 Agent Skills 結構

.DESCRIPTION
此腳本使用 GitHub CLI 建立 Repository Ruleset，強制要求：
1. 必須包含 AGENTS.md
2. 必須包含 .github/agents/ 目錄
3. 必須包含至少一個 skills/ 技能

.PARAMETER OrgName
GitHub 組織名稱（選填，如為個人帳號則不需要）

.PARAMETER Scope
規則範圍: 'organization' 或 'repository'

.PARAMETER Enforcement
執行模式: 'active' (強制), 'evaluate' (僅評估), 'disabled' (停用)

.EXAMPLE
.\setup-repo-rules.ps1 -OrgName "bedev50972253" -Scope "organization" -Enforcement "active"

.EXAMPLE
.\setup-repo-rules.ps1 -Scope "repository" -Enforcement "evaluate"

.NOTES
需要安裝 GitHub CLI (gh) 並完成認證
權限要求: Organization Owner 或 Repository Admin
#>

param(
    [string]$OrgName = "",
    [ValidateSet("organization", "repository")]
    [string]$Scope = "repository",
    [ValidateSet("active", "evaluate", "disabled")]
    [string]$Enforcement = "active"
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 GitHub Repository Rules 設定工具" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# 檢查 GitHub CLI 是否已安裝
try {
    $ghVersion = gh version 2>&1
    Write-Host "✅ GitHub CLI 已安裝: $($ghVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "❌ 請先安裝 GitHub CLI: https://cli.github.com/" -ForegroundColor Red
    Write-Host "   執行: winget install --id GitHub.cli" -ForegroundColor Yellow
    exit 1
}

# 檢查認證狀態
try {
    $authStatus = gh auth status 2>&1
    Write-Host "✅ GitHub 認證成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 請先登入 GitHub CLI" -ForegroundColor Red
    Write-Host "   執行: gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 如果未提供組織名稱，使用當前使用者
if ([string]::IsNullOrEmpty($OrgName)) {
    $currentUser = gh api user --jq '.login'
    $OrgName = $currentUser
    Write-Host "📝 使用個人帳號: $OrgName" -ForegroundColor Yellow
} else {
    Write-Host "📝 使用組織: $OrgName" -ForegroundColor Yellow
}

Write-Host "📋 範圍: $Scope" -ForegroundColor Yellow
Write-Host "⚡ 執行模式: $Enforcement" -ForegroundColor Yellow
Write-Host ""

# 確認繼續
$confirm = Read-Host "是否繼續? (y/N)"
if ($confirm -ne 'y') {
    Write-Host "❌ 操作已取消" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "📦 建立 Repository Ruleset..." -ForegroundColor Cyan

# 準備 Ruleset JSON
$rulesetJson = @{
    name = "Agent Skills Required"
    target = "branch"
    enforcement = $Enforcement
    bypass_actors = @(
        @{
            actor_id = 5  # Repository administrators
            actor_type = "RepositoryRole"
            bypass_mode = "always"
        }
    )
    conditions = @{
        ref_name = @{
            include = @("refs/heads/main", "refs/heads/master")
            exclude = @()
        }
    }
    rules = @(
        # 規則 1: 必須包含 AGENTS.md
        @{
            type = "required_status_checks"
            parameters = @{
                required_status_checks = @(
                    @{
                        context = "agent-skills/validate-structure"
                        integration_id = $null
                    }
                )
                strict_required_status_checks_policy = $true
            }
        },
        # 規則 2: Pull Request 必須通過審查
        @{
            type = "pull_request"
            parameters = @{
                required_approving_review_count = 1
                dismiss_stale_reviews_on_push = $true
                require_code_owner_review = $false
                require_last_push_approval = $false
                required_review_thread_resolution = $true
            }
        },
        # 規則 3: 禁止強制推送
        @{
            type = "deletion"
        },
        @{
            type = "non_fast_forward"
        }
    )
} | ConvertTo-Json -Depth 10 -Compress

# 建立 Ruleset
try {
    if ($Scope -eq "organization") {
        # 組織層級 Ruleset
        Write-Host "🌍 建立組織層級 Ruleset..." -ForegroundColor Yellow
        
        $result = gh api `
            --method POST `
            -H "Accept: application/vnd.github+json" `
            -H "X-GitHub-Api-Version: 2022-11-28" `
            "/orgs/$OrgName/rulesets" `
            --input - <<< $rulesetJson
        
        Write-Host "✅ 組織 Ruleset 建立成功!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📊 規則詳情:" -ForegroundColor Cyan
        Write-Host "   名稱: Agent Skills Required"
        Write-Host "   組織: $OrgName"
        Write-Host "   範圍: 所有倉庫的 main/master 分支"
        Write-Host "   執行: $Enforcement"
        
    } else {
        # 倉庫層級 Ruleset（需要指定倉庫）
        Write-Host "📁 倉庫層級 Ruleset 需要指定倉庫名稱" -ForegroundColor Yellow
        $repoName = Read-Host "請輸入倉庫名稱（例如: my-project）"
        
        if ([string]::IsNullOrEmpty($repoName)) {
            Write-Host "❌ 倉庫名稱不可為空" -ForegroundColor Red
            exit 1
        }
        
        $result = gh api `
            --method POST `
            -H "Accept: application/vnd.github+json" `
            -H "X-GitHub-Api-Version: 2022-11-28" `
            "/repos/$OrgName/$repoName/rulesets" `
            --input - <<< $rulesetJson
        
        Write-Host "✅ 倉庫 Ruleset 建立成功!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📊 規則詳情:" -ForegroundColor Cyan
        Write-Host "   名稱: Agent Skills Required"
        Write-Host "   倉庫: $OrgName/$repoName"
        Write-Host "   分支: main/master"
        Write-Host "   執行: $Enforcement"
    }
    
} catch {
    Write-Host "❌ 建立 Ruleset 失敗" -ForegroundColor Red
    Write-Host "錯誤訊息: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能原因:" -ForegroundColor Yellow
    Write-Host "  1. 權限不足（需要 Organization Owner 或 Repository Admin）" -ForegroundColor Yellow
    Write-Host "  2. Organization 未啟用 Repository Rules 功能" -ForegroundColor Yellow
    Write-Host "  3. API Token 權限不足" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🎯 下一步:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1️⃣  建立 GitHub Actions 驗證工作流程" -ForegroundColor White
Write-Host "   將以下內容加入 .github/workflows/validate-agent-skills.yml:" -ForegroundColor Gray
Write-Host ""

$workflowContent = @"
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
          echo "✅ .github/agents/ 目錄存在"
      
      - name: 檢查 skills/
        run: |
          if [ ! -d "skills" ]; then
            echo "❌ 缺少 skills/ 目錄"
            exit 1
          fi
          
          skill_count=\$(find skills -name "SKILL.md" | wc -l)
          if [ \$skill_count -eq 0 ]; then
            echo "❌ skills/ 目錄中至少需要一個 SKILL.md"
            exit 1
          fi
          echo "✅ 找到 \$skill_count 個技能"
      
      - name: 驗證 YAML Frontmatter
        run: |
          # 安裝 yq (YAML 處理工具)
          sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
          sudo chmod +x /usr/local/bin/yq
          
          # 驗證所有 SKILL.md 的 YAML
          for skill in \$(find skills -name "SKILL.md"); do
            echo "檢查: \$skill"
            
            # 提取 YAML frontmatter
            yaml_content=\$(sed -n '/^---$/,/^---$/p' "\$skill" | sed '1d;\$d')
            
            if [ -z "\$yaml_content" ]; then
              echo "❌ \$skill 缺少 YAML frontmatter"
              exit 1
            fi
            
            # 驗證必要欄位
            echo "\$yaml_content" | yq eval '.name' - > /dev/null || {
              echo "❌ \$skill 缺少 'name' 欄位"
              exit 1
            }
            
            echo "✅ \$skill YAML 格式正確"
          done
      
      - name: 驗證通過
        run: |
          echo "🎉 Agent Skills 結構驗證通過!"
"@

Write-Host $workflowContent -ForegroundColor Gray

Write-Host ""
Write-Host "2️⃣  查看現有 Rulesets" -ForegroundColor White
if ($Scope -eq "organization") {
    Write-Host "   gh api /orgs/$OrgName/rulesets" -ForegroundColor Gray
} else {
    Write-Host "   gh api /repos/$OrgName/$repoName/rulesets" -ForegroundColor Gray
}

Write-Host ""
Write-Host "3️⃣  測試新專案" -ForegroundColor White
Write-Host "   建立新倉庫並嘗試推送不含 AGENTS.md 的 commit，應該會被拒絕" -ForegroundColor Gray

Write-Host ""
Write-Host "4️⃣  管理 Ruleset（網頁介面）" -ForegroundColor White
if ($Scope -eq "organization") {
    Write-Host "   https://github.com/organizations/$OrgName/settings/rules" -ForegroundColor Gray
} else {
    Write-Host "   https://github.com/$OrgName/$repoName/settings/rules" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ 設定完成!" -ForegroundColor Green
Write-Host ""

# 儲存 workflow 檔案
$saveWorkflow = Read-Host "是否自動建立驗證工作流程檔案? (y/N)"
if ($saveWorkflow -eq 'y') {
    $workflowPath = ".github/workflows/validate-agent-skills.yml"
    
    # 建立目錄
    New-Item -ItemType Directory -Path ".github/workflows" -Force | Out-Null
    
    # 寫入檔案
    $workflowContent | Out-File -FilePath $workflowPath -Encoding UTF8
    
    Write-Host "✅ 已建立: $workflowPath" -ForegroundColor Green
    Write-Host "   請提交並推送此檔案到倉庫" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎊 所有操作完成!" -ForegroundColor Cyan

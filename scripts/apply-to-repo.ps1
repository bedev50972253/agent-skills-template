<#
.SYNOPSIS
將 Agent Skills 模板結構應用到指定倉庫。

.DESCRIPTION
此腳本會複製 AGENTS.md、.github/agents/、skills/ 等目錄到目標倉庫,
並保留目標倉庫的自訂內容。

.PARAMETER RepoPath
目標倉庫路徑（預設為當前目錄）

.PARAMETER Force
強制覆蓋現有檔案

.PARAMETER OnlySkills
僅複製 skills/ 目錄

.EXAMPLE
.\apply-to-repo.ps1 -RepoPath "C:\Projects\MyApp"

.EXAMPLE
.\apply-to-repo.ps1 -Force

.NOTES
作者: BlueWhale Development Team
版本: 1.0.0
#>

param(
    [string]$RepoPath = ".",
    [switch]$Force,
    [switch]$OnlySkills
)

$ErrorActionPreference = "Stop"

# 取得模板目錄（此腳本所在目錄的上層）
$TemplateDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TargetDir = Resolve-Path $RepoPath

Write-Host "🤖 Agent Skills 自動化部署" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "模板目錄: $TemplateDir"
Write-Host "目標目錄: $TargetDir"
Write-Host ""

# 檢查目標是否為 Git 倉庫
if (-not (Test-Path (Join-Path $TargetDir ".git"))) {
    $response = Read-Host "⚠️  目標目錄不是 Git 倉庫,是否繼續? (y/N)"
    if ($response -ne 'y') {
        Write-Host "❌ 操作已取消" -ForegroundColor Red
        exit 1
    }
}

# 定義要複製的項目
$ItemsToCopy = @()

if (-not $OnlySkills) {
    $ItemsToCopy += @{
        Source = "AGENTS.md"
        Target = "AGENTS.md"
        Type = "File"
    }
    $ItemsToCopy += @{
        Source = ".github/agents"
        Target = ".github/agents"
        Type = "Directory"
    }
    $ItemsToCopy += @{
        Source = ".github/prompts"
        Target = ".github/prompts"
        Type = "Directory"
    }
    $ItemsToCopy += @{
        Source = ".github/instructions"
        Target = ".github/instructions"
        Type = "Directory"
    }
}

$ItemsToCopy += @{
    Source = "skills"
    Target = "skills"
    Type = "Directory"
}

# 複製函式
function Copy-AgentSkillsItem {
    param(
        [string]$SourcePath,
        [string]$TargetPath,
        [string]$Type,
        [bool]$ForceOverwrite
    )

    $fullSource = Join-Path $TemplateDir $SourcePath
    $fullTarget = Join-Path $TargetDir $TargetPath

    if (-not (Test-Path $fullSource)) {
        Write-Host "⚠️  來源不存在: $SourcePath" -ForegroundColor Yellow
        return
    }

    # 檢查目標是否存在
    $exists = Test-Path $fullTarget

    if ($exists -and -not $ForceOverwrite) {
        $response = Read-Host "📁 $TargetPath 已存在,是否覆蓋? (y/N/s=skip)"
        if ($response -eq 's') {
            Write-Host "⏭️  跳過: $TargetPath" -ForegroundColor Gray
            return
        }
        if ($response -ne 'y') {
            Write-Host "⏭️  保留現有: $TargetPath" -ForegroundColor Gray
            return
        }
    }

    # 建立父目錄
    $parentDir = Split-Path -Parent $fullTarget
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # 複製
    if ($Type -eq "File") {
        Copy-Item -Path $fullSource -Destination $fullTarget -Force
        Write-Host "✅ 已複製檔案: $TargetPath" -ForegroundColor Green
    }
    elseif ($Type -eq "Directory") {
        if ($exists -and $ForceOverwrite) {
            Remove-Item -Path $fullTarget -Recurse -Force
        }
        Copy-Item -Path $fullSource -Destination $fullTarget -Recurse -Force
        Write-Host "✅ 已複製目錄: $TargetPath" -ForegroundColor Green
    }
}

# 執行複製
Write-Host "📦 開始複製 Agent Skills 結構..." -ForegroundColor Cyan
Write-Host ""

foreach ($item in $ItemsToCopy) {
    Copy-AgentSkillsItem `
        -SourcePath $item.Source `
        -TargetPath $item.Target `
        -Type $item.Type `
        -ForceOverwrite $Force
}

Write-Host ""
Write-Host "🎉 完成!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 下一步:" -ForegroundColor Cyan
Write-Host "  1. 檢查 $TargetDir 中的檔案"
Write-Host "  2. 根據專案需求修改 skills/ 中的技能"
Write-Host "  3. 提交變更: git add . && git commit -m 'feat: 新增 Agent Skills'"
Write-Host ""
Write-Host "📚 說明文件: $TargetDir\AGENTS.md" -ForegroundColor Cyan

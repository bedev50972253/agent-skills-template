# 🔒 安全開發生命週期 (SSLDLC) 檢查清單

## 概述

本檢查清單基於 Microsoft SDL、OWASP 與 NIST 標準，確保軟體開發的每個階段都考慮安全性。

---

## 🎯 需求階段 (Requirements Phase)

### 安全性需求定義

- [ ] **識別敏感資料**
  - 個人資料 (PII): 姓名、身分證號、電話、地址、電子郵件
  - 財務資料: 信用卡號、銀行帳號
  - 驗證資訊: 密碼、Token、API Key
  - 商業機密: 價格、供應商資訊

- [ ] **定義資料分類等級**
  - 公開 (Public)
  - 內部 (Internal)
  - 機密 (Confidential)
  - 高度機密 (Highly Confidential)

- [ ] **驗證與授權需求**
  - 需要多因子驗證 (MFA):  是 / 否
  - 角色型存取控制 (RBAC):  是 / 否
  - 單一登入 (SSO):  是 / 否
  - Session 有效期: ___ 分鐘

- [ ] **合規要求確認**
  - GDPR (歐盟一般資料保護規則)
  - PCI DSS (支付卡產業資料安全標準)
  - ISO 27001 (資訊安全管理)
  - 個資法 (台灣個人資料保護法)

- [ ] **第三方整合安全評估**
  - 列出所有第三方服務 / API
  - 查核供應商安全性與合規性
  - 定義資料傳輸協定 (HTTPS、VPN)

---

## 🏗️ 設計階段 (Design Phase)

### 威脅模型分析 (STRIDE)

使用 STRIDE 方法識別威脅：

| 威脅類型 | 說明 | 範例 | 緩解措施 |
|---------|------|------|---------|
| **S**poofing | 身份欺騙 | 假冒管理員 | JWT、OAuth、MFA |
| **T**ampering | 資料篡改 | 修改訂單金額 | 簽章驗證、完整性檢查 |
| **R**epudiation | 否認行為 | 否認交易 | 稽核日誌、數位簽章 |
| **I**nformation Disclosure | 資訊洩露 | 暴露 API Key | 加密、存取控制 |
| **D**enial of Service | 阻斷服務 | 惡意請求癱瘓系統 | Rate Limiting、WAF |
| **E**levation of Privilege | 權限提升 | 一般用戶取得管理員權限 | 最小權限原則、RBAC |

#### 檢查清單

- [ ] 完成 STRIDE 威脅模型分析
- [ ] 識別所有信任邊界 (Trust Boundaries)
- [ ] 定義資料流圖 (Data Flow Diagram)
- [ ] 記錄高風險威脅與緩解措施

### 架構安全設計

- [ ] **最小權限原則 (Principle of Least Privilege)**
  - 使用者僅被授予必要權限
  - 服務帳號限制最小資料庫權限

- [ ] **深度防禦 (Defense in Depth)**
  - 多層安全控制（網路、應用、資料）
  - 不依賴單一安全機制

- [ ] **安全預設 (Secure by Default)**
  - 預設關閉非必要功能
  - 預設啟用 HTTPS
  - 預設拒絕存取（White list 機制）

- [ ] **失敗安全 (Fail-Safe)**
  - 錯誤發生時降級為安全狀態
  - 不洩露敏感錯誤訊息

### 資料保護設計

- [ ] **傳輸中加密 (Encryption in Transit)**
  - 強制使用 HTTPS (TLS 1.2+)
  - API 通訊使用 TLS
  - 禁用 HTTP (自動重新導向)

- [ ] **靜態資料加密 (Encryption at Rest)**
  - 資料庫透明資料加密 (TDE)
  - 檔案儲存加密 (Azure Storage Encryption)
  - 備份資料加密

- [ ] **金鑰管理**
  - 使用 Azure Key Vault / AWS KMS
  - 定期輪替金鑰 (每 90 天)
  - 不將金鑰硬編碼於程式碼

- [ ] **敏感資料遮罩**
  - 日誌中遮罩信用卡號 (顯示後 4 碼)
  - UI 顯示部分資訊 (example@*****.com)

---

## 💻 開發階段 (Development Phase)

### 安全編碼實踐

#### 1. 輸入驗證

- [ ] **所有使用者輸入必須驗證**
  ```csharp
  // ✅ 白名單驗證
  if (!Regex.IsMatch(username, @"^[a-zA-Z0-9_]{3,20}$"))
      return BadRequest("使用者名稱格式錯誤");
  ```

- [ ] **長度限制**
  ```csharp
  [MaxLength(200)]
  public string ProductName { get; set; }
  ```

- [ ] **型別驗證**
  ```csharp
  if (!int.TryParse(input, out var productId))
      return BadRequest("產品 ID 必須為數字");
  ```

#### 2. 輸出編碼 (防 XSS)

- [ ] **HTML 編碼**
  ```csharp
  var safeOutput = HttpUtility.HtmlEncode(userInput);
  ```

- [ ] **JavaScript 編碼**
  ```typescript
  const sanitized = DOMPurify.sanitize(userInput);
  ```

- [ ] **URL 編碼**
  ```csharp
  var encoded = Uri.EscapeDataString(userInput);
  ```

#### 3. SQL Injection 防護

- [ ] **使用參數化查詢**
  ```csharp
  // ✅ 正確
  var sql = "SELECT * FROM Users WHERE Username = @Username";
  var user = await _dbConnection.QueryFirstOrDefaultAsync<User>(sql, new { Username = username });
  
  // ❌ 錯誤
  var sql = $"SELECT * FROM Users WHERE Username = '{username}'";
  ```

- [ ] **使用 ORM (EF Core)**
  ```csharp
  var user = await _context.Users
      .FirstOrDefaultAsync(u => u.Username == username);
  ```

#### 4. 驗證與授權

- [ ] **密碼雜湊**
  ```csharp
  // ✅ 使用 bcrypt 或 Argon2
  var hashedPassword = BCrypt.Net.BCrypt.HashPassword(password, workFactor: 12);
  ```

- [ ] **JWT Token 安全**
  ```csharp
  // ✅ 短效期 Access Token (15 分鐘)
  // ✅ 長效期 Refresh Token (7 天，存儲於資料庫)
  // ✅ 使用強金鑰 (至少 256 bits)
  ```

- [ ] **CORS 配置**
  ```csharp
  builder.Services.AddCors(options =>
  {
      options.AddPolicy("AllowSpecificOrigin",
          policy => policy
              .WithOrigins("https://yourdomain.com")
              .AllowedMethods("GET", "POST")
              .AllowCredentials());
  });
  ```

#### 5. 錯誤處理

- [ ] **不洩露敏感資訊**
  ```csharp
  // ✅ 正確
  return StatusCode(500, new { message = "伺服器發生錯誤，請稍後再試" });
  
  // ❌ 錯誤
  return StatusCode(500, new { message = ex.StackTrace });
  ```

- [ ] **記錄錯誤**
  ```csharp
  _logger.LogError(ex, "處理訂單 {OrderId} 時發生錯誤", orderId);
  ```

#### 6. Session 管理

- [ ] **安全 Cookie 設定**
  ```csharp
  options.Cookie.HttpOnly = true;   // 防止 JavaScript 存取
  options.Cookie.Secure = true;     // 僅透過 HTTPS 傳輸
  options.Cookie.SameSite = SameSiteMode.Strict;
  ```

- [ ] **Session 逾時**
  - Idle Timeout: 15 分鐘
  - Absolute Timeout: 8 小時

### 相依性管理

- [ ] **使用官方套件來源**
  - NuGet.org (官方)
  - npm registry (官方)

- [ ] **套件版本鎖定**
  ```json
  // package-lock.json
  // packages.lock.json
  ```

- [ ] **定期更新套件**
  ```bash
  dotnet list package --outdated
  npm audit
  ```

---

## 🧪 測試階段 (Testing Phase)

### 靜態應用程式安全測試 (SAST)

- [ ] **執行 SAST 工具**
  - SonarQube / SonarCloud
  - Checkmarx
  - Fortify

- [ ] **程式碼審查檢查項目**
  - 硬編碼密碼 / API Key
  - SQL Injection 風險
  - XSS 漏洞
  - 不安全的密碼學使用
  - 不當錯誤處理

### 動態應用程式安全測試 (DAST)

- [ ] **執行 DAST 工具**
  - OWASP ZAP
  - Burp Suite
  - Acunetix

- [ ] **測試項目**
  - SQL Injection
  - Cross-Site Scripting (XSS)
  - CSRF (Cross-Site Request Forgery)
  - 不安全的反序列化
  - XML External Entity (XXE)
  - 安全性錯誤配置

### 相依性掃描

- [ ] **掃描已知漏洞**
  ```bash
  # .NET
  dotnet list package --vulnerable
  
  # Node.js
  npm audit
  
  # 使用工具
  # Snyk, WhiteSource, GitHub Dependabot
  ```

- [ ] **檢視掃描報告並修復高風險漏洞**

### 滲透測試

- [ ] **委外專業團隊進行滲透測試**
  - 範圍定義
  - 測試授權書
  - 測試報告檢視
  - 漏洞修補追蹤

---

## 🚀 部署階段 (Deployment Phase)

### 部署前檢查

- [ ] **移除測試用帳號與資料**
  - 刪除預設管理員帳號
  - 移除 Seed Data（生產環境）

- [ ] **環境變數配置**
  - 使用 Azure Key Vault
  - 不在 appsettings.json 儲存敏感資訊

- [ ] **安全配置驗證**
  ```xml
  <!-- ✅ 生產環境關閉詳細錯誤 -->
  <customErrors mode="On" />
  ```

  ```json
  // ✅ 關閉 Swagger (生產環境)
  if (app.Environment.IsDevelopment())
  {
      app.UseSwagger();
  }
  ```

- [ ] **HTTPS 強制啟用**
  ```csharp
  app.UseHttpsRedirection();
  app.UseHsts();
  ```

### 基礎設施安全

- [ ] **網路安全**
  - 私有子網路 (Private Subnet)
  - 網路安全群組 (NSG) 最小開放
  - Web Application Firewall (WAF)

- [ ] **存取控制**
  - Managed Identity (避免密碼)
  - 最小權限 IAM 角色
  - Just-In-Time (JIT) 存取

- [ ] **監控與警報**
  - Application Insights 啟用
  - Azure Defender / Microsoft Defender for Cloud
  - 異常登入警報
  - 高 CPU / 記憶體警報

### 日誌與稽核

- [ ] **啟用稽核日誌**
  - 登入 / 登出事件
 - 權限變更
  - 敏感資料存取
  - API 呼叫記錄

- [ ] **日誌保護**
  - 不記錄密碼、Token、信用卡號
  - 日誌集中儲存 (Log Analytics)
  - 日誌保留期: 至少 90 天

---

## 🔧 維運階段 (Operations Phase)

### 定期安全維護

- [ ] **安全更新排程**
  - 每月第二個星期二 (Patch Tuesday)
  - 關鍵漏洞: 24 小時內修補

- [ ] **漏洞修補流程**
  1. 識別漏洞 (CVE 編號)
  2. 評估影響範圍
  3. 測試修補程式
  4. 部署到生產環境
  5. 驗證修補成功

- [ ] **安全審計**
  - 每季進行存取權限審查
  - 每半年進行安全配置審查
  - 每年進行第三方安全稽核

### 事件應變計畫

- [ ] **安全事件應變流程**
  1. **偵測**: 監控系統發現異常
  2. **通報**: 通知安全團隊與管理層
  3. **隔離**: 隔離受影響系統
  4. **調查**: 分析攻擊向量與影響範圍
  5. **修復**: 修補漏洞並還原服務
  6. **檢討**: 事後分析與流程改善

- [ ] **緊急聯絡清單**
  - 安全團隊聯絡人
  - 資深開發者
  - 系統管理員
  - 法務顧問

---

## 📊 OWASP Top 10 (2021) 檢查清單

| 序號 | 漏洞類型 | 檢查項目 | 狀態 |
|-----|---------|---------|-----|
| A01 | Broken Access Control | 實作 RBAC，驗證所有 API 端點 | ☐ |
| A02 | Cryptographic Failures | 使用 TLS 1.2+，敏感資料加密 | ☐ |
| A03 | Injection | 參數化查詢，輸入驗證 | ☐ |
| A04 | Insecure Design | 威脅模型分析，安全架構設計 | ☐ |
| A05 | Security Misconfiguration | 關閉預設帳號，移除不必要功能 | ☐ |
| A06 | Vulnerable Components | 定期更新套件，掃描漏洞 | ☐ |
| A07 | Identification/Authentication Failures | MFA、強密碼政策、JWT 安全 | ☐ |
| A08 | Software/Data Integrity Failures | 驗證軟體更新簽章、CI/CD 安全 | ☐ |
| A09 | Security Logging Failures | 啟用稽核日誌、監控異常行為 | ☐ |
| A10 | Server-Side Request Forgery (SSRF) | 驗證 URL 白名單、禁止內部 IP | ☐ |

---

## ✅ 簽核

### 需求階段簽核

- [ ] 安全需求已定義並經審核  
- [ ] 合規要求已確認  
- **簽核人**: _____________  **日期**: ___________

### 設計階段簽核

- [ ] 威脅模型已完成  
- [ ] 架構安全審查通過  
- **簽核人**: _____________  **日期**: ___________

### 開發階段簽核

- [ ] 安全編碼標準已遵循  
- [ ] Code Review 完成  
- **簽核人**: _____________  **日期**: ___________

### 測試階段簽核

- [ ] SAST/DAST 掃描完成  
- [ ] 高風險漏洞已修復  
- **簽核人**: _____________  **日期**: ___________

### 部署階段簽核

- [ ] 安全配置檢查完成  
- [ ] 生產環境就緒  
- **簽核人**: _____________  **日期**: ___________

---

**版本**: 1.0.0  
**最後更新**: 2026-02-11  
**維護者**: BlueWhale Development Team  
**參考標準**: Microsoft SDL, OWASP Top 10 2021, NIST Cybersecurity Framework

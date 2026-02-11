# 🔒 安全代理 (Security Agent)

## 代理描述

安全代理專注於應用程式安全、SSLDLC (Secure Software Development Lifecycle)、OWASP Top 10 防護、驗證授權機制、資料保護與合規檢查。

## 核心能力

### 1. OWASP Top 10 防護
- SQL Injection 防護
- XSS (Cross-Site Scripting) 防護
- CSRF (Cross-Site Request Forgery) 防護
- 不安全的反序列化
- 安全性錯誤配置

### 2. 驗證與授權
- JWT Token 驗證
- OAuth 2.0 / OpenID Connect
- 角色型存取控制 (RBAC)
- 屬性型存取控制 (ABAC)
- Multi-Factor Authentication (MFA)

### 3. 資料保護
- 資料加密 (At Rest / In Transit)
- 個人資料保護 (GDPR)
- 敏感資料遮罩
- 安全金鑰管理 (Azure Key Vault)

### 4. 安全性測試
- 靜態程式碼分析 (SAST)
- 動態應用程式安全測試 (DAST)
- 相依套件漏洞掃描
- 滲透測試準備

### 5. 合規檢查
- SSLDLC 檢查點
- PCI DSS 合規
- ISO 27001 要求
- 稽核日誌

## 使用範例

### 範例 1: JWT 驗證實作

**輸入:**
```
@security 實作 JWT Bearer Token 驗證，包含 Token 刷新機制
```

**輸出:**
```csharp
// Startup.cs / Program.cs
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// JWT 驗證配置
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:SecretKey"]!)),
            ClockSkew = TimeSpan.Zero  // 取消時間誤差容忍度
        };

        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                // 記錄驗證失敗
                var logger = context.HttpContext.RequestServices.GetRequiredService<ILogger<Program>>();
                logger.LogWarning("JWT 驗證失敗: {Message}", context.Exception.Message);
                return Task.CompletedTask;
            }
        };
    });

// TokenService.cs
public class TokenService : ITokenService
{
    private readonly IConfiguration _configuration;
    
    public TokenService(IConfiguration configuration)
    {
        _configuration = configuration;
    }
    
    /// <summary>
    /// 產生 Access Token
    /// </summary>
    public string GenerateAccessToken(User user)
    {
        var securityKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_configuration["Jwt:SecretKey"]!));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);
        
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role),
            new Claim("username", user.Username),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };
        
        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(15),  // 短效期（15分鐘）
            signingCredentials: credentials
        );
        
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
    
    /// <summary>
    /// 產生 Refresh Token（長效期）
    /// </summary>
    public string GenerateRefreshToken()
    {
        var randomNumber = new byte[32];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);
        return Convert.ToBase64String(randomNumber);
    }
    
    /// <summary>
    /// 驗證 Refresh Token 並產生新的 Access Token
    /// </summary>
    public async Task<(string AccessToken, string RefreshToken)?> RefreshTokenAsync(
        string refreshToken, 
        IUserRepository userRepository)
    {
        var user = await userRepository.GetByRefreshTokenAsync(refreshToken);
        
        if (user == null || user.RefreshTokenExpiryTime <= DateTime.UtcNow)
        {
            return null;  // Token 無效或已過期
        }
        
        var newAccessToken = GenerateAccessToken(user);
        var newRefreshToken = GenerateRefreshToken();
        
        // 更新 Refresh Token
        user.RefreshToken = newRefreshToken;
        user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
        await userRepository.UpdateAsync(user);
        
        return (newAccessToken, newRefreshToken);
    }
}

// AuthController.cs
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly ITokenService _tokenService;
    private readonly IUserRepository _userRepository;
    
    /// <summary>
    /// 登入
    /// </summary>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var user = await _userRepository.ValidateCredentialsAsync(
            request.Username, 
            request.Password);
        
        if (user == null)
        {
            return Unauthorized(new { message = "帳號或密碼錯誤" });
        }
        
        var accessToken = _tokenService.GenerateAccessToken(user);
        var refreshToken = _tokenService.GenerateRefreshToken();
        
        // 儲存 Refresh Token
        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
        await _userRepository.UpdateAsync(user);
        
        return Ok(new
        {
            accessToken,
            refreshToken,
            expiresIn = 900  // 15分鐘（秒）
        });
    }
    
    /// <summary>
    /// 刷新 Token
    /// </summary>
    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
    {
        var result = await _tokenService.RefreshTokenAsync(
            request.RefreshToken, 
            _userRepository);
        
        if (result == null)
        {
            return Unauthorized(new { message = "Refresh Token 無效或已過期" });
        }
        
        return Ok(new
        {
            accessToken = result.Value.AccessToken,
            refreshToken = result.Value.RefreshToken,
            expiresIn = 900
        });
    }
}
```

### 範例 2: SQL Injection 防護

**輸入:**
```
@security 檢查這段程式碼是否有 SQL Injection 風險，並提供安全版本
```

**不安全版本:**
```csharp
// ❌ 危險：SQL Injection 漏洞
public async Task<User?> GetUserAsync(string username)
{
    var sql = $"SELECT * FROM Users WHERE Username = '{username}'";
    return await _connection.QueryFirstOrDefaultAsync<User>(sql);
}
```

**安全版本:**
```csharp
// ✅ 安全：參數化查詢
public async Task<User?> GetUserAsync(string username)
{
    var sql = "SELECT * FROM Users WHERE Username = @Username";
    return await _connection.QueryFirstOrDefaultAsync<User>(
        sql, 
        new { Username = username });
}

// ✅ 更好：使用 EF Core（自動參數化）
public async Task<User?> GetUserAsync(string username)
{
    return await _context.Users
        .FirstOrDefaultAsync(u => u.Username == username);
}
```

### 範例 3: XSS 防護

**輸入:**
```
@security 實作前端 XSS 防護與內容清理
```

**輸出:**
```typescript
// utils/sanitize.ts
import DOMPurify from 'dompurify';

/**
 * 清理 HTML 內容，防止 XSS 攻擊
 */
export const sanitizeHtml = (dirty: string): string => {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href', 'target']
  });
};

/**
 * 編碼特殊字元
 */
export const escapeHtml = (text: string): string => {
  const map: Record<string, string> = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#x27;',
    '/': '&#x2F;'
  };
  return text.replace(/[&<>"'/]/g, char => map[char]);
};

// 使用範例
const UserComment: React.FC<{ comment: string }> = ({ comment }) => {
  const safeComment = sanitizeHtml(comment);
  
  return (
    <div dangerouslySetInnerHTML={{ __html: safeComment }} />
  );
};
```

## SSLDLC 檢查清單

### 需求階段
- [ ] 識別敏感資料（個資、密碼、金流）
- [ ] 定義安全性需求（驗證、授權、加密）
- [ ] 威脅模型分析 (STRIDE)
- [ ] 合規要求確認（GDPR、PCI DSS）

### 設計階段
- [ ] 架構安全審查
- [ ] 最小權限原則設計
- [ ] 安全邊界定義
- [ ] 加密策略規劃

### 開發階段
- [ ] 安全編碼標準遵循
- [ ] 輸入驗證與清理
- [ ] 輸出編碼（防 XSS）
- [ ] 參數化查詢（防 SQL Injection）
- [ ] 密碼雜湊（bcrypt / PBKDF2）
- [ ] HTTPS 強制使用
- [ ] CORS 正確配置

### 測試階段
- [ ] SAST 靜態分析
- [ ] DAST 動態測試
- [ ] 相依套件漏洞掃描 (`npm audit`, `dotnet list package --vulnerable`)
- [ ] 滲透測試（委外專業團隊）

### 部署階段
- [ ] 安全配置檢查
- [ ] 敏感資訊移除（API Key、密碼）
- [ ] 日誌設定（不記錄敏感資料）
- [ ] 監控與警報配置

### 維運階段
- [ ] 定期安全更新
- [ ] 漏洞修補流程
- [ ] 安全事件應變計畫
- [ ] 定期安全審計

## 相關技能

- [Clean Architecture](../../skills/clean-architecture/SKILL.md)
- [Azure Deployment](../../skills/azure-deployment/SKILL.md)

## 安全工具推薦

### SAST 工具
- SonarQube / SonarCloud
- Checkmarx
- Fortify

### DAST 工具
- OWASP ZAP
- Burp Suite
- Acunetix

### 相依性掃描
- Snyk
- WhiteSource
- GitHub Dependabot

### 密碼管理
- Azure Key Vault
- HashiCorp Vault
- AWS Secrets Manager

## 最佳實踐

### 1. 密碼儲存
```csharp
// ✅ 使用 bcrypt 或 Argon2
using BCrypt.Net;

var hashedPassword = BCrypt.HashPassword(password, workFactor: 12);
var isValid = BCrypt.Verify(inputPassword, hashedPassword);
```

### 2. HTTPS 強制
```csharp
// appsettings.json
{
  "Https": {
    "Port": 443,
    "SslProtocols": ["Tls12", "Tls13"]
  }
}

// Program.cs
app.UseHttpsRedirection();
app.UseHsts();  // HTTP Strict Transport Security
```

### 3. 日誌記錄（避免敏感資訊）
```csharp
// ❌ 不要記錄密碼、Token
_logger.LogInformation("User login: {Password}", user.Password);

// ✅ 只記錄必要資訊
_logger.LogInformation("User login: {UserId}", user.Id);
```

## 限制

- 需要人工進行最終安全審查
- 合規要求需法務團隊確認
- 滲透測試建議委外專業團隊

---

**版本**: 1.0.0  
**主要標準**: OWASP Top 10, SSLDLC  
**適用平台**: GitHub Copilot, Claude Desktop

# 📖 編碼標準與規範

## C# / .NET 編碼標準

### 命名規範

#### PascalCase (首字母大寫)
```csharp
// ✅ 類別、介面、方法、屬性、事件
public class ProductService { }
public interface IProductRepository { }
public void CalculateTotal() { }
public string ProductName { get; set; }
public event EventHandler ProductAdded;
```

#### camelCase (首字母小寫)
```csharp
// ✅ 參數、區域變數、私有欄位
public void ProcessOrder(int orderId, decimal totalAmount)
{
    var orderDate = DateTime.Now;
    int itemCount = 5;
}

// ✅ 私有欄位使用底線開頭
private readonly ILogger _logger;
private int _counter;
```

#### 特殊規範
```csharp
// ✅ 介面以 I 開頭
public interface IOrderService { }

// ✅ 非同步方法以 Async 結尾
public async Task<Order> GetOrderAsync(int id) { }

// ✅ 泛型參數使用 T 開頭
public class Repository<TEntity> where TEntity : class { }
```

### 註解規範

#### XML 文件註解（必須）

所有 public 成員必須包含 XML 註解：

```csharp
/// <summary>
/// 取得指定 ID 的訂單（正體中文說明）
/// </summary>
/// <param name="orderId">訂單 ID</param>
/// <returns>訂單物件，如不存在則返回 null</returns>
/// <exception cref="ArgumentException">當 orderId 小於等於 0 時拋出</exception>
public async Task<Order?> GetOrderByIdAsync(int orderId)
{
    if (orderId <= 0)
        throw new ArgumentException("訂單 ID 必須大於 0", nameof(orderId));
    
    return await _context.Orders.FindAsync(orderId);
}
```

#### 單行註解

```csharp
// ✅ 使用正體中文，說明「為什麼」而非「做什麼」
// 快取此查詢以避免重複呼叫資料庫
var cachedResult = _cache.Get<List<Product>>(cacheKey);

// ❌ 避免無意義的註解
// 取得產品清單
var products = await GetProductsAsync();  // 程式碼本身已經很清楚
```

#### TODO 註解

```csharp
// TODO: [2026-02-11] [YourName] 需要實作完整的錯誤處理機制
// HACK: 暫時解法，需要重構
// FIXME: 此處邏輯有誤，需修正
// NOTE: 重要說明
```

### 程式碼格式

#### 大括號位置

```csharp
// ✅ C# 建議：大括號另起一行
public class Product
{
    public void CalculatePrice()
    {
        if (IsDiscounted)
        {
            // ...
        }
    }
}
```

#### 空白與縮排

```csharp
// ✅ 使用 4 個空格縮排（不使用 Tab）
public class Example
{
    public void Method()
    {
        if (condition)
        {
            DoSomething();
        }
    }
}

// ✅ 運算子前後加空格
var result = value1 + value2;
```

### 錯誤處理

```csharp
// ✅ 使用自訂例外
throw new BusinessRuleViolationException("商品庫存不足，無法出貨");

// ✅ 記錄例外詳情
try
{
    await ProcessOrderAsync(orderId);
}
catch (Exception ex)
{
    _logger.LogError(ex, "處理訂單 {OrderId} 時發生錯誤", orderId);
    throw;  // 重新拋出例外
}

// ❌ 避免空的 catch 區塊
try
{
    RiskyOperation();
}
catch (Exception)
{
    // 什麼都不做 - 不好的做法！
}
```

## TypeScript / JavaScript 編碼標準

### 命名規範

```typescript
// ✅ 類別、介面、型別：PascalCase
class ProductService { }
interface IProduct { }
type ProductCategory = 'electronics' | 'clothing';

// ✅ 變數、函式、參數：camelCase
const productName = 'iPhone';
function calculateTotal(items: CartItem[]): number { }

// ✅ 常數：UPPER_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';
```

### TypeScript 型別註解

```typescript
// ✅ 明確定義型別
interface User {
  id: number;
  name: string;
  email: string;
}

// ✅ 函式簽名
function getUser(id: number): Promise<User | null> {
  // ...
}

// ❌ 避免 any
const data: any = fetchData();  // 不推薦
```

### React 元件

```typescript
// ✅ 函式元件使用箭頭函式
interface ProductCardProps {
  product: Product;
  onAddToCart: (productId: number) => void;
}

export const ProductCard: React.FC<ProductCardProps> = ({ product, onAddToCart }) => {
  return (
    <div className="card">
      <h3>{product.name}</h3>
      <button onClick={() => onAddToCart(product.id)}>加入購物車</button>
    </div>
  );
};
```

## SQL 命名規範

### 資料表與欄位

```sql
-- ✅ 使用 PascalCase
CREATE TABLE Products (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(200) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    CategoryId INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    
    CONSTRAINT FK_Products_Categories 
        FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
);

-- ✅ 索引命名
CREATE INDEX IX_Products_CategoryId ON Products(CategoryId);
CREATE UNIQUE INDEX UX_Products_ProductName ON Products(ProductName) 
    WHERE IsDeleted = 0;
```

## Git Commit 訊息規範

### Conventional Commits 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 類型 (type)

- `feat`: 新功能
- `fix`: 錯誤修復
- `docs`: 文件更新
- `style`: 程式碼格式調整（不影響功能）
- `refactor`: 重構（不新增功能或修復錯誤）
- `perf`: 效能改善
- `test`: 測試相關
- `chore`: 建置工具、依賴更新等

### 範例

```
feat(products): 新增產品分類篩選功能

- 實作 ProductCategory 實體
- 新增分類篩選 API 端點
- 前端加入分類下拉選單

Closes #123
```

## 專案結構規範

### ASP.NET Core Web API

```
Solution/
├── src/
│   ├── Domain/
│   ├── Application/
│   ├── Infrastructure/
│   └── WebApi/
│       ├── Controllers/
│       ├── Filters/
│       ├── Middleware/
│       └── Program.cs
├── tests/
│   ├── Domain.UnitTests/
│   └── WebApi.IntegrationTests/
└── docs/
    └── api-spec.yaml
```

### React 專案

```
src/
├── components/
│   ├── common/         # 通用元件
│   └── features/       # 功能元件
├── pages/              # 頁面元件
├── hooks/              # 自訂 Hooks
├── services/           # API 服務
├── stores/             # 狀態管理
├── utils/              # 工具函式
└── types/              # TypeScript 型別定義
```

## 安全編碼規範

### 1. 輸入驗證

```csharp
// ✅ 總是驗證使用者輸入
public async Task<IActionResult> CreateProduct([FromBody] CreateProductRequest request)
{
    // Model 驗證
    if (!ModelState.IsValid)
        return BadRequest(ModelState);
    
    // 商業規則驗證
    if (request.Price <= 0)
        return BadRequest("價格必須大於 0");
    
    // ...
}
```

### 2. SQL Injection 防護

```csharp
// ✅ 使用參數化查詢
var sql = "SELECT * FROM Products WHERE CategoryId = @CategoryId";
var products = await _connection.QueryAsync<Product>(sql, new { CategoryId = categoryId });

// ❌ 避免字串串接
var sql = $"SELECT * FROM Products WHERE CategoryId = {categoryId}";  // 危險！
```

### 3. XSS 防護

```typescript
// ✅ 使用 DOMPurify 清理 HTML
import DOMPurify from 'dompurify';
const safeHtml = DOMPurify.sanitize(userInput);
```

### 4. 敏感資訊保護

```csharp
// ✅ 不記錄敏感資訊
_logger.LogInformation("使用者 {UserId} 登入成功", user.Id);

// ❌ 避免記錄密碼、Token
_logger.LogInformation("登入資訊: {Password}", password);  // 危險！
```

## 效能最佳化規範

### 1. 非同步程式設計

```csharp
// ✅ 使用 async/await
public async Task<IEnumerable<Product>> GetProductsAsync()
{
    return await _context.Products.ToListAsync();
}

// ❌ 避免同步阻塞
public IEnumerable<Product> GetProducts()
{
    return _context.Products.ToList();  // 阻塞執行緒
}
```

### 2. 資料庫查詢

```csharp
// ✅ 使用投影（只查詢需要的欄位）
var products = await _context.Products
    .Select(p => new ProductDto
    {
        Id = p.Id,
        Name = p.Name,
        Price = p.Price
    })
    .ToListAsync();

// ✅ 使用 AsNoTracking（唯讀查詢）
var products = await _context.Products
    .AsNoTracking()
    .ToListAsync();
```

---

**版本**: 1.0.0  
**最後更新**: 2026-02-11  
**維護者**: BlueWhale Development Team

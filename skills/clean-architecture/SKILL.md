---
name: clean-architecture
description: 整潔架構 (Clean Architecture) 模式實作指南
version: 1.0.0
category: architecture
tags:
  - clean-architecture
  - ddd
  - solid
  - layered-architecture
  - dotnet
author: BlueWhale Development Team
platform:
  - github-copilot
  - claude-desktop
  - azure-ai-foundry
---

# Clean Architecture - 整潔架構實作

## 📋 技能描述

Clean Architecture（整潔架構）是由 Robert C. Martin (Uncle Bob) 提出的軟體架構模式，強調：

- **依賴反轉**: 內層不依賴外層,依賴方向永遠指向核心
- **關注點分離**: 每層有清晰的職責邊界
- **可測試性**: 商業邏輯獨立於框架、UI、資料庫
- **獨立性**: 核心邏輯不受外部變更影響

## 🎯 使用時機

當您需要：
- 建立長期維護的企業級應用
- 確保商業邏輯可獨立測試
- 支援多種 UI (Web, Mobile, Desktop)
- 未來可能更換資料庫或第三方服務
- 團隊協作需要清晰的程式碼結構

## 🧩 架構層次

### 1. Domain Layer (領域層) - 核心

```
Domain/
├── Entities/           # 實體（商業物件）
│   ├── Product.cs
│   └── Order.cs
├── ValueObjects/       # 值物件
│   ├── Money.cs
│   └── Address.cs
├── Enums/              # 列舉
│   └── OrderStatus.cs
├── Exceptions/         # 領域例外
│   └── InsufficientStockException.cs
└── Interfaces/         # 倉儲介面（抽象）
    └── IProductRepository.cs
```

**特性:**
- 零外部依賴
- 包含商業規則
- 框架無關

### 2. Application Layer (應用層)

```
Application/
├── Commands/           # CQRS 命令
│   └── CreateProduct/
│       ├── CreateProductCommand.cs
│       └── CreateProductCommandHandler.cs
├── Queries/            # CQRS 查詢
│   └── GetProducts/
│       ├── GetProductsQuery.cs
│       └── GetProductsQueryHandler.cs
├── DTOs/               # 資料傳輸物件
│   └── ProductDto.cs
├── Interfaces/         # 應用服務介面
│   └── IEmailService.cs
└── Validators/         # 驗證器
    └── CreateProductCommandValidator.cs
```

**特性:**
- 僅依賴 Domain 層
- 協調領域物件執行業務流程
- 使用 MediatR 實作 CQRS

### 3. Infrastructure Layer (基礎設施層)

```
Infrastructure/
├── Persistence/        # 資料持久化
│   ├── ApplicationDbContext.cs
│   ├── Repositories/
│   │   └── ProductRepository.cs
│   └── Configurations/
│       └── ProductConfiguration.cs
├── Services/           # 外部服務實作
│   ├── EmailService.cs
│   └── StorageService.cs
└── Extensions/         # DI 擴充方法
    └── ServiceCollectionExtensions.cs
```

**特性:**
- 實作 Domain 與 Application 定義的介面
- 包含 EF Core、第三方整合
- 可替換性高

### 4. Presentation Layer (展示層)

```
WebApi/                 # API 專案
├── Controllers/
│   └── ProductsController.cs
├── Filters/
│   └── ValidationFilter.cs
├── Middleware/
│   └── ExceptionHandlingMiddleware.cs
└── Program.cs

或

BlazorApp/              # Blazor 專案
WebMvc/                 # MVC 專案
```

**特性:**
- 僅依賴 Application 層
- 處理 HTTP、UI 相關邏輯
- 可同時存在多個展示層

## 💡 實作範例

### 範例 1: Domain 實體設計

```csharp
/// <summary>
/// 產品實體（Domain Entity）
/// </summary>
public class Product : BaseEntity
{
    // 私有建構子（強制使用工廠方法）
    private Product() { }
    
    public string Name { get; private set; } = string.Empty;
    public string Description { get; private set; } = string.Empty;
    public Money Price { get; private set; } = null!;
    public int Stock { get; private set; }
    public ProductCategory Category { get; private set; } = null!;
    
    /// <summary>
    /// 工廠方法（建立商品）
    /// </summary>
    public static Product Create(
        string name, 
        string description, 
        Money price, 
        int stock,
        ProductCategory category)
    {
        // 領域規則驗證
        if (string.IsNullOrWhiteSpace(name))
            throw new DomainException("商品名稱不可為空");
        
        if (price.Amount <= 0)
            throw new DomainException("商品價格必須大於0");
        
        return new Product
        {
            Name = name,
            Description = description,
            Price = price,
            Stock = stock,
            Category = category
        };
    }
    
    /// <summary>
    /// 領域方法（減少庫存）
    /// </summary>
    public void ReduceStock(int quantity)
    {
        if (quantity <= 0)
            throw new DomainException("扣除數量必須大於0");
        
        if (Stock < quantity)
            throw new InsufficientStockException(
                $"商品 {Name} 庫存不足，目前: {Stock}，需要: {quantity}");
        
        Stock -= quantity;
        
        // 領域事件
        AddDomainEvent(new StockReducedEvent(Id, quantity));
    }
}

/// <summary>
/// 值物件（Money）
/// </summary>
public class Money : ValueObject
{
    public decimal Amount { get; private set; }
    public string Currency { get; private set; } = "TWD";
    
    public Money(decimal amount, string currency = "TWD")
    {
        if (amount < 0)
            throw new DomainException("金額不可為負數");
        
        Amount = amount;
        Currency = currency;
    }
    
    protected override IEnumerable<object> GetEqualityComponents()
    {
        yield return Amount;
        yield return Currency;
    }
}
```

### 範例 2: Application 層 CQRS

```csharp
/// <summary>
/// 建立商品命令
/// </summary>
public record CreateProductCommand(
    string Name,
    string Description,
    decimal Price,
    int Stock,
    int CategoryId
) : IRequest<int>;

/// <summary>
/// 命令處理器
/// </summary>
public class CreateProductCommandHandler 
    : IRequestHandler<CreateProductCommand, int>
{
    private readonly IProductRepository _repository;
    private readonly IUnitOfWork _unitOfWork;
    
    public CreateProductCommandHandler(
        IProductRepository repository,
        IUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }
    
    public async Task<int> Handle(
        CreateProductCommand request, 
        CancellationToken cancellationToken)
    {
        // 建立領域物件
        var category = await _repository.GetCategoryByIdAsync(request.CategoryId);
        
        var product = Product.Create(
            request.Name,
            request.Description,
            new Money(request.Price),
            request.Stock,
            category);
        
        // 持久化
        await _repository.AddAsync(product);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        
        return product.Id;
    }
}

/// <summary>
/// FluentValidation 驗證器
/// </summary>
public class CreateProductCommandValidator 
    : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("商品名稱為必填")
            .MaximumLength(200);
        
        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("價格必須大於0");
        
        RuleFor(x => x.Stock)
            .GreaterThanOrEqualTo(0).WithMessage("庫存不可為負數");
    }
}
```

### 範例 3: Infrastructure 倉儲實作

```csharp
/// <summary>
/// 產品倉儲實作
/// </summary>
public class ProductRepository : IProductRepository
{
    private readonly ApplicationDbContext _context;
    
    public ProductRepository(ApplicationDbContext context)
    {
        _context = context;
    }
    
    public async Task<Product?> GetByIdAsync(int id)
    {
        return await _context.Products
            .Include(p => p.Category)
            .FirstOrDefaultAsync(p => p.Id == id);
    }
    
    public async Task<IEnumerable<Product>> GetAllAsync()
    {
        return await _context.Products
            .Include(p => p.Category)
            .OrderBy(p => p.Name)
            .ToListAsync();
    }
    
    public async Task AddAsync(Product product)
    {
        await _context.Products.AddAsync(product);
    }
    
    public void Update(Product product)
    {
        _context.Products.Update(product);
    }
    
    public void Delete(Product product)
    {
        _context.Products.Remove(product);
    }
}
```

### 範例 4: API 控制器

```csharp
/// <summary>
/// 產品 API 控制器
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IMediator _mediator;
    
    public ProductsController(IMediator mediator)
    {
        _mediator = mediator;
    }
    
    /// <summary>
    /// 建立新商品
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(int), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateProduct(
        [FromBody] CreateProductCommand command)
    {
        var productId = await _mediator.Send(command);
        
        return CreatedAtAction(
            nameof(GetProduct), 
            new { id = productId }, 
            productId);
    }
    
    /// <summary>
    /// 取得商品詳情
    /// </summary>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetProduct(int id)
    {
        var query = new GetProductByIdQuery(id);
        var product = await _mediator.Send(query);
        
        return product == null 
            ? NotFound() 
            : Ok(product);
    }
}
```

## ✅ 最佳實踐

### 1. 依賴方向

```
Presentation → Application → Domain ← Infrastructure
                                ↑
                        (Infrastructure 實作介面)
```

### 2. 專案結構

```
Solution/
├── src/
│   ├── Domain/                 # Class Library
│   ├── Application/            # Class Library
│   ├── Infrastructure/         # Class Library
│   └── WebApi/                 # ASP.NET Core Web API
├── tests/
│   ├── Domain.UnitTests/
│   ├── Application.UnitTests/
│   └── WebApi.IntegrationTests/
└── docs/
```

### 3. NuGet 套件建議

**Domain 層**: 無外部依賴  
**Application 層**:
- MediatR
- FluentValidation
- AutoMapper (可選)

**Infrastructure 層**:
- Microsoft.EntityFrameworkCore
- Microsoft.EntityFrameworkCore.SqlServer

**WebApi 層**:
- Swashbuckle.AspNetCore (Swagger)
- Serilog

### 4. 註冊服務 (Program.cs)

```csharp
// Application 層服務
builder.Services.AddMediatR(cfg => 
    cfg.RegisterServicesFromAssembly(typeof(CreateProductCommand).Assembly));
builder.Services.AddValidatorsFromAssembly(typeof(CreateProductCommand).Assembly);

// Infrastructure 層服務
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

// 自訂中介軟體
builder.Services.AddScoped(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
```

## ❌ 常見錯誤

### 錯誤 1: Domain 層依賴外部套件

```csharp
// ❌ 不可在 Domain 層使用 EF Core
public class Product : BaseEntity
{
    [Required]  // ← 這是 DataAnnotations，屬於框架依賴
    public string Name { get; set; }
}

// ✅ 正確：使用領域驗證
public class Product : BaseEntity
{
    private string _name = string.Empty;
    
    public string Name
    {
        get => _name;
        set
        {
            if (string.IsNullOrWhiteSpace(value))
                throw new DomainException("商品名稱不可為空");
            _name = value;
        }
    }
}
```

### 錯誤 2: 貧血領域模型

```csharp
// ❌ 貧血模型（只有屬性，沒有行為）
public class Order
{
    public int Id { get; set; }
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; }
}

// ✅ 豐富領域模型（包含商業邏輯）
public class Order
{
    private readonly List<OrderItem> _items = new();
    
    public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();
    public decimal TotalAmount { get; private set; }
    public OrderStatus Status { get; private set; }
    
    public void AddItem(Product product, int quantity)
    {
        if (Status != OrderStatus.Draft)
            throw new DomainException("只能修改草稿狀態的訂單");
        
        var item = new OrderItem(product, quantity);
        _items.Add(item);
        RecalculateTotal();
    }
    
    private void RecalculateTotal()
    {
        TotalAmount = _items.Sum(i => i.Subtotal);
    }
}
```

## 🔗 相關技能

- [CQRS + MediatR](../cqrs-mediatr/SKILL.md)
- [EF Core Migration](../efcore-migration/SKILL.md)
- [Azure Deployment](../azure-deployment/SKILL.md)

## 📚 參考資源

- [Clean Architecture (Robert C. Martin)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Microsoft - Clean Architecture Template](https://github.com/jasontaylordev/CleanArchitecture)
- [Ardalis - Clean Architecture](https://github.com/ardalis/CleanArchitecture)

---

**版本**: 1.0.0  
**最後更新**: 2026-02-11  
**維護者**: BlueWhale Development Team

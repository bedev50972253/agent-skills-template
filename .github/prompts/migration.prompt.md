# 📝 資料庫遷移提示範本

## 使用情境

當需要建立新的 EF Core Migration 時使用此提示。

## 提示範本

```
請協助建立 EF Core Migration:

**目的**: [說明此次遷移的目的，例如：新增產品分類功能]

**變更內容**:
- [ ] 新增實體: [實體名稱]
  - 欄位:
    - Name (string, required, max:100)
    - Description (string, nullable)
    - ...
- [ ] 修改實體: [實體名稱]
  - 新增欄位: [欄位名稱]
  - 修改關聯: [說明]
- [ ] 刪除實體: [實體名稱]

**額外需求**:
- [ ] 需要建立索引
- [ ] 需要資料遷移 (Data Migration)
- [ ] 需要 Seed Data

**資料庫**: SQL Server / PostgreSQL / MySQL

請產生:
1. Entity 類別或修改
2. EntityTypeConfiguration
3. Migration 指令
4. 必要的 Seed Data (如果需要)
```

## 範例輸入

```
請協助建立 EF Core Migration:

**目的**: 新增產品分類功能

**變更內容**:
- [x] 新增實體: ProductCategory
  - 欄位:
    - Id (int, Primary Key)
    - Name (string, required, max:100)
    - Description (string, nullable)
    - ParentCategoryId (int, nullable, 自我關聯)
    - IsActive (bool, default:true)
- [x] 修改實體: Product
  - 新增欄位: CategoryId (int, required, Foreign Key)

**額外需求**:
- [x] 需要建立索引 (Category Name 唯一索引)
- [x] 需要 Seed Data (預設分類)

**資料庫**: SQL Server

請產生上述完整程式碼與 Migration 指令
```

## 預期輸出

包含:
1. 完整 Entity 定義
2. EntityTypeConfiguration
3. Migration 命令與說明
4. Seed Data 範例

---

**類別**: Database  
**優先級**: High  
**版本**: 1.0.0

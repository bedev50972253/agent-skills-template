# 🎨 UI 元件生成提示範本

## 使用情境

當需要建立新的 React / Blazor UI 元件時使用此提示。

## 提示範本

```
請協助建立 UI 元件:

**元件名稱**: [元件名稱]

**UI 框架**: React / Blazor / Vue

**CSS 框架**: Bootstrap 5 / Tailwind CSS / Material-UI

**功能需求**:
- [ ] 顯示資料: [說明]
- [ ] 使用者互動: [說明]
- [ ] 表單驗證: [說明]
- [ ] API 整合: [說明]

**Props / 參數**:
- `prop1` (type): 說明
- `prop2` (type): 說明

**狀態管理**: Local State / Redux / Zustand / Context API

**響應式設計**: 
- 手機: [說明]
- 平板: [說明]
- 桌面: [說明]

請產生:
1. 元件程式碼 (TypeScript)
2. Props 介面定義
3. CSS 樣式 (如需要)
4. 使用範例
```

## 範例輸入

```
請協助建立 UI 元件:

**元件名稱**: ProductCard

**UI 框架**: React 18 + TypeScript

**CSS 框架**: Bootstrap 5

**功能需求**:
- [x] 顯示資料: 產品圖片、名稱、價格、分類標籤
- [x] 使用者互動: 點擊卡片查看詳情、加入購物車按鈕
- [x] API 整合: 加入購物車時呼叫 API

**Props / 參數**:
- `product` (Product): 產品物件
- `onAddToCart` ((productId: number) => void): 加入購物車回呼
- `onClick` ((product: Product) => void): 點擊卡片回呼

**狀態管理**: Local State (React Hook)

**響應式設計**: 
- 手機: 單欄
- 平板: 雙欄
- 桌面: 四欄

請產生完整程式碼與使用範例
```

## 預期輸出

包含:
1. TypeScript 元件程式碼
2. Props 介面
3. Bootstrap Grid 響應式佈局
4. 使用範例

---

**類別**: Frontend  
**優先級**: High  
**版本**: 1.0.0

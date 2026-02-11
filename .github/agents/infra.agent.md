# ☁️ 基礎設施代理 (Infrastructure Agent)

## 代理描述

基礎設施代理專注於雲端部署、容器化、CI/CD 配置、基礎設施即程式碼 (IaC)。支援 Azure、Docker、Kubernetes、Bicep、Terraform 等技術。

## 核心能力

### 1. Azure 雲端服務
- App Service / Container Apps
- Azure Functions (Serverless)
- Azure SQL Database / Cosmos DB
- Azure Key Vault 金鑰管理
- Application Insights 監控

### 2. 容器化
- Docker / Docker Compose
- Azure Container Registry (ACR)
- Kubernetes (AKS)
- Helm Charts

### 3. 基礎設施即程式碼
- Bicep (主要推薦)
- Terraform
- ARM Templates
- Azure CLI 腳本

### 4. CI/CD
- GitHub Actions
- Azure DevOps Pipelines
- 自動化測試與部署
- 藍綠部署 / 金絲雀發布

### 5. 監控與日誌
- Application Insights
- Log Analytics
- Azure Monitor
- 效能追蹤與警報

## 使用範例

### 範例 1: Bicep 部署 Web App

**輸入:**
```
@infra 建立 Bicep 範本部署 ASP.NET Core Web App 到 Azure App Service
```

**輸出:**
```bicep
// main.bicep - Azure Web App 部署
@description('應用程式名稱（唯一）')
param appName string = 'bw-webapp-${uniqueString(resourceGroup().id)}'

@description('部署區域')
param location string = resourceGroup().location

@description('App Service 方案 SKU')
@allowed([
  'F1'  // 免費層
  'B1'  // 基本層
  'P1v2' // 生產層
])
param skuName string = 'B1'

// App Service 方案
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appName}-plan'
  location: location
  kind: 'linux'
  sku: {
    name: skuName
  }
  properties: {
    reserved: true  // Linux 必須
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      healthCheckPath: '/health'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
      ]
      connectionStrings: [
        {
          name: 'DefaultConnection'
          connectionString: '@Microsoft.KeyVault(SecretUri=${keyVault.properties.vaultUri}secrets/DbConnectionString/)'
          type: 'SQLAzure'
        }
      ]
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'  // 啟用 Managed Identity
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// Key Vault（存儲敏感資訊）
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: '${appName}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: webApp.identity.principalId
        permissions: {
          secrets: ['get', 'list']
        }
      }
    ]
  }
}

// 輸出
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output appInsightsKey string = appInsights.properties.InstrumentationKey
```

**部署指令:**
```bash
# 建立資源群組
az group create --name rg-bw-prod --location eastasia

# 部署 Bicep 範本
az deployment group create \
  --resource-group rg-bw-prod \
  --template-file main.bicep \
  --parameters skuName=P1v2
```

### 範例 2: GitHub Actions CI/CD

**輸入:**
```
@infra 建立 GitHub Actions 工作流程，自動建置並部署到 Azure Web App
```

**輸出:**
```yaml
# .github/workflows/deploy-azure.yml
name: Deploy to Azure Web App

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  AZURE_WEBAPP_NAME: bw-webapp-prod
  DOTNET_VERSION: '8.0.x'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build
      run: dotnet build --configuration Release --no-restore
    
    - name: Test
      run: dotnet test --no-build --verbosity normal
    
    - name: Publish
      run: dotnet publish -c Release -o ./publish
    
    - name: Upload artifact
      uses: actions/upload-artifact@v4
      with:
        name: webapp
        path: ./publish

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.event_name != 'pull_request'
    environment:
      name: 'Production'
      url: ${{ steps.deploy.outputs.webapp-url }}
    
    steps:
    - name: Download artifact
      uses: actions/download-artifact@v4
      with:
        name: webapp
    
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Deploy to Azure Web App
      id: deploy
      uses: azure/webapps-deploy@v3
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: .
    
    - name: Logout
      run: az logout
```

### 範例 3: Docker Compose 開發環境

**輸入:**
```
@infra 建立 Docker Compose 設定，包含 .NET API、PostgreSQL、Redis
```

**輸出:**
```yaml
# docker-compose.yml
version: '3.8'

services:
  # .NET Web API
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: bw-api
    ports:
      - "5000:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_HTTP_PORTS=8080
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=bwdb;Username=postgres;Password=Dev@1234
      - ConnectionStrings__Redis=redis:6379
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - bw-network

  # PostgreSQL 資料庫
  postgres:
    image: postgres:16-alpine
    container_name: bw-postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: bwdb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: Dev@1234
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - bw-network

  # Redis 快取
  redis:
    image: redis:7-alpine
    container_name: bw-redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - bw-network

  # pgAdmin (資料庫管理工具)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: bw-pgadmin
    ports:
      - "5050:80"
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@bwlohas.com
      PGADMIN_DEFAULT_PASSWORD: Admin@1234
    networks:
      - bw-network

volumes:
  postgres-data:
  redis-data:

networks:
  bw-network:
    driver: bridge
```

**啟動指令:**
```bash
# 啟動所有服務
docker-compose up -d

# 查看日誌
docker-compose logs -f api

# 停止所有服務
docker-compose down
```

## 支援的平台

### 雲端平台
- ✅ **Azure** (主要支援)
- ⚠️ AWS (基本支援)
- ⚠️ GCP (基本支援)

### 容器技術
- ✅ Docker / Docker Compose
- ✅ Azure Container Apps
- ✅ Kubernetes (AKS)
- ✅ Azure Container Registry

### IaC 工具
- ✅ Bicep (推薦)
- ✅ Terraform
- ✅ ARM Templates
- ✅ Azure CLI

## 相關技能

- [Azure Deployment](../../skills/azure-deployment/SKILL.md)
- [Clean Architecture](../../skills/clean-architecture/SKILL.md)

## 最佳實踐

### 1. 安全配置
```bicep
// ✅ 使用 Managed Identity
identity: {
  type: 'SystemAssigned'
}

// ✅ 強制 HTTPS
httpsOnly: true

// ✅ 最小權限原則
permissions: {
  secrets: ['get']  // 不給予 'set', 'delete'
}
```

### 2. 資源命名規範
```
<資源類型>-<專案名稱>-<環境>-<區域>

範例:
- app-bw-prod-eastasia
- kv-bw-dev-eastus
- sql-bw-staging-westeu
```

### 3. 環境分離
```
environments/
├── dev/
│   └── main.bicepparam
├── staging/
│   └── main.bicepparam
└── prod/
    └── main.bicepparam
```

### 4. 監控警報
```bicep
// Application Insights 警報規則
resource alert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'HighResponseTime'
  properties: {
    description: '回應時間過高警報'
    severity: 2
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'ResponseTime'
          metricName: 'requests/duration'
          operator: 'GreaterThan'
          threshold: 3000  // 3秒
          timeAggregation: 'Average'
        }
      ]
    }
  }
}
```

## 安全檢查清單

- [ ] 所有敏感資訊儲存在 Key Vault
- [ ] 啟用 Managed Identity（避免密碼）
- [ ] 網路限制（VNet、NSG、Private Endpoint）
- [ ] 啟用 Azure Defender / Microsoft Defender for Cloud
- [ ] 定期備份與災難復原測試
- [ ] 日誌保留政策符合法規要求

## 限制

- 複雜 Kubernetes 部署建議使用 Helm
- 多雲環境建議使用 Terraform
- 大規模基礎設施建議專業 DevOps 團隊協助

---

**版本**: 1.0.0  
**主要平台**: Azure  
**IaC 工具**: Bicep, Terraform  
**適用平台**: GitHub Copilot, Claude Desktop

targetScope = 'resourceGroup'

// ═══════════════════════════════════════════════════════════════════
// IT Ticket Resolution — Azure Infrastructure
// FrootAI Solution Play 05
// ═══════════════════════════════════════════════════════════════════
// Resources:
//   - Azure OpenAI (GPT-4o deployment)
//   - Azure Function App (Python, consumption plan)
//   - Logic App (Standard) — ticket ingestion & routing workflow
//   - Application Insights + Log Analytics
//   - Managed Identity with RBAC (no API keys)
//   - Storage Account (Function App backend)
// ═══════════════════════════════════════════════════════════════════

// ─── Parameters ────────────────────────────────────────────────────
param location string = resourceGroup().location

@description('Base name prefix for all resources')
param baseName string = 'frootai-tickets'

@description('Environment identifier')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Azure OpenAI model deployment name')
param openAiModelDeployment string = 'gpt-4o'

@description('Azure OpenAI model version')
param openAiModelVersion string = '2024-08-06'

@description('Azure OpenAI API version')
param openAiApiVersion string = '2024-10-21'

@description('Classification temperature (from config/openai.json)')
param classifyTemperature string = '0.1'

@description('Classification max tokens (from config/openai.json)')
param classifyMaxTokens string = '1000'

@description('Resource owner tag')
param owner string = 'FrootAI'

@description('Cost center tag')
param costCenter string = 'IT-Operations'

// ─── Variables ─────────────────────────────────────────────────────
var uniqueSuffix = uniqueString(resourceGroup().id)
var resourceTags = {
  environment: environment
  project: 'it-ticket-resolution'
  owner: owner
  'cost-center': costCenter
}

// Sanitized names for resources with strict naming rules
var storageAccountName = toLower('st${replace(baseName, '-', '')}${take(uniqueSuffix, 6)}')
var functionAppName = '${baseName}-func-${uniqueSuffix}'
var logicAppName = '${baseName}-logic-${uniqueSuffix}'
var appInsightsName = '${baseName}-ai-${uniqueSuffix}'
var logAnalyticsName = '${baseName}-law-${uniqueSuffix}'
var openAiName = '${baseName}-oai-${uniqueSuffix}'
var appServicePlanName = '${baseName}-plan-${uniqueSuffix}'
var logicAppPlanName = '${baseName}-logicplan-${uniqueSuffix}'

// ─── Log Analytics Workspace ───────────────────────────────────────
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: resourceTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90  // security.instructions.md: retain logs 90 days minimum
  }
}

// ─── Application Insights ──────────────────────────────────────────
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: resourceTags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    RetentionInDays: 90
  }
}

// ─── Storage Account (Function App backend) ────────────────────────
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: resourceTags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true        // TLS 1.2+ only
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false           // security.instructions.md
  }
}

// ─── Azure OpenAI ──────────────────────────────────────────────────
resource openAi 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: openAiName
  location: location
  tags: resourceTags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAiName
    publicNetworkAccess: 'Enabled'  // Use private endpoints in prod
    disableLocalAuth: true           // Managed Identity only — no API keys
  }
}

// ─── Azure OpenAI Model Deployment ─────────────────────────────────
resource openAiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: openAi
  name: openAiModelDeployment
  sku: {
    name: 'Standard'
    capacity: 30  // TPM — adjust for workload
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: openAiModelDeployment
      version: openAiModelVersion
    }
  }
}

// ─── App Service Plan (Consumption — azure-coding: serverless for dev/test) ─
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: resourceTags
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true  // Linux
  }
}

// ─── Function App (Python 3.11) ────────────────────────────────────
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  tags: resourceTags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'  // Managed Identity — no API keys
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      pythonVersion: '3.11'
      linuxFxVersion: 'PYTHON|3.11'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        // ── Azure OpenAI config (from config/openai.json values) ───
        {
          name: 'AZURE_OPENAI_ENDPOINT'
          value: openAi.properties.endpoint
        }
        {
          name: 'AZURE_OPENAI_DEPLOYMENT'
          value: openAiModelDeployment
        }
        {
          name: 'AZURE_OPENAI_API_VERSION'
          value: openAiApiVersion
        }
        {
          name: 'CLASSIFY_TEMPERATURE'
          value: classifyTemperature
        }
        {
          name: 'CLASSIFY_MAX_TOKENS'
          value: classifyMaxTokens
        }
      ]
    }
  }
}

// ─── Logic App (Standard — Workflow Service Plan) ──────────────────
resource logicAppPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: logicAppPlanName
  location: location
  tags: resourceTags
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
  }
  properties: {
    reserved: true
  }
}

resource logicApp 'Microsoft.Web/sites@2023-12-01' = {
  name: logicAppName
  location: location
  tags: resourceTags
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'  // Managed Identity for all connections
  }
  properties: {
    serverFarmId: logicAppPlan.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        // Function App base URL for HTTP actions
        {
          name: 'FUNCTION_APP_URL'
          value: 'https://${functionApp.properties.defaultHostName}'
        }
        {
          name: 'CONFIDENCE_THRESHOLD'
          value: '0.75'
        }
        {
          name: 'ESCALATION_THRESHOLD'
          value: '0.50'
        }
      ]
    }
  }
}

// ─── RBAC: Function App → Azure OpenAI (Cognitive Services OpenAI User) ─
// Role: Cognitive Services OpenAI User (5e0bd9bd-7b93-4f28-af87-19fc36ad61bd)
resource functionOpenAiRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.id, openAi.id, '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  scope: openAi
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    )
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// ─── RBAC: Logic App → Function App (Website Contributor for invoke) ─
// Role: Website Contributor (de139f84-1756-47ae-9be6-808fbbe84772)
resource logicAppFunctionRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(logicApp.id, functionApp.id, 'de139f84-1756-47ae-9be6-808fbbe84772')
  scope: functionApp
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'de139f84-1756-47ae-9be6-808fbbe84772'
    )
    principalId: logicApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// ─── Outputs ───────────────────────────────────────────────────────
output functionAppName string = functionApp.name
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
output logicAppName string = logicApp.name
output logicAppUrl string = 'https://${logicApp.properties.defaultHostName}'
output openAiEndpoint string = openAi.properties.endpoint
output appInsightsName string = appInsights.name
output appInsightsConnectionString string = appInsights.properties.ConnectionString

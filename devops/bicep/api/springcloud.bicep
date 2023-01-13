@description('The instance name of the Azure Spring Cloud resource')
param springCloudInstanceName string

// @description('The name of the Application Insights instance for Azure Spring Cloud')
// param appInsightsName string

@description('The resource ID of the existing Log Analytics workspace. This will be used for both diagnostics logs and Application Insights')
param laWorkspaceResourceId string

@description('The resourceID of the Azure Spring Cloud App Subnet')
param springCloudAppSubnetID string

@description('The resourceID of the Azure Spring Cloud Runtime Subnet')
param springCloudRuntimeSubnetID string

@description('Comma-separated list of IP address ranges in CIDR format. The IP ranges are reserved to host underlying Azure Spring Cloud infrastructure, which should be 3 at least /16 unused IP ranges, must not overlap with any Subnet IP ranges')
param springCloudServiceCidrs string = '10.0.0.0/16,10.2.0.0/16,10.3.0.1/16'

//@description('The tags that will be associated to the Resources')
//param tags object = {
//  environment: 'lab'
//}

@description('Location for all resources.')
param location string = resourceGroup().location

//resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
//  name: appInsightsName
//  location: location
//  kind: 'web'
//  tags: tags
//  properties: {
//    Application_Type: 'web'
//    Flow_Type: 'Bluefield'
//    Request_Source: 'rest'
//    WorkspaceResourceId: laWorkspaceResourceId
//  }
//}

resource springCloudInstance 'Microsoft.AppPlatform/Spring@2022-03-01-preview' = {
  name: springCloudInstanceName
  location: location
  //tags: tags
  sku: { // limitaiton - cannot deploy to Basic using IaC
    name: 'S0'
    tier: 'Standard'
  }
  properties: {
    networkProfile: {
      serviceCidr: springCloudServiceCidrs
      serviceRuntimeSubnetId: springCloudRuntimeSubnetID
      appSubnetId: springCloudAppSubnetID
    }
  }
}

//resource springCloudMonitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2020-07-01' = {
//  name: '${springCloudInstance.name}/default' // The only supported value is 'default'
//  properties: {
//    traceEnabled: true
//    appInsightsInstrumentationKey: appInsights.properties.InstrumentationKey
//  }
//}

resource springCloudDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'monitoring'
  scope: springCloudInstance
  properties: {
    workspaceId: laWorkspaceResourceId
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: false
        }
      }
    ]
  }
}

$sub = Get-AzSubscription -SubscriptionName 'NH173 Landing Zone 1'
Select-AzSubscription $sub

#  az role assignment create --assignee ca2ad932-742a-43de-8e3f-956051cac913 --scope '/' --role 'Owner'

# Management groups

$location = 'westeurope'

$inputObject = @{
  DeploymentName        = 'alz-MGDeployment-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  Location              = $location
  TemplateFile          = "infra-as-code/bicep/modules/managementGroups/managementGroups.bicep"
  TemplateParameterFile = 'infra-as-code/bicep/modules/managementGroups/parameters/managementGroups.parameters.all.json'
}
New-AzTenantDeployment @inputObject


# Policy

$inputObject = @{
  DeploymentName        = 'alz-PolicyDefsDeployment-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  Location              = $location
  ManagementGroupId     = 'alz'
  TemplateFile          = "infra-as-code/bicep/modules/policy/definitions/customPolicyDefinitions.bicep"
  TemplateParameterFile = 'infra-as-code/bicep/modules/policy/definitions/parameters/customPolicyDefinitions.parameters.all.json'
}

New-AzManagementGroupDeployment @inputObject


# Custom roles

$inputObject = @{
  DeploymentName        = 'alz-CustomRoleDefsDeployment-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  Location              = $location
  ManagementGroupId     = 'alz'
  TemplateFile          = "infra-as-code/bicep/modules/customRoleDefinitions/customRoleDefinitions.bicep"
  TemplateParameterFile = 'infra-as-code/bicep/modules/customRoleDefinitions/parameters/customRoleDefinitions.parameters.all.json'
}

New-AzManagementGroupDeployment @inputObject

# Logging
# Set Platform management subscripion ID as the the current subscription
$ManagementSubscriptionId = "6e8c64f1-51d4-4010-aac6-bdd891e66b1b"
Register-AzResourceProvider –ProviderNamespace Microsoft.Insights


# Set the top level MG Prefix in accordance to your environment. This example assumes default 'alz'.
$TopLevelMGPrefix = "alz"

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = 'alz-LoggingDeploy-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  ResourceGroupName     = "rg-$TopLevelMGPrefix-logging-001"
  TemplateFile          = "infra-as-code/bicep/modules/logging/logging.bicep"
  TemplateParameterFile = "infra-as-code/bicep/modules/logging/parameters/logging.parameters.all.json"
}

Select-AzSubscription -SubscriptionId $ManagementSubscriptionId

# Create Resource Group - optional when using an existing resource group
New-AzResourceGroup `
  -Name $inputObject.ResourceGroupName `
  -Location $location `
  -Force

$loggingOutput =  New-AzResourceGroupDeployment @inputObject

# For Azure global regions
New-AzManagementGroupDeployment `
  -TemplateFile infra-as-code/bicep/orchestration/mgDiagSettingsAll/mgDiagSettingsAll.bicep `
  -TemplateParameterFile infra-as-code/bicep/orchestration/mgDiagSettingsAll/parameters/mgDiagSettingsAll.parameters.all.json `
  -Location $location `
  -parLogAnalyticsWorkspaceResourceId $loggingOutput.Outputs['outLogAnalyticsWorkspaceId'].Value `
  -ManagementGroupId alz


# Network Hub
# Set Platform connectivity subscription ID as the the current subscription
$ConnectivitySubscriptionId = "6e8c64f1-51d4-4010-aac6-bdd891e66b1b"

Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId

# Set Platform management subscription ID as the the current subscription
$ManagementSubscriptionId = "6e8c64f1-51d4-4010-aac6-bdd891e66b1b"

# Set the top level MG Prefix in accordance to your environment. This example assumes default 'alz'.
$TopLevelMGPrefix = "alz"

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = 'alz-HubNetworkingDeploy-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  ResourceGroupName     = "rg-$TopLevelMGPrefix-hub-networking-001"
  TemplateFile          = "infra-as-code/bicep/modules/hubNetworking/hubNetworking.bicep"
  TemplateParameterFile = "infra-as-code/bicep/modules/hubNetworking/parameters/hubNetworking.parameters.all.json"
}

New-AzResourceGroup `
  -Name $inputObject.ResourceGroupName `
  -Location $location

New-AzResourceGroupDeployment @inputObject

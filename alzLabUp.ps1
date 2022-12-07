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

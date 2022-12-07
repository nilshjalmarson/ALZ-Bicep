$sub = Get-AzSubscription -SubscriptionName 'NH173 Landing Zone 1'
Select-AzSubscription $sub

#  az role assignment create --assignee ca2ad932-742a-43de-8e3f-956051cac913 --scope '/' --role 'Owner'

# For Azure global regions

$inputObject = @{
  DeploymentName        = 'alz-MGDeployment-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  Location              = 'westeurope'
  TemplateFile          = "infra-as-code/bicep/modules/managementGroups/managementGroups.bicep"
  TemplateParameterFile = 'infra-as-code/bicep/modules/managementGroups/parameters/managementGroups.parameters.all.json'
}
New-AzTenantDeployment @inputObject

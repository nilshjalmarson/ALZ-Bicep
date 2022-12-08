$sub = Get-AzSubscription -SubscriptionName 'NH173 Landing Zone 1'
Select-AzSubscription $sub

#  az role assignment create --assignee ca2ad932-742a-43de-8e3f-956051cac913 --scope '/' --role 'Owner'

# Management groups

# $location = 'westeurope'

Remove-AzManagementGroup -GroupId 'alz-decommissioned'

Remove-AzResourceGroup -Force -Name 'rg-alz-logging-001'
Remove-AzResourceGroup -Force -Name 'rg-alz-hub-networking-001'

#The below PowerShell Script will be helpful to disable/enable blob inventory rule(s) in a storage account

#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, 
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#get the blob inventory policy for the storage account
$policy = Get-AzStorageBlobInventoryPolicy -ResourceGroupName "resouce_group_name" -AccountName "storage_account_name"
# use $false to disable the rule and use $true to enable the rule
#if you want to take action on multiple blob inventory rules, use $policy.Rules[0],$policy.Rules[1].$policy.Rules[2].. and so on
$policy.Rules[0].Enabled=$false
$policy.Rules[0]
 
# set the blob inventory rules
Set-AzStorageBlobInventoryPolicy -ResourceGroupName "resource_group_name" -AccountName "storage_account_name" -Rule $policy.Rules

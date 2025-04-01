#The below PowerShell script helps to Update  Tenant In Key Vault .



#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service.
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including,
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
Select-AzSubscription -SubscriptionId <your-subscriptionId>                                     

$vaultResourceId = (Get-AzKeyVault -VaultName myvault).ResourceId                 

$vault = Get-AzResource -ResourceId $vaultResourceId -ExpandProperties           

$vault.Properties.TenantId = (Get-AzContext).Tenant.TenantId                                

$vault.Properties.AccessPolicies = @()  

Set-AzResource -ResourceId $vaultResourceId -Properties $vault.Properties



#The below PowerShell script helps to get all storage accounts of a subscription where blob versioning is enabled.

#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, 
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 




Connect-AzAccount
#Make sure you select the right subscription
Set-AzContext -SubscriptionId "a177bdb0-44ce-4b6e-a01e-9444cfa34b5c"
$accounts = Get-AzStorageAccount
write-output "account name with Versioning enabled:"
foreach($account in $accounts)
{


if((Get-AzStorageBlobServiceProperty -ResourceGroupName $account.ResourceGroupName -AccountName $account.StorageAccountName).IsVersioningEnabled -eq $true)
{
write-output $account.StorageAccountName
}
}


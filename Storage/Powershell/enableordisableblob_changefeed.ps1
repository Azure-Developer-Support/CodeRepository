###ATTENTION: DISCLAIMER###
 
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
 
 
############# Script Overview #################################################################
########## Helps to enable/disable blob changefeed on all storage account in selected subscription #########

Connect-AzAccount
#Make sure you select the right subscription
Set-AzContext -SubscriptionId "8d5a164b-2102-4481-bfff-926284f55786"

$storageAccounts = Get-AzStorageAccount
foreach ($storageAccount in $storageAccounts)
{
    $storageAccountName = $storageAccount.StorageAccountName

    $resourceGroupName = $storageAccount.ResourceGroupName

    #enable blob Change feed with with keep all logs
    Update-AzStorageBlobServiceProperty -ResourceGroupName $resourceGroupName  -Name $storageAccountName -EnableChangeFeed $true

    #enable blob Change feed with Delete change feed logs after (in days)
    Update-AzStorageBlobServiceProperty -ResourceGroupName $resourceGroupName  -Name $storageAccountName -EnableChangeFeed $true -ChangeFeedRetentionInDays 6

    #disable blob Change feed 
    Update-AzStorageBlobServiceProperty -ResourceGroupName $resourceGroupName  -Name $storageAccountName -EnableChangeFeed $false

    $properties=Get-AzStorageBlobServiceProperty -ResourceGroupName $resourceGroupName -Name $storageAccountName

    Write-Output "Storage account Name: $($storageAccountName), Change feed enabled: $($properties.ChangeFeed.Enabled)" 

}

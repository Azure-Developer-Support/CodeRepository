###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########This script helps in enabling Azure Storage logs in Azure Monitor in all the storage accounts part of an Azure Subscription for specified region. 
##########Please feel free to customize the logging details as needed on parameter of cmd: Set-AzDiagnosticSetting.
#Ref links:https://docs.microsoft.com/en-us/azure/storage/blobs/monitor-blob-storage?tabs=azure-powershell#creating-a-diagnostic-setting
    
    
    #connect to your Azure account
    Connect-AzAccount

    #sets the context to a subscription
    $context = Get-AzSubscription -SubscriptionId 'XXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    Set-AzContext $context
    
    #Get all storage accounts of standard tier sku present in the subscription
    $sAccounts = Get-AzStorageAccount | Where-Object {$_.Sku.Tier -eq "Standard" }

    #loop through all storage accounts to set logging
    Foreach($Account in $sAccounts)
    {
    
        #Get storage account
        $account = Get-AzResource -ResourceGroupName $Account.ResourceGroupName -Name $Account.StorageAccountName

        
        #gets the resource id of specific storage service
        $blobResID = $account.ResourceId + "/blobServices/default"
        $fileResID = $account.ResourceId + "/fileServices/default"
        $queueResID = $account.ResourceId + "/queueServices/default"
        $tableResID = $account.ResourceId + "/tableServices/default"

        #set the resource id of storage account to which you want to export the logs to
        #make sure the storage account on which Monitor log is getting enabled and the storage account to which logs are exported to, are in the same Azure region
        $accountResID = "/subscriptions/XXXXXXXXXXXXXXXXXXX/resourceGroups/YYY/providers/Microsoft.Storage/storageAccounts/ZZZZZZZZZZZZZ"
        
        #set logging settings
        #modify the logging settings below as per your requirement : https://docs.microsoft.com/en-us/powershell/module/az.monitor/set-azdiagnosticsetting?view=azps-5.7.0

        Set-AzDiagnosticSetting -ResourceId $blobResID -StorageAccountId  $accountResID -Enabled $true -Category StorageRead,StorageWrite,StorageDelete

        #get the logging details
        $log = Get-AzDiagnosticSetting -ResourceId $blobResID

         if($log) {
                    Write-Host -ForegroundColor Green "Storage Analytical log is enabled in storage account: "$Account.StorageAccountName
                }
                else {
                    Write-Host -ForegroundColor Red " Storage Analytical is not enabled in storage account: "$Account.StorageAccountName
                }
    
    }

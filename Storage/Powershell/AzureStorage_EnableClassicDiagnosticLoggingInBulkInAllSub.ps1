###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########This script helps in enabling Classic storage diagnostic logs for all the storage accounts part of an Azure Subscription or multiple subscription. 
##########Please feel free to customize the logging details as needed on parameter of cmd: Set-AzStorageServiceLoggingProperty.
#Ref links:https://docs.microsoft.com/en-us/azure/storage/common/manage-storage-analytics-logs?tabs=azure-powershell#enable-logs
    
    #connect to your Azure account
    Connect-AzAccount

    #Get all subscriptions
    $subscriptions = Get-AzSubscription
    
    foreach ($sub in $subscriptions){

        #sets the context to a subscription
        $context = Get-AzSubscription -SubscriptionId $sub.Id
        Set-AzContext $context
    
        #Get all storage accounts of standard tier SKU present in the subscription
        $sAccounts = Get-AzStorageAccount | Where-Object {$_.Sku.Tier -eq "Standard" }

        #loop through all storage accounts to set logging
        Foreach($Account in $sAccounts)
        {
    
            #Get storage account
            $storageAccount = Get-AzStorageAccount -ResourceGroupName $Account.ResourceGroupName -AccountName $Account.StorageAccountName
            $ctx = $storageAccount.Context
        
            #set logging settings
            #modify the logging settings below as per your requirement : https://docs.microsoft.com/en-us/powershell/module/az.storage/set-azstorageserviceloggingproperty?view=azps-5.7.0

            Set-AzStorageServiceLoggingProperty -ServiceType Blob -LoggingOperations read,write,delete -RetentionDays 5 -Version 2.0 -Context $ctx 

            #get the logging details
            $log = $ctx | Get-AzStorageServiceLoggingProperty -ServiceType Blob

             if($log.LoggingOperations -ne "None") {
                        Write-Host -ForegroundColor Green "Storage Analytical log is enabled in storage account: "$Account.StorageAccountName
                    }
                    elseif ($log.LoggingOperations -eq "None") {
                        Write-Host -ForegroundColor Red " Storage Analytical is not enabled in storage account: "$Account.StorageAccountName
                    }
    
        }
    }

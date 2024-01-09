#The below PowerShell script helps to list the blobs present in a folder in storage accounts and also calculate the usage of that folder.

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

##########Script Overview#################################################################

##########This script provide data of availability metric of all the storage accounts within a subscription#########################

############################Script Sample#######################################

#Please update these value as per your scenario

#Make sure you provide the right subscription Id

$subscriptionId = "<your Azure subscription Id>"

Connect-AzAccount

Set-AzContext -SubscriptionId $subscriptionId

$storageAccounts = Get-AzStorageAccount

foreach ($storageAccount in $storageAccounts) {
    $storageAccountName = $storageAccount.StorageAccountName
    $resourceGroupName = $storageAccount.ResourceGroupName

    Write-Host "storage account name: $storageAccountName"

    $resourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$storageAccountName"

    $metrics = Get-AzMetric -ResourceId $resourceId -MetricName "Availability" -AggregationType Average -TimeGrain 00:05:00 -StartTime (Get-Date).AddDays(-1) -EndTime (Get-Date)
    $metrics.Data

    Write-Host "=========================================================XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX======================================="
}

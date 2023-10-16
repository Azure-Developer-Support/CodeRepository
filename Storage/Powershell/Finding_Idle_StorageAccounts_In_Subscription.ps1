PS script to find all the storage accounts in a subscription which are having the total transaction is equal to zero.
#Disclaimer
 #By using the following materials or sample code you agree to be bound by the license terms below 
#and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
#are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
#are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
#use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
#provided that you agree: (i) to not use Microsoftâ€™s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
#which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
#a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
#suppliers from and against any third party claims or lawsuits, including attorneysâ€™ fees, that arise or result 
#from the use or distribution of the sample code."

# Set the number of days to check for inactivity
$daysThreshold = 30 # You can change this value as needed
# Sign into your Azure account
Connect-AzAccount
Set-AzContext -SubscriptionId "XXXXXXXXXXXXXXXXXXXXXXXXX"
# Get all storage accounts in the subscription
$storageAccounts = Get-AzStorageAccount
# Loop through each storage account
foreach ($storageAccount in $storageAccounts) { 
    $resourceId = $storageAccount.Id
    $metrics = Get-AzMetric -ResourceId $resourceId -MetricName "Transactions"  -Aggregation Total -StartTime (Get-Date).AddDays(-$daysThreshold) -EndTime (Get-Date)
   $totalTransactions = $metrics.Data[0].Total
    $totalTransactions = 0
    $metrics.Data | Foreach { $totalTransactions += $_.Total}
    #$totalTransactions 
    $storageAccountName = $storageAccount.StorageAccountName

    #If you want to print the totla transactions of the storage account
    #   Write-Host " $totalTransactions'- '$storageAccountName' "

  if ($totalTransactions -eq 0) {
       Write-Host "No transactions in storage account '$storageAccountName'  in the last $daysThreshold days."
    }
}




PS script to find all the storage accounts in a subscription which are having the total transaction is equal to zero based on the transaction type (User/System).
# Set the number of days to check for inactivity
$daysThreshold = 30 # You can change this value as needed
# Sign into your Azure account
Connect-AzAccount
Set-AzContext -SubscriptionId "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
# Get all storage accounts in the subscription
$storageAccounts = Get-AzStorageAccount
# Loop through each storage account
foreach ($storageAccount in $storageAccounts) {  
    $resourceId = $storageAccount.Id
#Please change the transaction type based on your requirements (User/System)
    $dimFilter = New-AzMetricFilter -Dimension TransactionType -Operator eq -Value "User"
    $metrics = Get-AzMetric -ResourceId $resourceId -MetricName "Transactions" -MetricFilter $dimFilter  -Aggregation Total -StartTime (Get-Date).AddDays(-$daysThreshold) -EndTime (Get-Date)
   $totalTransactions = $metrics.Data[0].Total
    $totalTransactions = 0
    $metrics.Data | Foreach { $totalTransactions += $_.Total}
    #$totalTransactions 
    $storageAccountName = $storageAccount.StorageAccountName
    #If you want to print the totla transactions of the storage account
    #   Write-Host " $totalTransactions'- '$storageAccountName' "
  
  if ($totalTransactions -eq 0) {
       Write-Host "No transactions in storage account '$storageAccountName’ in the last $daysThreshold days."
    }
}

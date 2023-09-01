#Azure Storage Table - PowerShell
###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#############Script Overview#################################################################
##########This script is designed to facilitate the deletion of rows in batches of 1000, filtered based on the Timestamp property of a specific Azure Table Storage.#########################

Connect-AzAccount
Set-AzContext -SubscriptionName '<Subscription-Name>'
 
$storageAccountName = "<Storage-Account-Name>"
$storageAccountKey = "<Storage-Account-Access-Key>"
$tableName = "<Azure-Table-Name>"

$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$cloudTable = (Get-AzStorageTable -Name $tableName -Context $ctx).CloudTable

$filter = "Timestamp lt datetime'2020-10-13T09:12:23.9628442Z'"
$count = 0

do {
            $loop += 1
            Write-Host $("Loop count " + $loop)

            $entityToDelete = Get-AzTableRow -table $cloudTable -customFilter $filter -top 1000 -verbose
            Write-Host "Start deleting data from table: " + $tableName
            
            $count = $entityToDelete.Count
            Write-Host $("Items count: " + $count)
            
            $entityToDelete | Remove-AzTableRow -table $cloudTable -verbose
   }
   While ($count -gt 0)

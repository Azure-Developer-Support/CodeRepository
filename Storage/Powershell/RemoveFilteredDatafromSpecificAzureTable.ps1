#Azure Storage Table - PowerShell
###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#############Script Overview#################################################################
##########This script would help to filter the data based on Timestamp property of a specific Azure Table Storage and then delete it#########################

Connect-AzAccount
Set-AzContext -SubscriptionName '<Subscription-Name>'
 
$storageAccountName = "<Storage-Account-Name>"
$storageAccountKey = "<Storage-Account-Access-Key>"
$tableName = "<Azure-Table-Name>"

$ctx = New-AzStorageContext -StorageAccountName $StorageAccountNAme -StorageAccountKey $StorageAccountKey

$table = Get-AzStorageTable -Name $tableName -Context $ctx

$cloudtable = $table.CloudTable

Get-AzTableRow -table $cloudTable -CustomFilter "Timestamp gt datetime'2016-12-20T03:00:12Z' and Timestamp lt datetime'2023-05-01T10:30:21Z'" | Remove-AzTableRow -Table $cloudtable

Write-Output "Filtered data has been deleted from " $tableName

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


Connect-AzAccount -Subscription "xxx"

$StorageAccount = "xxx"
$StorageAccountKey = "xxx"
 
$ctx = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageAccountKey
 
$alltablename=(Get-AzStorageTable –Context $ctx).CloudTable

foreach($table in $alltablename)
{
$tabledata=Get-AzTableRow -table $table -CustomFilter "Timestamp gt datetime'2020-05-01T00:00:00.000Z'" | Remove-AzTableRow -Table $table
}


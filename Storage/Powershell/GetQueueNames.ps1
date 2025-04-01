#The below PowerShell script helps to get All the queue name.



#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service.
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including,
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages

#Connect-AzAccount
$storageAccountName = "test"
$resourceGroupName="test"
$StorageAccountKey = "XXXXX" 
#$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName       `
#$ctx = $storageAccount.Context
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey
# Retrieve a specific queue
$queue = Get-AzStorageQueue –Name kar* –Context $ctx
# Show the properties of the queue
$queue

# Retrieve all queues and show their names
#Get-AzStorageQueue -Context $ctx | Select-Object Name 

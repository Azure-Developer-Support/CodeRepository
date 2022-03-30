#The below PowerShell script helps to Update TLS Version for Storage Account.



#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service.
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including,
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages

rgName = "<resource-group>"
$accountName = "<storage-account>" 
$location = "<location>"
# Create a storage account with MinimumTlsVersion set to TLS 1.1. 
New-AzStorageAccount -ResourceGroupName $rgName `  -AccountName $accountName `  -Location $location `  -SkuName Standard_GRS `  -MinimumTlsVersion TLS1_1 
# Read the MinimumTlsVersion property. 
(Get-AzStorageAccount -ResourceGroupName $rgName -Name $accountName).MinimumTlsVersion 
# Update the MinimumTlsVersion version for the storage account to TLS 1.2. 
Set-AzStorageAccount -ResourceGroupName $rgName `  -AccountName $accountName `  -MinimumTlsVersion TLS1_2 
# Read the MinimumTlsVersion property. 
(Get-AzStorageAccount -ResourceGroupName $rgName -Name $accountName).MinimumTlsVersion

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#the script will help to check if the secured transfer required property(Enable HTTPS TrafficOnly) is enabled or disabled in all storage accounts in a subscription and export the data into a csv
#Please make sure to run the script as admin in powershell

Connect-AzAccount -Subscription "<Subscription_ID>"

# Get the list of all storage accounts and their HTTPS status
$storageAccounts = Get-AzStorageAccount | Select-Object ResourceGroupName, StorageAccountName, Location, EnableHttpsTrafficOnly 

# Write the data to a CSV file
$storageAccounts | Export-Csv -Path "C:/StorageAccountsHttpsStatus.csv" -NoTypeInformation
Write-Host "Storage account details exported to storageAccountsHttpsStatus.csv"

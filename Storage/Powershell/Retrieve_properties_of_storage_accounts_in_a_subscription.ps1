#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#The script will list properties(ResourceGroupName,StorageAccountName,Kind,CreationTime,Location,AccessTier,EnableHierarchicalNamespace,Redundancy) of all storage accounts in a subscription and export the data into a csv file
#Please make sure to run the script as Admin in powershell

Connect-AzAccount -Subscription "d684944d-2d18-4413-a83d-691540c8c768"

# Get the details of all storage accounts in the subscription
$storageAccounts = Get-AzStorageAccount

# Collect the required details
$storageDetails = $storageAccounts | Select-Object ResourceGroupName, StorageAccountName,Kind, CreationTime, Location, AccessTier,EnableHierarchicalNamespace ,  @{Name="Redundancy"; Expression={
    if ($_.Sku.Name -eq "Standard_LRS") {
        "Locally Redundant Storage (LRS)"
    } elseif ($_.Sku.Name -eq "Standard_ZRS") {
        "Zone Redundant Storage (ZRS)"
    } elseif ($_.Sku.Name -eq "Standard_GRS") {
        "Geo-Redundant Storage (GRS)"
    } elseif ($_.Sku.Name -eq "Standard_RAGRS") {
        "Read-Access Geo-Redundant Storage (RA-GRS)"
    } elseif ($_.Sku.Name -eq "Standard_RAGZRS") {
        "Read-Access Geo-Zone Redundant Storage (RA-GZRS)"
    } else {
        "Unknown"
    }
}}

# Export the details to a CSV file
$storageDetails | Export-Csv -Path "C:/storageaccountsDetails.csv" -NoTypeInformation

# Output the path of the CSV file
Write-Host "Storage account details exported to storageaccountsDetails.csv"

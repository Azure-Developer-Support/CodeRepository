###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########These scripts provide total number of blobs based on Tier for a storage account #########################


#Please update these value as per your scenario

$rg = Read-Host "`n Enter the name of your Resource Group: "
$sa = Read-Host "`n Enter the name of your Storage Account: "
$path = Read-Host "`n Enter the path where you want to keep the generated report: "
$strAccountName = "$sa"
$strAccountRG = "$rg"
# Connect to Az  Account
Connect-AzAccount
# Choose subscription
Select-AzSubscription -SubscriptionId "$subID"
# create context
$stCtx = New-AzStorageContext -StorageAccountName $strAccountName -StorageAccountKey ((Get-AzStorageAccountKey -ResourceGroupName $strAccountRG -Name $strAccountName).Value[0])
# fetch containers
$containers = Get-AzStorageContainer -Context $stCtx
# placeholder to hold file list
$array = @();
# outer loop
foreach($container in $containers)
{
    # fetch blobs in current container
    $blobs = Get-AzStorageBlob -Container $container.Name -Context $stCtx
    $array += ($blobs | Select-Object @{N='Container'; E={$_.ICloudBlob.Container.Name}}, Name, BlobType, AccessTier);
}
# Export to file
$array | Export-Csv -NoClobber -NoTypeInformation -Delimiter ";" -Path "$path\myblobreport.csv"

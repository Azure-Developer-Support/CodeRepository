#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#############Script Overview#################################################################
#This Azure CLI script determines how many days are left before the storage account access key needs to be rotated, based on the configured reminder days.

############################Script Sample 1#######################################

$days = az storage account show --name <--storage account Name--> --resource-group <--resource group name--> --query "keyPolicy.keyExpirationPeriodInDays"
$lastrotation = az storage account keys list --account-name mynewstorage11 --resource-group rg-storage --query "[].{LastRotated:creationTime}[0]" -o tsv

$lastrotation2 = [datetimeoffset]::Parse($lastrotation)
$currenttime = [datetimeoffset]::Parse((Get-Date).ToString("o"))

$daysremaining = ($currenttime - $lastrotation2).days

$data = $days-$daysremaining

if($data -le 1) {Write-Host "Rotate your storage account keys"}

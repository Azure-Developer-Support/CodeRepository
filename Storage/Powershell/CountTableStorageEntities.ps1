###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########This script provide steps to get the count of entities present in Azure Table Storage#########################
#Ref links:https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-how-to-use-powershell#query-the-table-entities

############################Script Sample 1#######################################

#This will help in getting the count of entities present in Azure Table Storage
#
#Please update <placeholders> as per your scenario

# Install the required Az modules if not already installed

if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    Install-Module -Name Az.Accounts -Force
}
if (-not (Get-Module -ListAvailable -Name Az.StorageTable)) {
    Install-Module -Name Az.StorageTable -Force
}

# Import the required Az modules

Import-Module -Name Az.Accounts -DisableNameChecking
Import-Module -Name Az.StorageTable -DisableNameChecking

#Function to set the storage account context 

function GetTable($connectionString, $tableName)
{
    $context = New-AzStorageContext -ConnectionString $connectionString
    $azureStorageTable = Get-AzStorageTable $tableName -Context $context
    $azureStorageTable.CloudTable
}

#Function to count the number of rows/entities in Table storage

function GetTableCount($table)

{
 (Get-AzTableRow -table $table | measure).Count    
}

#Setting Table connection details

$connectionString = "<storageaccountconnectionstring>"
$table = GetTable $connectionString "<tablename>"

#Outcome

$numberofentities=GetTableCount $table

Echo "Total number of entities in $table Table : $numberofentities"


#EndOfScript

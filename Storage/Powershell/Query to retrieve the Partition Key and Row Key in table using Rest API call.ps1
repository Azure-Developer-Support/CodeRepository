#Azure Storage Table - PowerShell
###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#############Script Overview#################################################################
##########This script is designed to fetch the Partition Key and Row Key in a table.#########################
##Script Starts##

$resourceGroup = "<ResourceGroup-Name>"
$storageAccount = "<Storage-Account-Name>"
$tableName = "<Table-Name>"

# Get token
$token = Get-AzAccessToken -ResourceUrl https://storage.azure.com/
$dateTime = (Get-Date -AsUTC).ToString('R')

# Build URI
$uri = "https://$storageAccount.table.core.windows.net/$tableName()? &`$select=PartitionKey,RowKey"

# Headers
$headers = @{
    'Authorization'      = "$($token.Type) $($token.Token)"
    'x-ms-date'          = $dateTime
    'x-ms-version'       = '2025-05-05'
    'Accept'             = 'application/json;odata=nometadata'
    'DataServiceVersion' = '3.0;NetFx'
}

# Make the request
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
$response.value | Select-Object PartitionKey, RowKey

##Script Ends##

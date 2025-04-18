#This script authenticates against an Azure storage account using Entra token and uses the REST API to perform an undelete operation against a soft delete blob

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#Authorization
Connect-AzAccount

# Define the storage account, container, and blob name
$storageAccountName = ""
$containerName = ""
$blobName = ""
$resourceGroup = ""

# Get the blob client
$blob = Get-AzStorageBlob -Container $containerName -Blob $blobName -Context (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName).Context -IncludeDeleted

# Get the access token
$token = Get-AzAccessToken -ResourceUrl "https://storage.azure.com/"

# Construct the URI for the undelete operation
$uri = "https://" + $blob.BlobClient.Uri.Host + $blob.BlobClient.Uri.AbsolutePath + "?comp=undelete"

# Set the headers with the authorization token
$headers = @{
    'Authorization' = "Bearer $($token.Token)"
    'x-ms-version' = '2021-12-02'  # Specify the latest storage API version
    'x-ms-date' = (Get-Date).ToUniversalTime().ToString("R")
    'Content-Length' = '0'  # Required for PUT operations without a body
}

# Try to undelete the blob
try {
    $res = Invoke-RestMethod -Method "Put" -Uri $uri -Headers $headers
    Write-Host "Blob undeleted successfully."
} catch {
    Write-Warning -Message "$($_.Exception.Message)" -ErrorAction Stop
}

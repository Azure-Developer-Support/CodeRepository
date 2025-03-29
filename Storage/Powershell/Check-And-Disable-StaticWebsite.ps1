# ====================================================================================
# Azure Storage - This script will enumerate storage accounts in a given subscription and output if the static website feature is enabled or disabled. 
# Also If Static Website enabled it will update it "false" as needed.Customer is welcome to update/modify the script according to their requirements.
# ====================================================================================
# Scrpt will use the MS Entra(ID) Auth, please ensure you have required RBAC roles as mentioned here https://learn.microsoft.com/en-us/azure/storage/blobs/authorize-access-azure-active-directory#azure-built-in-roles-for-blobs
# ====================================================================================
# DISCLAMER : please note that this script is to be considered as a sample and is provided as is with no warranties express or implied, even more considering this is about deleting data. 
# We really recommended to double check that list of filtered elements looks fine to you before processing with the deletion with the last line of the script.  
# This script should be tested in a dev environment before using in Production.
# ====================================================================================
# Define variables
$subscriptionId = "XXXXXXXXXXX"
# Login to Azure (If not already logged in)
Connect-AzAccount
# Set Subscription Context
Set-AzContext -SubscriptionId $subscriptionId

# Get all storage accounts in the subscription
$storageAccounts = Get-AzStorageAccount
# Get Access Token for Microsoft Entra ID Authentication
$token = (Get-AzAccessToken -ResourceUrl "https://storage.azure.com/").Token

# Iterate through each storage account
foreach ($storageAccount in $storageAccounts) {

    $storageAccountName = $storageAccount.StorageAccountName
    $resourceGroupName = $storageAccount.ResourceGroupName

    Write-Host "🔍 Checking Storage Account: $storageAccountName"

# Construct the REST API URL
$apiUrl = "https://$storageAccountName.blob.core.windows.net/?restype=service&comp=properties"

# Define Headers for the REST API Request
$headers = @{
    "Authorization" = "Bearer $token"
    "x-ms-version"  = "2021-12-02"
}

# Make API Call using Invoke-RestMethod
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction Stop
} catch {
    Write-Host "❌ Error: Unable to retrieve blob service properties. $_"
    exit
}

# Check if Response is Empty
if (-not $response) {
    Write-Host "❌ Error: API response is empty. Please check if the Storage Account exists and your permissions are correct."
    exit
}

# Ensure Response is String and Remove BOM if Necessary
$responseString = $response.ToString().Trim()

# Remove BOM (Byte Order Mark) if present
$responseString = $responseString -replace "^\xEF\xBB\xBF", ""

# Debug: Print first few characters to check BOM removal
Write-Host "🔍 Debug: First few characters of response after BOM removal: $($responseString.Substring(0, [math]::Min(100, $responseString.Length)))"

# Convert to XML Object
try {
    [xml]$xmlData = $responseString
} catch {
    Write-Host "❌ Error: Failed to parse XML response. $_"
    Write-Host "Raw Response: $responseString"
    exit
}

# Extract Static Website Enabled Property (Check if Exists)
if ($xmlData.StorageServiceProperties.StaticWebsite.Enabled) {
    $staticWebsiteEnabled = $xmlData.StorageServiceProperties.StaticWebsite.Enabled
} else {
    $staticWebsiteEnabled = "false" # Default if not present
}

# Output the Result
if ($staticWebsiteEnabled -eq "true") {
    Write-Host "✅ Static Website is ENABLED for storage account: $storageAccountName"

    try {
            Invoke-RestMethod -Uri $apiUrl -Method Put -Headers $headers -Body '<StorageServiceProperties><StaticWebsite><Enabled>false</Enabled></StaticWebsite></StorageServiceProperties>' -ContentType "application/xml" -ErrorAction Stop
            Write-Host "✅ Static Website DISABLED for $storageAccountName."
        } catch {
            Write-Host "❌ Error: Unable to disable Static Website for $storageAccountName. $_"
        }
} else {
    Write-Host "❌ Static Website is DISABLED for storage account: $storageAccountName"
}
}

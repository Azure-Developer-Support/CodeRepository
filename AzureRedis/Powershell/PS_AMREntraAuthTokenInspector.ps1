<#
.SYNOPSIS
    Validates an Entra ID token against an Azure Managed Redis Cache resource.

.DESCRIPTION
    This script decodes a JWT token and validates it for use with Azure Managed Redis Cache.
    It checks token claims, expiration, and verifies if the token's object ID has an
    access policy assignment on the specified Redis cache.
.DISCLAIMER
    The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. 
    Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
    The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
    without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

.PARAMETER Token
    The Entra ID JWT token to validate.

.PARAMETER ResourceId
    The Azure resource ID of the Managed Redis Cache.

.EXAMPLE
    .\Validate-RedisToken.ps1 -Token $token -ResourceId "/subscriptions/.../redisEnterprise/myCache"

.NOTES
    Requires Azure CLI (az) to be installed and authenticated.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "The Entra ID token to validate")]
    [ValidateNotNullOrEmpty()]
    [string]$Token,

    [Parameter(Mandatory = $true, HelpMessage = "The Azure Managed Redis Cache resource ID (e.g. /subscriptions/{id}/resourceGroups/{rg}/providers/Microsoft.Cache/redisEnterprise/{name})")]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Helper Functions

function Write-ColoredMessage {
    <#
    .SYNOPSIS
        Writes a colored message to the console with optional prefix.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ConsoleColor]$Color = 'White',

        [Parameter(Mandatory = $false)]
        [string]$Prefix = '',

        [Parameter(Mandatory = $false)]
        [int]$Indent = 0
    )

    $indentation = ' ' * $Indent
    $fullMessage = if ($Prefix) { "$indentation$Prefix $Message" } else { "$indentation$Message" }
    Write-Host $fullMessage -ForegroundColor $Color
}

function Write-SectionHeader {
    <#
    .SYNOPSIS
        Writes a section header to the console.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [ConsoleColor]$Color = 'Cyan'
    )

    Write-Host ""
    Write-Host "=====================================" -ForegroundColor $Color
    Write-Host $Title -ForegroundColor $Color
    Write-Host "=====================================" -ForegroundColor $Color
    Write-Host ""
}

function Get-DecodedJwtToken {
    <#
    .SYNOPSIS
        Decodes a JWT token and returns its payload as a PowerShell object.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Token
    )

    try {
        # Split the token into parts (header.payload.signature)
        $tokenParts = $Token.Split('.')
        if ($tokenParts.Count -ne 3) {
            throw "Invalid JWT token format. Expected 3 parts separated by dots, got $($tokenParts.Count)."
        }

        # Decode the payload (second part)
        $payload = $tokenParts[1]

        # Add padding if necessary for Base64 decoding
        $paddingLength = (4 - ($payload.Length % 4)) % 4
        if ($paddingLength -gt 0) {
            $payload += "=" * $paddingLength
        }

        # Replace URL-safe Base64 characters with standard Base64
        $payload = $payload.Replace('-', '+').Replace('_', '/')

        # Decode from Base64 and convert to UTF8 string
        $decodedBytes = [System.Convert]::FromBase64String($payload)
        $decodedJson = [System.Text.Encoding]::UTF8.GetString($decodedBytes)

        # Parse JSON and return as object
        return ($decodedJson | ConvertFrom-Json)
    }
    catch {
        throw "Failed to decode JWT token: $_"
    }
}

function Get-ResourceComponents {
    <#
    .SYNOPSIS
        Extracts components from an Azure resource ID.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceId
    )

    # Expected format: /subscriptions/{sub}/resourceGroups/{rg}/providers/{provider}/{type}/{name}[/databases/{db}]
    $pattern = '/subscriptions/([^/]+)/resourceGroups/([^/]+)/providers/([^/]+)/([^/]+)/([^/]+)'

    if ($ResourceId -notmatch $pattern) {
        throw "Invalid resource ID format. Expected: /subscriptions/{id}/resourceGroups/{name}/providers/{provider}/{type}/{name}"
    }

    return @{
        SubscriptionId = $Matches[1]
        ResourceGroup  = $Matches[2]
        Provider       = $Matches[3]
        ResourceType   = $Matches[4]
        ResourceName   = $Matches[5]
        FullResourceId = $ResourceId
    }
}

function Get-DatabaseNameFromResourceId {
    <#
    .SYNOPSIS
        Extracts the database name from a resource ID, defaulting to "default".
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResourceId
    )

    if ($ResourceId -match '/databases/([^/]+)$') {
        return $Matches[1]
    }
    return "default"
}

function Test-AzureCliInstalled {
    <#
    .SYNOPSIS
        Checks if Azure CLI is installed and accessible.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    return $null -ne (Get-Command az -ErrorAction SilentlyContinue)
}

function Get-AzureAccountInfo {
    <#
    .SYNOPSIS
        Gets the current Azure CLI account information.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    try {
        $accountJson = az account show 2>&1
        if ($LASTEXITCODE -eq 0) {
            return ($accountJson | ConvertFrom-Json)
        }
        return $null
    }
    catch {
        return $null
    }
}

function Set-AzureSubscription {
    <#
    .SYNOPSIS
        Sets the Azure CLI subscription context.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId
    )

    $result = az account set --subscription $SubscriptionId 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to switch to subscription $SubscriptionId : $result"
    }
}

function Get-AccessPolicyAssignments {
    <#
    .SYNOPSIS
        Gets access policy assignments for a Redis Enterprise cache.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroup,

        [Parameter(Mandatory = $true)]
        [string]$ClusterName,

        [Parameter(Mandatory = $true)]
        [string]$DatabaseName
    )

    $command = "az redisenterprise database access-policy-assignment list " +
    "--resource-group `"$ResourceGroup`" " +
    "--cluster-name `"$ClusterName`" " +
    "--database-name `"$DatabaseName`" 2>&1"

    $output = Invoke-Expression $command

    return @{
        Output    = ($output | Out-String)
        ExitCode  = $LASTEXITCODE
        RawOutput = $output
    }
}

function Test-ObjectIdInAssignments {
    <#
    .SYNOPSIS
        Checks if an object ID exists in the access policy assignments output.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputString,

        [Parameter(Mandatory = $true)]
        [string]$ObjectId
    )

    # Use regex escape to handle any special characters in the object ID
    return $OutputString -match [regex]::Escape($ObjectId)
}

#endregion

#region Validation Classes

class ValidationResult {
    [string[]]$Errors = @()
    [string[]]$Warnings = @()

    [void]AddError([string]$message) {
        $this.Errors += $message
    }

    [void]AddWarning([string]$message) {
        $this.Warnings += $message
    }

    [bool]HasErrors() {
        return $this.Errors.Count -gt 0
    }

    [bool]HasWarnings() {
        return $this.Warnings.Count -gt 0
    }

    [bool]IsSuccess() {
        return -not $this.HasErrors()
    }
}

#endregion

#region Main Validation Functions

function Test-TokenStructure {
    <#
    .SYNOPSIS
        Validates the basic structure and decodes the token.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Token,

        [Parameter(Mandatory = $true)]
        [ValidationResult]$ValidationResult
    )

    Write-ColoredMessage "Decoding JWT Token..." -Color Yellow

    try {
        $decodedToken = Get-DecodedJwtToken -Token $Token
        Write-ColoredMessage "Token decoded successfully" -Color Green -Prefix "✓"
        return $decodedToken
    }
    catch {
        $ValidationResult.AddError("Failed to decode token: $_")
        Write-ColoredMessage "Failed to decode token" -Color Red -Prefix "❌"
        return $null
    }
}

function Show-TokenClaims {
    <#
    .SYNOPSIS
        Displays token claims information.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$DecodedToken
    )

    Write-Host ""
    Write-ColoredMessage "Token Claims:" -Color Yellow
    Write-ColoredMessage "Audience (aud):     $($DecodedToken.aud)" -Color Gray -Indent 2
    Write-ColoredMessage "Issuer (iss):       $($DecodedToken.iss)" -Color Gray -Indent 2
    Write-ColoredMessage "Subject (sub):      $($DecodedToken.sub)" -Color Gray -Indent 2
    Write-ColoredMessage "App ID (appid):     $($DecodedToken.appid)" -Color Gray -Indent 2
    Write-ColoredMessage "Object ID (oid):    $($DecodedToken.oid)" -Color Gray -Indent 2

    if ($DecodedToken.exp) {
        $expirationTime = [DateTimeOffset]::FromUnixTimeSeconds($DecodedToken.exp).LocalDateTime
        Write-ColoredMessage "Expiration (exp):   $expirationTime" -Color Gray -Indent 2

        if ($expirationTime -lt (Get-Date)) {
            Write-ColoredMessage "WARNING: Token has expired!" -Color Yellow -Indent 2 -Prefix "⚠️"
        }
    }

    if ($DecodedToken.iat) {
        $issuedTime = [DateTimeOffset]::FromUnixTimeSeconds($DecodedToken.iat).LocalDateTime
        Write-ColoredMessage "Issued At (iat):    $issuedTime" -Color Gray -Indent 2
    }
}

function Test-TokenAudience {
    <#
    .SYNOPSIS
        Validates the token audience claim.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$DecodedToken,

        [Parameter(Mandatory = $true)]
        [ValidationResult]$ValidationResult
    )

    Write-Host ""
    Write-ColoredMessage "Validating Token Audience..." -Color Yellow

    $expectedAudiences = @(
        "https://redis.azure.com",
        "https://redis.azure.com/"
    )

    $audienceValid = $expectedAudiences -contains $DecodedToken.aud

    if ($audienceValid) {
        Write-ColoredMessage "Token audience '$($DecodedToken.aud)' is valid for Azure Managed Redis" -Color Green -Prefix "✓"
    }
    else {
        $ValidationResult.AddError("Token audience '$($DecodedToken.aud)' is not valid for Azure Managed Redis Cache")
        Write-ColoredMessage "Invalid audience" -Color Red -Prefix "❌"
        Write-ColoredMessage "Expected one of: $($expectedAudiences -join ', ')" -Color Red -Indent 3
        Write-ColoredMessage "Got: $($DecodedToken.aud)" -Color Red -Indent 3
    }
}

function Test-TokenIssuer {
    <#
    .SYNOPSIS
        Validates the token issuer claim.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$DecodedToken,

        [Parameter(Mandatory = $true)]
        [ValidationResult]$ValidationResult
    )

    Write-Host ""
    Write-ColoredMessage "Validating Token Issuer..." -Color Yellow

    if ($DecodedToken.iss -match 'https://sts\.windows\.net/([^/]+)/' -or
        $DecodedToken.iss -match 'https://login\.microsoftonline\.com/([^/]+)/v2\.0') {
        $tenantId = $Matches[1]
        Write-ColoredMessage "Token issued by Microsoft Entra ID for tenant: $tenantId" -Color Green -Prefix "✓"
    }
    else {
        $ValidationResult.AddError("Token issuer '$($DecodedToken.iss)' does not match expected Entra ID format")
        Write-ColoredMessage "Unexpected issuer format: $($DecodedToken.iss)" -Color Yellow -Prefix "⚠️"
    }
}

function Test-TokenExpiration {
    <#
    .SYNOPSIS
        Validates the token expiration.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$DecodedToken,

        [Parameter(Mandatory = $true)]
        [ValidationResult]$ValidationResult
    )

    Write-Host ""
    Write-ColoredMessage "Validating Token Expiration..." -Color Yellow

    if (-not $DecodedToken.exp) {
        $ValidationResult.AddWarning("Token does not contain expiration claim")
        Write-ColoredMessage "Token does not contain expiration claim" -Color Yellow -Prefix "⚠️"
        return
    }

    $expirationTime = [DateTimeOffset]::FromUnixTimeSeconds($DecodedToken.exp).LocalDateTime

    if ($expirationTime -lt (Get-Date)) {
        $ValidationResult.AddError("Token has expired at $expirationTime")
        Write-ColoredMessage "Token expired at $expirationTime" -Color Red -Prefix "❌"
    }
    else {
        $timeRemaining = $expirationTime - (Get-Date)
        $minutesRemaining = [Math]::Floor($timeRemaining.TotalMinutes)
        Write-ColoredMessage "Token is valid until $expirationTime ($minutesRemaining minutes remaining)" -Color Green -Prefix "✓"
    }
}

function Show-ValidationSummary {
    <#
    .SYNOPSIS
        Displays the validation summary with errors, warnings, and troubleshooting tips.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidationResult]$ValidationResult,

        [Parameter(Mandatory = $true)]
        [PSCustomObject]$DecodedToken
    )

    Write-SectionHeader "Validation Summary"

    if (-not $ValidationResult.HasErrors() -and -not $ValidationResult.HasWarnings()) {
        Write-ColoredMessage "All validations passed!" -Color Green -Prefix "✓"
        Write-ColoredMessage "The token appears to be valid for the provided Azure Managed Redis Cache resource." -Color Green -Indent 2
        return
    }

    if (-not $ValidationResult.HasErrors()) {
        Write-ColoredMessage "Validation completed with warnings:" -Color Yellow -Prefix "⚠️"
        foreach ($warning in $ValidationResult.Warnings) {
            Write-ColoredMessage "- $warning" -Color Yellow -Indent 2
        }
        Write-Host ""
        Write-ColoredMessage "The token may work, but there are some concerns to review." -Color Yellow
        return
    }

    # Has errors
    Write-ColoredMessage "Validation failed with errors:" -Color Red -Prefix "❌"
    foreach ($error in $ValidationResult.Errors) {
        Write-ColoredMessage "- $error" -Color Red -Indent 2
    }

    if ($ValidationResult.HasWarnings()) {
        Write-Host ""
        Write-ColoredMessage "Additional warnings:" -Color Yellow -Prefix "⚠️"
        foreach ($warning in $ValidationResult.Warnings) {
            Write-ColoredMessage "- $warning" -Color Yellow -Indent 2
        }
    }

    # Show troubleshooting tips - only for failed validations
    Write-Host ""
    Write-ColoredMessage "Troubleshooting Tips:" -Color Cyan

    $tipNumber = 1

    # Check if audience validation failed
    $audienceError = $ValidationResult.Errors | Where-Object { $_ -like "*audience*" }
    if ($audienceError) {
        Write-ColoredMessage "$tipNumber. Ensure the token was requested with the correct audience/scope:" -Color Gray -Indent 2
        Write-ColoredMessage "   - For data plane access: https://redis.azure.com/.default" -Color Gray -Indent 2
        Write-ColoredMessage "   - Example (PowerShell): `$token = (Get-AzAccessToken -ResourceUrl 'https://redis.azure.com').Token" -Color Gray -Indent 2
        Write-Host ""
        $tipNumber++
    }

    # Check if expiration validation failed
    $expirationError = $ValidationResult.Errors | Where-Object { $_ -like "*expired*" }
    if ($expirationError) {
        Write-ColoredMessage "$tipNumber. Token has expired. Request a new token:" -Color Gray -Indent 2
        Write-ColoredMessage "   - Tokens typically expire after 1 hour" -Color Gray -Indent 2
        Write-ColoredMessage "   - Re-authenticate or refresh your token" -Color Gray -Indent 2
        Write-Host ""
        $tipNumber++
    }

    # Check if access policy assignment validation failed
    $accessPolicyError = $ValidationResult.Errors | Where-Object { $_ -like "*access policy*" -or $_ -like "*object ID*NOT assigned*" }
    if ($accessPolicyError) {
        Write-ColoredMessage "$tipNumber. The user/service principal needs an access policy assignment:" -Color Gray -Indent 2
        Write-ColoredMessage "   - Get the Object ID (oid) from the token: $($DecodedToken.oid)" -Color Gray -Indent 2
        Write-ColoredMessage "   - Add an access policy assignment using Azure Portal or CLI" -Color Gray -Indent 2
        Write-Host ""
        Write-ColoredMessage "   Common access policy names:" -Color Gray -Indent 2
        Write-ColoredMessage "   • Data Owner: Full data access (read, write, delete)" -Color Gray -Indent 2
        Write-ColoredMessage "   • Data Contributor: Read and write access" -Color Gray -Indent 2
        Write-ColoredMessage "   • Data Reader: Read-only access" -Color Gray -Indent 2
        Write-Host ""
        $tipNumber++
    }

    # Check if resource not found error occurred
    $resourceNotFoundError = $ValidationResult.Errors | Where-Object { $_ -like "*not found*" }
    if ($resourceNotFoundError) {
        Write-ColoredMessage "$tipNumber. Verify the resource ID is correct:" -Color Gray -Indent 2
        Write-ColoredMessage "   - Check subscription ID, resource group name, and cache name" -Color Gray -Indent 2
        Write-ColoredMessage "   - Ensure you have access to the subscription" -Color Gray -Indent 2
        Write-Host ""
        $tipNumber++
    }

    # General tips if there are errors
    if ($ValidationResult.HasErrors()) {
        Write-ColoredMessage "$tipNumber. For programmatic access:" -Color Gray -Indent 2
        Write-ColoredMessage "   - Use DefaultAzureCredential with scope: https://redis.azure.com/.default" -Color Gray -Indent 2
        Write-ColoredMessage "   - Ensure the identity has an access policy assignment (not just RBAC role)" -Color Gray -Indent 2
        Write-ColoredMessage "   - Verify you're authenticated to the correct Azure tenant" -Color Gray -Indent 2
        Write-Host ""
    }
}

function Test-AccessPolicyAssignment {
    <#
    .SYNOPSIS
        Validates that the token's object ID has an access policy assignment.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$DecodedToken,

        [Parameter(Mandatory = $true)]
        [hashtable]$ResourceComponents,

        [Parameter(Mandatory = $true)]
        [string]$DatabaseName,

        [Parameter(Mandatory = $true)]
        [ValidationResult]$ValidationResult
    )

    Write-Host ""
    Write-ColoredMessage "Checking Access Policy Assignments (requires Azure CLI)..." -Color Yellow

    # Check Azure CLI installation
    if (-not (Test-AzureCliInstalled)) {
        $ValidationResult.AddWarning("Azure CLI not installed - skipping access policy validation")
        Write-ColoredMessage "Azure CLI (az) not installed. Skipping access policy validation." -Color Cyan -Prefix "ℹ️"
        Write-ColoredMessage "Install from: https://aka.ms/install-azure-cli" -Color Gray -Indent 3
        return
    }

    # Check Azure login
    $accountInfo = Get-AzureAccountInfo
    if (-not $accountInfo) {
        $ValidationResult.AddWarning("Not logged in to Azure - skipping access policy validation")
        Write-ColoredMessage "Not logged in to Azure. Run 'az login' to validate access policies" -Color Yellow -Prefix "⚠️"
        return
    }

    Write-ColoredMessage "Logged in to Azure as: $($accountInfo.user.name)" -Color Green -Prefix "✓"
    Write-ColoredMessage "Subscription: $($accountInfo.name) ($($accountInfo.id))" -Color Gray -Indent 2
    Write-ColoredMessage "Tenant: $($accountInfo.tenantId)" -Color Gray -Indent 2
    Write-Host ""

    # Switch subscription if needed
    if ($accountInfo.id -ne $ResourceComponents.SubscriptionId) {
        $ValidationResult.AddWarning("Current Azure CLI subscription does not match resource subscription")
        Write-ColoredMessage "CLI subscription doesn't match resource subscription. Switching..." -Color Yellow -Prefix "⚠️"

        try {
            Set-AzureSubscription -SubscriptionId $ResourceComponents.SubscriptionId
            Write-ColoredMessage "Switched to subscription: $($ResourceComponents.SubscriptionId)" -Color Green -Prefix "✓"
        }
        catch {
            $ValidationResult.AddError("Could not switch to subscription: $_")
            Write-ColoredMessage "Could not switch to subscription: $_" -Color Red -Prefix "❌"
            return
        }
    }

    # Check for object ID in token
    $tokenObjectId = $DecodedToken.oid
    if (-not $tokenObjectId) {
        $ValidationResult.AddWarning("Token does not contain 'oid' claim - cannot verify access policy assignment")
        Write-ColoredMessage "Token missing 'oid' claim - cannot verify access policy assignment" -Color Yellow -Prefix "⚠️"
        return
    }

    Write-ColoredMessage "Token Object ID (oid): $tokenObjectId" -Color Gray
    Write-Host ""
    Write-ColoredMessage "Retrieving access policy assignments from Redis cache..." -Color Yellow
    Write-ColoredMessage "Cluster: $($ResourceComponents.ResourceName)" -Color Gray -Indent 2
    Write-ColoredMessage "Database: $DatabaseName" -Color Gray -Indent 2
    Write-Host ""

    # Get access policy assignments
    try {
        $result = Get-AccessPolicyAssignments `
            -ResourceGroup $ResourceComponents.ResourceGroup `
            -ClusterName $ResourceComponents.ResourceName `
            -DatabaseName $DatabaseName

        if ($result.ExitCode -ne 0) {
            # Handle errors
            $errorOutput = $result.Output

            if ($errorOutput -match "ResourceNotFound|NotFound|could not be found") {
                $ValidationResult.AddError("Redis cache resource not found. Verify the resource ID is correct.")
                Write-ColoredMessage "Redis cache not found" -Color Red -Prefix "❌"
                Write-ColoredMessage "Error: $errorOutput" -Color Red -Indent 3
            }
            elseif ($errorOutput -match "AuthorizationFailed|Forbidden|does not have authorization") {
                $ValidationResult.AddWarning("Insufficient permissions to read access policy assignments")
                Write-ColoredMessage "Insufficient permissions to read access policies" -Color Yellow -Prefix "⚠️"
                Write-ColoredMessage "You need 'Reader' or higher role on the cache to view assignments." -Color Yellow -Indent 3
            }
            else {
                $ValidationResult.AddWarning("Could not retrieve access policy assignments: $errorOutput")
                Write-ColoredMessage "Could not retrieve access policy assignments" -Color Yellow -Prefix "⚠️"
                Write-ColoredMessage "Error: $errorOutput" -Color Yellow -Indent 3
            }
            return
        }

        # Check if output contains assignments
        $outputString = $result.Output
        if ($outputString -notmatch 'objectId|user') {
            $ValidationResult.AddError("No access policy assignments found for this Redis cache")
            Write-ColoredMessage "No access policy assignments configured for this cache" -Color Red -Prefix "❌"
            Write-ColoredMessage "The cache must have access policy assignments to accept token-based authentication." -Color Red -Indent 3
            return
        }

        # Check if token's object ID is in the assignments
        if (Test-ObjectIdInAssignments -OutputString $outputString -ObjectId $tokenObjectId) {
            Write-ColoredMessage "Token's object ID is assigned to the cache!" -Color Green -Prefix "✓"
            Write-ColoredMessage "Object ID: $tokenObjectId" -Color Green -Indent 2
            Write-ColoredMessage "The user/service principal has access to the cache." -Color Green -Indent 2
        }
        else {
            $ValidationResult.AddError("Token's object ID ($tokenObjectId) is NOT assigned to this cache")
            Write-ColoredMessage "Token's object ID is NOT found in access policy assignments" -Color Red -Prefix "❌"
            Write-ColoredMessage "Object ID from token: $tokenObjectId" -Color Red -Indent 3
            Write-ColoredMessage "This user/service principal does not have an access policy assignment." -Color Red -Indent 3
            Write-Host ""
            Write-ColoredMessage "To add an access policy assignment, run:" -Color Gray -Indent 3
            Write-ColoredMessage "az redisenterprise database access-policy-assignment create \" -Color Gray -Indent 3
            Write-ColoredMessage "  --resource-group `"$($ResourceComponents.ResourceGroup)`" \" -Color Gray -Indent 3
            Write-ColoredMessage "  --cluster-name `"$($ResourceComponents.ResourceName)`" \" -Color Gray -Indent 3
            Write-ColoredMessage "  --database-name `"$DatabaseName`" \" -Color Gray -Indent 3
            Write-ColoredMessage "  --access-policy-assignment-name `"$tokenObjectId`" \" -Color Gray -Indent 3
            Write-ColoredMessage "  --object-id `"$tokenObjectId`" \" -Color Gray -Indent 3
            Write-ColoredMessage "  --access-policy-name `"default`"" -Color Gray -Indent 3
        }
    }
    catch {
        $ValidationResult.AddWarning("Could not retrieve access policy assignments: $_")
        Write-ColoredMessage "Could not retrieve access policy assignments: $_" -Color Yellow -Prefix "⚠️"
    }
}

#endregion

#region Main Execution

try {
    Write-SectionHeader "Azure Managed Redis Token Validator"

    # Parse the resource ID
    Write-ColoredMessage "Parsing Resource ID..." -Color Yellow

    try {
        $resourceComponents = Get-ResourceComponents -ResourceId $ResourceId
        $databaseName = Get-DatabaseNameFromResourceId -ResourceId $ResourceId

        Write-ColoredMessage "Resource parsed successfully:" -Color Green -Prefix "✓"
        Write-ColoredMessage "Subscription ID: $($resourceComponents.SubscriptionId)" -Color Gray -Indent 2
        Write-ColoredMessage "Resource Group:  $($resourceComponents.ResourceGroup)" -Color Gray -Indent 2
        Write-ColoredMessage "Provider:        $($resourceComponents.Provider)" -Color Gray -Indent 2
        Write-ColoredMessage "Resource Type:   $($resourceComponents.ResourceType)" -Color Gray -Indent 2
        Write-ColoredMessage "Resource Name:   $($resourceComponents.ResourceName)" -Color Gray -Indent 2
        Write-Host ""
    }
    catch {
        Write-ColoredMessage "Failed to parse resource ID: $_" -Color Red -Prefix "❌"
        exit 1
    }

    # Initialize validation result
    $validationResult = [ValidationResult]::new()

    # Decode and validate token structure
    Write-Host ""
    $decodedToken = Test-TokenStructure -Token $Token -ValidationResult $validationResult
    if (-not $decodedToken) {
        exit 1
    }

    # Display token claims
    Show-TokenClaims -DecodedToken $decodedToken

    # Run all validations with fail-fast behavior
    # Test-TokenAudience -DecodedToken $decodedToken -ValidationResult $validationResult
    # if ($validationResult.HasErrors()) {
    #     Show-ValidationSummary -ValidationResult $validationResult -DecodedToken $decodedToken
    #     exit 1
    # }

    Test-TokenIssuer -DecodedToken $decodedToken -ValidationResult $validationResult
    if ($validationResult.HasErrors()) {
        Show-ValidationSummary -ValidationResult $validationResult -DecodedToken $decodedToken
        exit 1
    }

    Test-TokenExpiration -DecodedToken $decodedToken -ValidationResult $validationResult
    if ($validationResult.HasErrors()) {
        Show-ValidationSummary -ValidationResult $validationResult -DecodedToken $decodedToken
        exit 1
    }

    Test-AccessPolicyAssignment `
        -DecodedToken $decodedToken `
        -ResourceComponents $resourceComponents `
        -DatabaseName $databaseName `
        -ValidationResult $validationResult
    if ($validationResult.HasErrors()) {
        Show-ValidationSummary -ValidationResult $validationResult -DecodedToken $decodedToken
        exit 1
    }

    # All validations passed - display summary
    Show-ValidationSummary -ValidationResult $validationResult -DecodedToken $decodedToken

    if ($validationResult.HasWarnings()) {
        exit 0  # Success with warnings
    }

    exit 0  # Complete success
}
catch {
    Write-Host ""
    Write-ColoredMessage "An unexpected error occurred: $_" -Color Red -Prefix "❌"
    Write-ColoredMessage $_.ScriptStackTrace -Color Gray
    exit 1
}
finally {
    # Cleanup if needed
}

#endregion


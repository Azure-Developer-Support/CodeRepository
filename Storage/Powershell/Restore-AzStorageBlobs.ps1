<#
.SYNOPSIS

DISCLAIMER

The sample scripts are not supported under any Microsoft standard support
program or service. This is intended to be used in non-production enviornment
only. The sample scripts are provided AS IS without warranty of any kind.
Microsoft further disclaims all implied warranties including, without
limitation, any implied warranties of merchantability or of fitness for a
particular purpose. The entire risk arising out of the use or performance of
the sample scripts and documentation remains with you. In no event shall
Microsoft, its authors, owners of this github repro, or anyone else involved in
the creation, production, or delivery of the scripts be liable for any damages
whatsoever (including without limitation, damages for loss of business profits,
business interruption, loss of business information, or other pecuniary loss)
arising out of the use of or inability to use the sample scripts or
documentation, even if Microsoft has been advised of the possibility of such
damages.

This cmdlet can be used to attempt to restore soft-deleted and versioned blobs
in large batches.

.DESCRIPTION

This cmdlet can be used to attempt to restore soft-deleted and versioned blobs
in large batches.

See notes for more information.

.NOTES

Please DO NOT use this cmdlet for ADLS Gen 2 Storage Accounts or Storage
Acccounts with hierarchical namespace enabled. This script does not validate
the Storage Account type. Please use the officially supported cmdlets for
ADLS Gen 2 accounts:

Get-AzDataLakeGen2DeletedItem and Restore-AzDataLakeGen2DeletedItem

To recover ADLS Gen 2 Storage Account paths.

This cmdlet depends on the Azure PowerShell modules.

Please visit the following link to install Azure PowerShell:

https://learn.microsoft.com/powershell/azure/install-azure-powershell

This cmdlet also requires that Connect-AzAccount has been executed.

Authorization:

This cmdlet will attempt to use the connected account via Entra ID
authentication as a first attempt. If Entra ID fails to get a container's
properties or fetch blobs, it will attempt to fallback to using Azure Storage
Key. To disable this fallback behavior consider using the
-DisableStorageKeyFallback switch. As Entra ID is the recommended form
of authorization, please use an account that can:

List Containers
List Blobs
Undelete Blobs
Copy Blos

To have this cmdlet work with National Clouds, ensure to use

Connect-AzAccount -Environment AzureUSGovernment or
Connect-AzAccount -Environment AzureChinaCloud

.COMPONENT

Azure PowerShell
(https://learn.microsoft.com/powershell/azure/install-azure-powershell)


.PARAMETER Subscription

Optional. Use this parameter to redirect Azure PowerShell to a desired
subscription. This is a shortcut to running Select-AzSubscription

.PARAMETER ResourceGroupName

Required. Specify the Resource Group name where the impacted Storage Account
is located.

.PARAMETER StorageAccountName

Required. Specify the impacted Storage Account's name.

.PARAMETER ContainerName

Required. Specify the container name where the blobs were deleted.

For reference the container name is the first child segment of a Storage
Account URL. E.g.: 

https://storageAccountName.blob.core.windows.net/{ContaienrName}


The rest of the children are considered a blob path.

.PARAMETER PREFIX

Optional. Use this parameter to pre-filter the blobs by prefix.

.PARAMETER IncludeSuffix

Optional. Use this parameter to post-filter include blobs by suffix.

.PARAMETER ExcludeSuffix

Optional. Use this parameter to post-filter exclude blobs by suffix.

.PARAMETER ConcurrentTasks

Optional. Default: 100. Specify how large the parallelism can be used
for this cmdlet.

.PARAMETER DeletionStartTime

Optional. Filters soft-deleted blobs by their date deletion. NOTE:
This argument does not apply to blobs in previous version state.

.PARAMETER DeletionEndTime

Optional. Filters soft-deleted blobs by their date deletion. NOTE:
This argument does not apply to blobs in previous version state.

.PARAMETER DisableStorageKeyFallback

Optional. Use this switch if falling back to using Storage Keys is not desired.

.PARAMETER WhatIf

Optional. Highly recommended, run the cmdlet with the WhatIf filter to get a
list of blobs that would be affected. Blobs will have two (2) statuses:

- Deleted: These blobs will be undeleted.
- Previous Version: The latest previous version for the blob will be copied as
the new base blob.

.INPUTS

This cmdlet does not accept inouts.

.OUTPUTS

If using WhatIf a PSCustomObject with the following columns:

    Name: The Blob Path
    Status:
        Deleted: Blobs that would be undeleted
        Previous Version: Blobs that would be retored from the latest  
        previous version
    DeletedOn: The date the blob deletion took place

.EXAMPLE

Restore-AzStorageBlobs -ResourceGroupName rgName `
    -StorageAccountName storageAccountName -ContainerName containerName

.EXAMPLE

Restore-AzStorageBlobs -ResourceGroupName rgName `
    -StorageAccountName storageAccountName -ContainerName containerName `
    -WhatIf | Export-Csv -Path ".\recovery-attempt-whatif.csv"

.EXAMPLE

Restore-AzStorageBlobs -Subscription MySubscription -ResourceGroupName rgName `
    -StorageAccountName storageAccountName -ContainerName containerName `
    -Prefix debug/files -IncludeSuffix ".cs" -ExcludeSuffix ".csv" `
    -ConcurrentTasks 20 -DeletionStartTime "2024-08-30T00:00:00Z" `
    -DeletionEndTime "2024-08-31T00:00:00Z" -DisableStorageKeyFallback
    -WhatIf

.EXAMPLE

$subscription = "MySubscription"
$resourceGroupName = "MyResourceGroupName"
$storageAccountName = "mystorageaccount"

Connect-AzAccount
Select-AzSubscription -Subscription $subscription
$storageContext = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName).Context

Get-AzStorageContainer -Context $storageContext | ForEach-Object {
    Restore-AzStorageBlobs -ResourceGroupName $resourceGroupName `
        -StorageAccountName $storageAccountName -ContainerName $_
}

#>

function Restore-AzStorageBlobs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][String]$Subscription,
        [Parameter(Mandatory=$true)][String]$ResourceGroupName,
        [Parameter(Mandatory=$true)][String]$StorageAccountName,
        [Parameter(Mandatory=$true)][String]$ContainerName,
        [Parameter(Mandatory=$false)][String]$Prefix,
        [Parameter(Mandatory=$false)][String]$IncludeSuffix,
        [Parameter(Mandatory=$false)][String]$ExcludeSuffix,
        [Parameter(Mandatory=$false)][Int32]$ConcurrentTasks = 100,
        [Parameter(Mandatory=$false)][Nullable[DateTime]]$DeletionStartTime,
        [Parameter(Mandatory=$false)][Nullable[DateTime]]$DeletionEndTime,
        [Switch]$DisableStorageKeyFallback,
        [Switch]$WhatIf
    )
    begin {
        function Write-PSErrorRecord {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory=$true)][String]$CallingMethod,
                [Parameter(Mandatory=$true)][String]$Message,
                [Parameter(Mandatory=$true)][System.Management.Automation.ErrorCategory]$ErrorCategory
            )
            begin {
                $exceptionRecord = [System.Management.Automation.PSInvalidOperationException]::new("[$([DateTime]::UtcNow.ToString("s"))Z] $CallingMethod : $Message")
                $errorRecord = [System.Management.Automation.ErrorRecord ]::new($exceptionRecord, [String]::Empty, $ErrorCategory, $null)
            }
            process {
                Write-Error $errorRecord
            }
            end {
    
            }
        }

        function Write-DebugTS {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory=$true)][String]$CallingMethod,
                [Parameter(Mandatory=$false)][String]$Message
            )
            process {
                if($null -eq $Message -or $Message.Trim().Length -eq 0) {
                    Write-Debug "[$([DateTime]::UtcNow.ToString("s"))Z]"
                    return
                }
                
                Write-Debug "[$([DateTime]::UtcNow.ToString("s"))Z] $CallingMethod : $Message"
            }
        }

        function Write-WarningTS {
            param (
                [Parameter(Mandatory=$true)][String]$CallingMethod,
                [Parameter(Mandatory=$false)][String]$Message
            )
            process {
                if($null -eq $Message -or $Message.Trim().Length -eq 0) {
                    Write-Warning "[$([DateTime]::UtcNow.ToString("s"))Z]"
                    return
                }
                
                #$PSCmdlet | ConvertTo-Json -Depth 5
                Write-Warning "[$([DateTime]::UtcNow.ToString("s"))Z] $CallingMethod : $Message"
            }
        }

        function ConvertFrom-APIError {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory=$true)]$ErrorMessage
            )
            process {

                if(-not $ErrorMessage.Contains("x-ms-request-id:")) {
                    @{Type="PlainError"; "Message"=$ErrorMessage} | ConvertTo-Json -Depth 5 | ConvertFrom-Json
                    return
                }

                $splitOptions = [System.StringSplitOptions]::RemoveEmptyEntries -bor [System.StringSplitOptions]::TrimEntries
                $lineSplit = $ErrorMessage.Split("`n", $splitOptions)
                $result = @{}
                $nextKey = $null
                $result.Add("Type", "StorageError")
                $result.Add("Message", $lineSplit[0])
                $lineSplit | ForEach-Object {
                    $line = $_
                    if($null -eq $nextKey) {
                        if(($match = [System.Text.RegularExpressions.Regex]::Match($line, "^x-ms-request-id: (?<requestId>.*)$")).Success) {
                            $result.Add("RequestId", $match.Groups["requestId"].Value)
                        }
                        elseif(($match = [System.Text.RegularExpressions.Regex]::Match($line, "^Time:(.*)$")).Success -and -not $line.Contains("<")) {
                            $result.Add("Time", $match.Value)
                        }
                        elseif(($match = [System.Text.RegularExpressions.Regex]::Match($line, "^Status: (?<statusCode>\d\d\d) .*$")).Success) {
                            $result.Add("StatusCode", [Int32]::Parse($match.Groups["statusCode"].Value))
                        }
                        elseif(($match = [System.Text.RegularExpressions.Regex]::Match($line, "^ErrorCode: (?<errorCode>.*)$")).Success) {
                            $result.Add("ErrorCode", $match.Groups["errorCode"].Value)
                        }
                        elseif($line.StartsWith("Additional Information:")) {
                            $nextKey = "AdditionalInformation"
                        }
                    }
                    else {
                        $result.Add($nextKey, $line)
                        $nextKey = $null
                    }
                }
                $result | ConvertTo-Json -Depth 100 -Compress | ConvertFrom-Json
            }
        }

        function Invoke-BlobRecovery {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory=$true)][Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob]$Blob,
                [Parameter(Mandatory=$true)][Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageContainer]$Container,
                [Parameter(Mandatory=$true)][Int32]$ConcurrentTasks,
                [Parameter(Mandatory=$true)][Bool]$WhatIf,
                [Parameter(Mandatory=$true)][PSCustomObject]$TaskList,
                [Parameter(Mandatory=$true)][PSCustomObject]$TaskStatus,
                [Parameter(Mandatory=$false)][Nullable[DateTime]]$DeletionStartTime,
                [Parameter(Mandatory=$false)][Nullable[DateTime]]$DeletionEndTime
            )
            begin {
                if($Blob.IsDeleted -and $null -eq $Blob.SnapshotTime) {
                    if($null -eq $Blob.versionId) {
                        $startTimeIsValid = ($null -eq $DeletionStartTime)
                        $endTimeIsValid = ($null -eq $DeletionEndTime)
                        if(-not $startTimeIsValid) { $startTimeIsValid = ($DeletionStartTime.ToUniversalTime() -le $Blob.ListBlobProperties.Properties.DeletedOn.UtcDateTime)}
                        if(-not $endTimeIsValid) { $endTimeIsValid = ($Blob.ListBlobProperties.Properties.DeletedOn.UtcDateTime -le $DeletionEndTime.ToUniversalTime())}

                        if($startTimeIsValid -and $endTimeIsValid) {
                            if($WhatIf) {
                                [PSCustomObject]@{Name=$Blob.Name;Status="Deleted";DeletedOn=$Blob.ListBlobProperties.Properties.DeletedOn}
                            }
                            else {
                                try {
                                    $resultFromPreviousTask = $null
                                    if($TaskList.Tasks.Count -ge $ConcurrentTasks) {
                                        for($i = $TaskList.Tasks.Count - 1; $i -ge 0; $i--) {
                                            if($TaskList.Tasks[$i].Status -eq "RanToCompletion") {
                                                $TaskList.Tasks.RemoveAt($i)
                                                $TaskStatus.Completed += 1
                                            }
                                            elseif($TaskList.Tasks[$i].Status -eq "Faulted") {
                                                $TaskList.Tasks.RemoveAt($i)
                                                $TaskStatus.Failed += 1
                                            }
                                        }
                                    }
                                    $TaskStatus.Total += 1
                                    [Diagnostics.Trace]::Listeners.Clear()
                                    $TaskList.Tasks.Add($Blob.BlobClient.UndeleteAsync()) | Out-Null
                                    [Diagnostics.Trace]::Listeners.Clear()
                                    $TaskStatus.Active = ($TaskList.Tasks | Where-Object { $_.Status -eq "Running" -or $_.Status -eq "WaitingForActivation" -or $_.Status -eq "Created" }).Count
                                    $resultFromPreviousTask
                                }
                                catch {
                                }
                            }
                        }
                    }
                    elseif (-not $blob.IsLatestVersion) {

                        $startTimeIsValid = ($null -eq $DeletionStartTime)
                        $endTimeIsValid = ($null -eq $DeletionEndTime)
                        if(-not $startTimeIsValid) { $startTimeIsValid = ($DeletionStartTime.ToUniversalTime() -le $Blob.ListBlobProperties.Properties.DeletedOn.UtcDateTime)}
                        if(-not $endTimeIsValid) { $endTimeIsValid = ($Blob.ListBlobProperties.Properties.DeletedOn.UtcDateTime -le $DeletionEndTime.ToUniversalTime())}
                        
                        if($startTimeIsValid -and $endTimeIsValid) {
                            if($WhatIf) {
                                [PSCustomObject]@{Name=$Blob.Name;Status="Deleted";DeletedOn=$Blob.ListBlobProperties.Properties.DeletedOn}
                            }
                            else {
                                if($TaskList.Tasks.Count -ge $ConcurrentTasks) {
                                    for($i = $TaskList.Tasks.Count - 1; $i -ge 0; $i--) {
                                        if($TaskList.Tasks[$i].Status -eq "RanToCompletion") {
                                            $TaskList.Tasks.RemoveAt($i)
                                            $TaskStatus.Completed += 1
                                        }
                                        elseif($TaskList.Tasks[$i].Status -eq "Faulted") {
                                            $TaskList.Tasks.RemoveAt($i)
                                            $TaskStatus.Failed += 1
                                        }
                                    }
                                }
                                $TaskStatus.Total += 1
                                [Diagnostics.Trace]::Listeners.Clear()
                                $TaskList.Tasks.Add([StorageBlobHelper]::UndeleteAndCopyAsync($Blob)) | Out-Null
                                [Diagnostics.Trace]::Listeners.Clear()
                                $TaskStatus.Active = ($TaskList.Tasks | Where-Object { $_.Status -eq "Running" -or $_.Status -eq "WaitingForActivation" -or $_.Status -eq "Created" }).Count
                            }
                        }
                    }
                }
                elseif($null -ne $Blob.VersionId -and -not $blob.IsLatestVersion) {
                    if($WhatIf) {
                        [PSCustomObject]@{Name=$Blob.Name;Status="Previous Version";DeletedOn=$null}
                    }
                    else {
                        try {
                            if($TaskList.Tasks.Count -ge $ConcurrentTasks) {
                                while([System.Threading.Tasks.Task]::WaitAny($TaskList.Tasks, 10) -eq -1){}
                                for($i = $TaskList.Tasks.Count - 1; $i -ge 0; $i--) {
                                    if($TaskList.Tasks[$i].Status -eq "RanToCompletion") {
                                        $TaskList.Tasks.RemoveAt($i)
                                        $TaskStatus.Completed += 1
                                    }
                                    elseif($TaskList.Tasks[$i].Status -eq "Faulted") {
                                        $TaskList.Tasks.RemoveAt($i)
                                        $TaskStatus.Failed += 1
                                    }
                                }
                            }
                            
                            $destinationBlobUri = $blob.BlobClient.Uri.AbsoluteUri.Substring(0, $blob.BlobClient.Uri.AbsoluteUri.IndexOf("?"))
                            $destinationBlobClient = $(
                                switch($blob.BlobType) {
                                    "PageBlob" { [Azure.Storage.Blobs.Specialized.PageBlobClient]::new($destinationBlobUri,$Blob.Context.Track2OauthToken) }
                                    "AppendBlob" { [Azure.Storage.Blobs.Specialized.AppendBlobClient]::new($destinationBlobUri, $Blob.Context.Track2OauthToken) }
                                    default { [Azure.Storage.Blobs.Specialized.BlockBlobClient]::new($destinationBlobUri, $Blob.Context.Track2OauthToken) } 
                                }
                            )
                            $copyOptions = [Azure.Storage.Blobs.Models.BlobCopyFromUriOptions]::new()
                            if(-not $Blob.BlobProperties.AccessTierInferred) {
                                $copyOptions.AccessTier = $Blob.BlobProperties.AccessTier
                            }
                            $copyOptions.CopySourceTagsMode = "Copy"
                            $TaskStatus.Total += 1
                            [Diagnostics.Trace]::Listeners.Clear()
                            $TaskList.Tasks.Add($destinationBlobClient.StartCopyFromUriAsync($Blob.BlobClient.Uri, $copyOptions)) | Out-Null
                            [Diagnostics.Trace]::Listeners.Clear()
                            $TaskStatus.Active = ($TaskList.Tasks | Where-Object { $_.Status -eq "Running" -or $_.Status -eq "WaitingForActivation" -or $_.Status -eq "Created" }).Count
                        }
                        catch {
                            $TaskStatus.Failed += 1
                        }
                    }
                }
            }
            process {
            }
            end {

            }
        }

        [System.Threading.ThreadPool]::SetMinThreads(300, 300) | Out-Null

        Write-Host

        $skipProcessing = $false
        $fallbackToKeyAuth = $false
        $originalProgressPreference = $ProgressPreference
        $ProgressPreference = "SilentlyContinue"

        [System.Diagnostics.Stopwatch]$measure = [System.Diagnostics.Stopwatch]::new()
        $measure.Start()

        # Checking if the Azure PowerShell cmdlets are available
        $tempErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        $azurePowerShellIsLoaded = $(try { if(Get-Command "Connect-AzAccount") { $true } } catch { $false } )
        $ErrorActionPreference = $tempErrorActionPreference

        if(-not $azurePowerShellIsLoaded) {
            Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name `
                "Azure PowerShell was not discovered as the 'Connect-AzAccount' command was not found. " `
                + "This cmdlet was written with a dependency on Azure PowerShell. " `
                + "Please go to 'https://learn.microsoft.com/powershell/azure/install-azure-powershell' to ensure the module is installed." `
                -ErrorCategory NotInstalled
            $skipProcessing = $true
            return
        }

        # Checking if the context is set
        $azureContext = Get-AzContext
        if($null -eq $azureContext -or $null -eq $azureContext.Account) {
            Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "Run Connect-AzAccount to login." `
                -ErrorCategory AuthenticationError
            $skipProcessing = $true
            return
        }

        # If a subscription is provided and it's different than the context subscription, try to switch to it
        if($null -ne $Subscription -and $Subscription.Trim().Length -gt 0 -and $azureContext.Subscription.Id -ne $Subscription -and $azureContext.Subscription.Name -ne $Subscription.Trim()) {
            Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name "Current context subscription '$($context.Subscription.Name) (ID: $($context.Subscription.Id))' is not the same as the specified subscription '$Subscription'. Will be switching the subscription in the context."
            
            $subscriptionError = $null
            $subscription = $(try { Select-AzSubscription -Subscription $Subscription -ErrorAction Stop } catch { $subscriptionError = $_; $null } )
            if($null -ne $subscriptionError) {
                Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "Could not switch to subscription '$Subscription': $($subscriptionError.Exception.Message)." `
                    -ErrorCategory AuthenticationError
                $skipProcessing = $true
                return
            }
        }

        [Diagnostics.Trace]::Listeners.Clear()
        $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount
        
        [Diagnostics.Trace]::Listeners.Clear()
        $containerError = $null
        $blobContainer = $(try { Get-AzStorageContainer -Name $ContainerName -Context $storageContext -ErrorAction Stop } catch { $containerError = $_; $null })
        
        # Validate that we can find and access the container
        if($null -eq $blobContainer -or $null -ne $containerError) {
            $parsedError = ConvertFrom-APIError -ErrorMessage $containerError.Exception.Message
            if($parsedError.Type -eq "PlainError") {
                Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "$($parsedError.Message)" -ErrorCategory ProtocolError
                $skipProcessing = $true
                return
            }
            else {
                $errorMessage = "Error while checking for container access and existence. Message: $($parsedError.Message)"
                if($null -ne $parsedError.RequestId) { $errorMessage += " Request ID: $($parsedError.RequestId)."  }
                if($null -ne $parsedError.Time) { $errorMessage += " Time: $($parsedError.Time)."  }
                if($null -ne $parsedError.StatusCode) { $errorMessage += " StatusCode: $($parsedError.StatusCode)."  }
                if($null -ne $parsedError.ErrorCode) { $errorMessage += " Error Code: $($parsedError.RequestId)."  }
                if($null -ne $parsedError.AdditionalInformation) { $errorMessage += " Additional Information: $($parsedError.AdditionalInformation)"  }

                if($parsedError.StatusCode -eq 401 -or $parsedError.StatusCode -eq 403) {
                    if($PSBoundParameters.ContainsKey("DisableStorageKeyFallback") -and $DisableStorageKeyFallback) {
                        Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message $errorMessage -ErrorCategory PermissionDenied
                        $skipProcessing = $true
                        return
                    }
                    else {
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name $errorMessage
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name "WILL ATTEMPT TO FALLBACK TO USING STORAGE KEY."
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name "IF THIS IS NOT DESIRED, STOP THE COMMAND AND RUN IT WITH -DisableStorageKeyFallback"
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name

                        $fallbackToKeyAuth = $true
                        $storageAccountError = $null;
                        $StorageAccount = $(try { Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction Stop; } catch { $storageAccountError = $_; $null })
            
                        $parsedError = $null
                        if($null -eq $StorageAccount -or $null -ne $storageAccountError) {
                            $parsedError = ConvertFrom-APIError -ErrorMessage $storageAccountError.Exception.Message
                            Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "$($parsedError.Message)" -ErrorCategory ProtocolError
                            $skipProcessing = $true
                            return
                        }
                        elseif($null -eq $StorageAccount.Context.ConnectionString -or -not $StorageAccount.Context.ConnectionString.Contains("AccountKey=")) {
                            Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "Could not list the Storage Account Keys." -ErrorCategory ProtocolError
                            $skipProcessing = $true
                            return
                        }

                        $storageContext = $StorageAccount.Context
                        $parsedError = $null
                        $blobContainer = $(try { Get-AzStorageContainer -Name $ContainerName -Context $storageContext -ErrorAction Stop } catch { $containerError = $_; $null })
                        if($null -eq $blobContainer -or $null -ne $containerError) {
                            $parsedError = ConvertFrom-APIError -ErrorMessage $containerError.Exception.Message
                            if($parsedError.Type -eq "PlainError") {
                                Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "$($parsedError.Message)" -ErrorCategory ProtocolError
                            }
                            else {
                                $errorMessage = "Error while checking for container access and existence. Message: $($parsedError.Message)"
                                if($null -ne $parsedError.RequestId) { $errorMessage += " Request ID: $($parsedError.RequestId)."  }
                                if($null -ne $parsedError.Time) { $errorMessage += " Time: $($parsedError.Time)."  }
                                if($null -ne $parsedError.StatusCode) { $errorMessage += " StatusCode: $($parsedError.StatusCode)."  }
                                if($null -ne $parsedError.ErrorCode) { $errorMessage += " Error Code: $($parsedError.RequestId)."  }
                                if($null -ne $parsedError.AdditionalInformation) { $errorMessage += " Additional Information: $($parsedError.AdditionalInformation)"  }
            
                                Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message $errorMessage -ErrorCategory ProtocolError
                            }
                            $skipProcessing = $true
                            return
                        }
                    }
                }
                else {
                    Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message $errorMessage -ErrorCategory ProtocolError
                    $skipProcessing = $true
                    return
                }
            }
        }

        # Validate that we can find and access at least 1 blob in the container
        $blobError = $null
        $parsedError = $null
        $testBlob = $(try { Get-AzStorageBlob -Container $ContainerName -MaxCount 1 -Context $storageContext -IncludeVersion -IncludeDeleted -Prefix $Prefix -ErrorAction Stop } catch { $blobError = $_; $null})
        if($null -eq $testBlob -or $null -ne $blobError) {
            $parsedError = ConvertFrom-APIError -ErrorMessage $blobError.Exception.Message
            if($parsedError.Type -eq "PlainError") {
                Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "$($parsedError.Message)" -ErrorCategory ProtocolError
                $skipProcessing = $true
                return
            }
            else {
                $errorMessage = "Error while checking for list blob access. Message: $($parsedError.Message)"
                if($null -ne $parsedError.RequestId) { $errorMessage += " Request ID: $($parsedError.RequestId)."  }
                if($null -ne $parsedError.Time) { $errorMessage += " Time: $($parsedError.Time)."  }
                if($null -ne $parsedError.StatusCode) { $errorMessage += " StatusCode: $($parsedError.StatusCode)."  }
                if($null -ne $parsedError.ErrorCode) { $errorMessage += " Error Code: $($parsedError.RequestId)."  }
                if($null -ne $parsedError.AdditionalInformation) { $errorMessage += " Additional Information: $($parsedError.AdditionalInformation)"  }

                if($parsedError.StatusCode -eq 401 -or $parsedError.StatusCode -eq 403) {
                    if(($PSBoundParameters.ContainsKey("DisableStorageKeyFallback") -and $DisableStorageKeyFallback) -or $fallbackToKeyAuth) {
                        Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message $errorMessage -ErrorCategory PermissionDenied
                        $skipProcessing = $true
                        return
                    }
                    else {
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name $errorMessage
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name "WILL ATTEMPT TO FALLBACK TO USING STORAGE KEY."
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name "IF THIS IS NOT DESIRED, STOP THE COMMAND AND RUN IT WITH -DisableStorageKeyFallback"
                        Write-WarningTS -CallingMethod $MyInvocation.MyCommand.Name
                        $fallbackToKeyAuth = $true

                        $parsedError = $null
                        $storageAccountError = $null;
                        $StorageAccount = $(try { Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction Stop; } catch { $storageAccountError = $_; $null })
        
                        if($null -eq $StorageAccount -or $null -ne $storageAccountError) {
                            $parsedError = ConvertFrom-APIError -ErrorMessage $storageAccountError.Exception.Message
                            Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "$($parsedError.Message)" -ErrorCategory ProtocolError
                            $skipProcessing = $true
                            return
                        }
                        elseif($null -eq $StorageAccount.Context.ConnectionString -or -not $StorageAccount.Context.ConnectionString.Contains("AccountKey=")) {
                            Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "Could not list the Storage Account Keys." -ErrorCategory ProtocolError
                            $skipProcessing = $true
                            return
                        }
            
                        $storageContext = $StorageAccount.Context
                        $blobError = $null
                        $parsedError = $null
                        $testBlob = $(try { Get-AzStorageBlob -Container $ContainerName -MaxCount 1 -Context $storageContext -IncludeVersion -IncludeDeleted -Prefix $Prefix -ErrorAction Stop } catch { $blobError = $_; $null})
                        if($null -eq $testBlob -or $null -ne $blobError) {
                            $parsedError = ConvertFrom-APIError -ErrorMessage $blobError.Exception.Message
                            if($parsedError.Type -eq "PlainError") {
                                Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "$($parsedError.Message)" -ErrorCategory ProtocolError
                            }
                            else {
                                $errorMessage = "Error while checking for list blob access. Message: $($parsedError.Message)"
                                if($null -ne $parsedError.RequestId) { $errorMessage += " Request ID: $($parsedError.RequestId)."  }
                                if($null -ne $parsedError.Time) { $errorMessage += " Time: $($parsedError.Time)."  }
                                if($null -ne $parsedError.StatusCode) { $errorMessage += " StatusCode: $($parsedError.StatusCode)."  }
                                if($null -ne $parsedError.ErrorCode) { $errorMessage += " Error Code: $($parsedError.RequestId)."  }
                                if($null -ne $parsedError.AdditionalInformation) { $errorMessage += " Additional Information: $($parsedError.AdditionalInformation)"  }
            
                                Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message $errorMessage -ErrorCategory ProtocolError
                            }
                            $skipProcessing = $true
                            return
                        }
                    }
                }
                else {
                    Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message $errorMessage -ErrorCategory ProtocolError
                    $skipProcessing = $true
                    return
                }
            }
        }

        $TaskList = [PSCustomObject]@{
            Tasks = [System.Collections.ArrayList]::new()
        }

        $TaskStatus = [PSCustomObject]@{
            Total = 0
            Active = 0
            Completed = 0
            Failed = 0
        }

        $code = @"
        public class StorageBlobHelper {
        
            public static System.Threading.Tasks.Task<Azure.Storage.Blobs.Models.CopyFromUriOperation> UndeleteAndCopyAsync(
                Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob Blob
            ) {
                return UndeleteAndCopyAsync(Blob, System.Threading.CancellationToken.None);
            }
        
            public static System.Threading.Tasks.Task<Azure.Storage.Blobs.Models.CopyFromUriOperation> UndeleteAndCopyAsync(
                Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob Blob,
                System.Threading.CancellationToken cancellationToken) {
        
                if(null == Blob) {
                    throw new System.ArgumentNullException("Blob");
                }
        
                var undeleteTask = Blob.BlobClient.UndeleteAsync(cancellationToken);
                while(!undeleteTask.Wait(20)){}
                var result = undeleteTask.GetAwaiter().GetResult();

                if(result.Status == 200) {
        
                    System.Uri destinationBlobUri = new System.Uri( Blob.BlobClient.Uri.AbsoluteUri.Substring(0, Blob.BlobClient.Uri.AbsoluteUri.IndexOf("?")));
                    Azure.Storage.Blobs.Specialized.BlobBaseClient destinationBlobClient;
                    Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext context = (Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext)Blob.Context;

                    switch(Blob.BlobType) {
                        case Microsoft.Azure.Storage.Blob.BlobType.PageBlob:
                            destinationBlobClient = new Azure.Storage.Blobs.Specialized.PageBlobClient(destinationBlobUri, context.Track2OauthToken);
                            break;
                        case Microsoft.Azure.Storage.Blob.BlobType.AppendBlob:
                            destinationBlobClient = new Azure.Storage.Blobs.Specialized.AppendBlobClient(destinationBlobUri, context.Track2OauthToken);
                            break;
                        default:
                            destinationBlobClient = new Azure.Storage.Blobs.Specialized.BlockBlobClient(destinationBlobUri, context.Track2OauthToken);
                            break;
                    }
        
                    Azure.Storage.Blobs.Models.BlobCopyFromUriOptions copyOptions = new Azure.Storage.Blobs.Models.BlobCopyFromUriOptions();
                    copyOptions.CopySourceTagsMode = Azure.Storage.Blobs.Models.BlobCopySourceTagsMode.Copy;
                    if(!Blob.BlobProperties.AccessTierInferred) {
                        copyOptions.AccessTier = Blob.BlobProperties.AccessTier;
                    }
        
                    return destinationBlobClient.StartCopyFromUriAsync(Blob.BlobClient.Uri, copyOptions, cancellationToken);
                }

                throw new System.Exception("UndeleteAndCopyAsync failed");
            }
        }
"@

        $assemblies = [System.Collections.Generic.List[String]]::new()
        $assemblies.Add($blobContainer.GetType().Assembly.Location) | Out-Null
        $assemblies.Add($blobcontainer.BlobContainerClient.Exists().GetType().Assembly.Location) | Out-Null
        $assemblies.Add((Join-Path -Path (Split-Path -Path $storageContext.StorageAccount.Credentials.GetType().Assembly.Location) -ChildPath Azure.Storage.Common.dll)) | Out-Null
        $assemblies.Add([Azure.Storage.Blobs.Models.BlobCopyFromUriOptions].Assembly.Location) | Out-Null
        $assemblies.Add([Microsoft.Azure.Storage.Blob.BlobType].Assembly.Location) | Out-Null
        $assemblies.Add([Microsoft.Azure.Commands.Common.Authentication.Abstractions.IStorageContext].Assembly.Location) | Out-Null
        $assemblies.Add([System.Uri].Assembly.Location) | Out-Null
        $assemblies.Add([Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBase].Assembly.Location) | Out-Null
        $assemblies.Add([System.Threading.CancellationToken].Assembly.Location) | Out-Null
        $assemblies.Add((Join-Path -Path (Split-Path -Path ([System.Object].Assembly.Location)) -ChildPath netstandard.dll)) | Out-Null

        $tempwp = $WarningPreference
        $WarningPreference = "SilentlyContinue"

        try {
            if($PSVersionTable.PSEdition -eq "Desktop") {
                $netStandardPath = (Join-Path (Split-Path ([Object].Assembly.Location)) "netstandard.dll")
                if(Test-Path $netStandardPath) {
                    $assemblies.Add($netStandardPath) | Out-Null    
                }
            }
            else {
                $assemblies.Add((Join-Path -Path (Split-Path -Path ([System.Uri].Assembly.Location)) -ChildPath netstandard.dll)) | Out-Null
            }

            Add-Type -TypeDefinition $code -ReferencedAssemblies $assemblies.ToArray() -IgnoreWarnings
        }
        catch {
        }
        finally {
            $WarningPreference = $tempwp
        }

    }
    process {

        if($skipProcessing -or $null -eq $blobContainer) { return }

        if(-not $WhatIf) {
            $title = "Will attempt to restore blobs on the '$ContainerName' container on the Storage Account named '$StorageAccountName'. If this script was meant to verify which blobs would be recovered, please use the -WhatIf switch. Are you sure you want to proceed with restoring?"
            $choices = "&Yes", "&No"

            $decision = $Host.UI.PromptForChoice("Confirm Blob Recovery", $title, $choices, 1)

            if($decision -eq 1) {
                Write-PSErrorRecord -CallingMethod $MyInvocation.MyCommand.Name -Message "Blob recovery was cancelled by user." -ErrorCategory OperationStopped
                return
            }
        }

        $continuationToken = $null
        $previousBlob = $null
        $currentBlob = $null
        $count = 0
        $sw = [System.Diagnostics.Stopwatch]::new()
        $sw.Start()

        do {
            [Diagnostics.Trace]::Listeners.Clear()
            Get-AzStorageBlob -Container $ContainerName -MaxCount 5000 -Context $storageContext `
                -ContinuationToken $continuationToken -IncludeVersion -IncludeDeleted -Prefix $Prefix `
                | Where-Object { [String]::IsNullOrEmpty($IncludeSuffix) -or $_.Name -like "*$IncludeSuffix" } `
                | Where-Object { [String]::IsNullOrEmpty($ExcludeSuffix) -or $_.Name -notlike "*$ExcludeSuffix" } `
                | ForEach-Object {

                $currentBlob = $_
                $continuationToken = $currentBlob.ContinuationToken

                if($null -ne $previousBlob -and $currentBlob.Name -ne $previousBlob.Name) {
                    [Diagnostics.Trace]::Listeners.Clear()
                    Invoke-BlobRecovery -Blob $previousBlob -Container $blobContainer -WhatIf $WhatIf -TaskList $TaskList -TaskStatus $TaskStatus `
                        -ConcurrentTasks $ConcurrentTasks -DeletionStartTime $DeletionStartTime -DeletionEndTime $DeletionEndTime
                    $count = $count + 1

                    if($sw.Elapsed.TotalMilliseconds -gt 500) {
                        $sw.Stop()
                        $sw.Reset()
                        $ProgressPreference = $originalProgressPreference
                        if($WhatIf) {
                            Write-Progress -Activity "Restore-AzStorageBlobs : " -Status "Completed: $count."
                        }
                        else {
                            Write-Progress -Activity "Restore-AzStorageBlobs : " -Status "Total: $($TaskStatus.Total). Finished: $($TaskStatus.Completed). Failed: $($TaskStatus.Failed). Active: $($TaskStatus.Active)"
                        }
                        $ProgressPreference = "SilentlyContinue"
                        $sw.Start()
                    }
                }
                $continuationToken | Out-Null

                $previousBlob = $currentBlob
            }
            $blob = $null
        } while ($null -ne $continuationToken)

        if($null -ne $currentBlob) {
            [Diagnostics.Trace]::Listeners.Clear()
            Invoke-BlobRecovery -Blob $currentBlob -Container $blobContainer -WhatIf $WhatIf -TaskList $TaskList -TaskStatus $TaskStatus `
                -ConcurrentTasks $ConcurrentTasks -DeletionStartTime $DeletionStartTime -DeletionEndTime $DeletionEndTime
        }

        while(-not [System.Threading.Tasks.Task]::WaitAll($TaskList.Tasks, 10)) {}
        $TaskStatus.Completed += ($TaskList.Tasks | Where-Object { $_.Status -eq "RanToCompletion" }).Count
        $TaskStatus.Completed += ($TaskList.Failed | Where-Object { $_.Status -eq "Failed" }).Count
        $TaskStatus.Active = 0
        $TaskList.Tasks.Clear() | Out-Null

        if($WhatIf) {
            Write-Progress -Activity "Restore-AzStorageBlobs : " -Status "Completed: $count." -Completed
        }
        else {
            Write-Progress -Activity "Restore-AzStorageBlobs : " -Status "Total: $($TaskStatus.Total). Finished: $($TaskStatus.Completed). Failed: $($TaskStatus.Failed). Active: $($TaskStatus.Active)"
        }
        $sw.Stop()
    }
    end {
        $measure.Stop()
        $speed = 0
        if($measure.Elapsed.TotalSeconds -gt 0) {
            $speed = [Math]::Round($count / $measure.Elapsed.TotalSeconds, 0)
        }
        if(-not $skipProcessing) {
            Write-Host "[$([DateTime]::UtcNow.ToString("s"))Z] $($MyInvocation.MyCommand.Name) : Operation finished in $($measure.Elapsed). Final Speed: $speed blobs/s."
            Write-Host
        }

        [Runtime.GCSettings]::LargeObjectHeapCompactionMode = "CompactOnce"
        [GC]::Collect()
        $ProgressPreference = $originalProgressPreference
    }
}
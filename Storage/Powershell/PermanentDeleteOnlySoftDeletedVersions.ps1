#This PowerShell script helps you permanently delete only the soft-deleted versions of a blob

#Disclaimer
#By using the following materials or sample code you agree to be bound by the license terms below 
#and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
#are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
#are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
#use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
#provided that you agree: (i) to not use Microsoftâ€™s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
#which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
#a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
#suppliers from and against any third party claims or lawsuits, including attorneysâ€™ fees, that arise or result 
#from the use or distribution of the sample code."

Connect-AzAccount;
Set-AzContext -SubscriptionId "subscriptionid";
 
$storageAccountName = "storageaccountname"
$resourceGroup = "resourcegroupname"
$containerName = “conatinername”

$action ="PERMANENT_DELETE" #"PERMANENT_DELETE" #List_Only

$ctx = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName).Context
$objCount=0
$arrDeleted = ""

$objCount = FlatContainerProcessing ($containerName)

function FlatContainerProcessing ($containerName)
{
    $blobCount = 0

    $blob_Token = $null
    $exception = $Null

    $SASPermissions = 'rwdl'

    do
    {
        $listOfBlobs = Get-AzStorageBlob -Container $containerName -IncludeDeleted -IncludeVersion -Context $ctx -ContinuationToken $blob_Token -Prefix $prefix -MaxCount 5000 -ErrorAction Stop
        
        if($listOfBlobs -eq $null)
        {
            break
        }

        $listOfDeletedBlobs = $listOfBlobs | Where-Object {($_.IsDeleted -eq $true)}

        $listOfDeletedBlobs = $listOfDeletedBlobs | Where-Object {($_.VersionId -ne $null) }  # Versions only

        $CurrentTime = Get-Date 
        $StartTime = $CurrentTime.AddHours(-1.0)
        $EndTime = $CurrentTime.AddHours(59.0) 

        $sas = New-AzStorageContainerSASToken -Name $containerName -Permission $SASPermissions -StartTime $StartTime -ExpiryTime $EndTime -Context $ctx
        $sas = $sas.Replace("?","")

        $blobCount += $listOfDeletedBlobs.Count

        foreach($blob in $listOfDeletedBlobs)
        {
            # Creates a table to show the Soft Delete objects
            #--------------------------------------------------
            if($action -eq "List_Only")
            {
                if($blob.SnapshotTime -eq $null) {$strSnapshotTime = "-"} else {$strSnapshotTime = $blob.SnapshotTime}
                if($blob.VersionID -eq $null) {$strVersionID = "-"} else {$strVersionID = $blob.VersionID}

                $arrDeleted = $arrDeleted + ($blob.Name, $blob.Length, $blob.AccessTier, $strSnapshotTime, $strVersionID, $blob.ICloudBlob.Uri.AbsolutePath)
            }
            #----------------------------------------------------------------------
        
        # Permanent Delete those objects in one call
        #-----------------------------------------
            if($action -eq "PERMANENT_DELETE")
            {
                $sastoken = "account level sas token with permanent delete permission"

                $delete_uri = "https://" + $blob.BlobClient.Uri.Host + $blob.BlobClient.Uri.AbsolutePath + "?versionid="+ $blob.VersionID + "&deletetype=permanent&" + $sastoken
            
                Write-Host $delete_uri

                try
                {
                    $response = Invoke-RestMethod -Method "Delete" -Uri $delete_uri  
                }
                catch
                {
                    Write-Warning -Message "$_" -ErrorAction Stop
                    break
                }
            }
        }

        $blob_Token = $listOfBlobs[$listOfBlobs.Count -1].ContinuationToken;

    }while ($blob_Token -ne $null)


    if($blobCount -eq 0)
    {
        write-host "No Objects found to list"  -ForegroundColor Red
    }
    else
    {    
        write-host "Soft Deleted Objects found: $blobCount  " -ForegroundColor magenta

        if($action -eq 'List_Only')
        { 
            if ($blobCount -gt 0)
            {
                $arrDeleted | Format-Wide -Property {$_} -Column 6 -Force | out-string -stream | write-host -ForegroundColor Cyan
            }
        }
    }

    #write-host "Total objects processed: $blobCount "  -ForegroundColor magenta 
    return $blobCount
}

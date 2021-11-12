'By using the following materials or sample code you agree to be bound by the license terms below 
'and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
'These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
'are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
'are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
'not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
'use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
'provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
'in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
'which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
'a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
'limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
'suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result 
'from the use or distribution of the sample code."
 

[CmdletBinding(DefaultParametersetName="SharedKey")]
param(

  [Parameter(Mandatory=$true, HelpMessage="Storage Account Name")] 
  [String] $storage_account_name,

  [Parameter(Mandatory=$true, HelpMessage="Any one of the two shared access keys", ParameterSetName="SharedKey", Position=1)] 
  [String] $storage_shared_key,
  
  [Parameter(Mandatory=$true, HelpMessage="SAS Token : the GET parameters", ParameterSetName="SASToken", Position=1)] 
  [String] $storage_sas_token,

[Parameter(Mandatory=$true, HelpMessage="Container Name")] 
  [String] $container
  
)

$containerstats = @()

If ($PsCmdlet.ParameterSetName -eq "SharedKey")
{
  $Ctx = New-AzStorageContext -StorageAccountName $storage_account_name -StorageAccountKey $storage_shared_key
}
Else
{
  $Ctx = New-AzStorageContext -StorageAccountName $storage_account_name -SasToken $storage_sas_token
}

      Write-Host "Container List"  $container

      Write-Verbose "Processing container : $container"

      $total_usage = 0
      $total_blob_count = 0
      $version_count =0 
      $version_usage =0
      $blob_continuation_token = $null
    
        $blobs = Get-AzStorageBlob -Context $Ctx -Container $container -MaxCount 5000 -IncludeVersion -IncludeDeleted -ContinuationToken $blob_continuation_token
     
      do {
    
                        
        $blob_continuation_token = $null;

        if ($blobs -ne $null)
        {
          $blob_continuation_token = $blobs[$blobs.Count - 1].ContinuationToken

          for ([int] $b = 0; $b -lt $blobs.Count; $b++)
          {
            $total_blob_count++
            $total_usage += $blobs[$b].Length
            if ($blobs[$b].VersionId)
            {
              $version_count++
              $version_usage += $blobs[$b].Length
              Remove-AzStorageBlob -Container $container -Blob $blobs[$b].Name -VersionId $blobs[$b].VersionId -Context  $Ctx
            }
          }

          If ($blob_continuation_token -ne $null)
          {
            Write-Verbose "Blob listing continuation token = {0}".Replace("{0}",$blob_continuation_token.NextMarker)
          }
        }
     } while ($blob_continuation_token -ne $null)

      Write-Verbose "Calculated size of $container = $total_usage with Usage of versions"
                        
      $containerstats += [PSCustomObject] @{ 
        Name = $container 
        TotalBlobCount = $total_blob_count 
        TotalBlobUsage = $total_usage 
        VersionCount = $version_count
        VersionUsage = $version_usage
      }


Write-Host "Total container stats"
$containerstats | Format-Table -AutoSize  

Write-Host "YOU CAN IGNORE THE ABOVE EXCEPTIONS AS ITS JUST A CHECK ON ROOT BLOB and deleted version" -ForegroundColor DarkGreen -BackgroundColor Yellow

Write-Host "Deleted the Blob versions succesfully. GO to the container in Azure Portal and check to confirm" -ForegroundColor DarkGreen -BackgroundColor Yellow



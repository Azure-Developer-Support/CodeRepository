#The below PowerShell script helps to list the blobs present in a folder in storage accounts and also calculate the usage of that folder.

#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, 
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


## Instructions :-
##     1.Launch PowerShell and set the subscription context using 
##         Set-AzContext -SubscriptionID <yoursubscription>
##     2. copy everything after the line "##StartCopy"
##     3.Execute this script in the cloud shell to register the routine.
##     4.Execute it as Get-AllBlobs -RGName MyResourceGroup -Name MyStorageAccount -Container containerName -Directory directoryName
###
##StartCopy

function Get-AllBlobs
{
param(
  [Parameter(Mandatory=$true, HelpMessage="Resource Group Name")]
  [String] $RGName,
  [Parameter(Mandatory=$true, HelpMessage="Storage Account Name")]
  [String] $Name,
  [Parameter(Mandatory=$true, HelpMessage="Container Name")]
  [String] $Container,
  [Parameter(Mandatory=$true, HelpMessage="Folder Name")]
  [String] $Folder
)

 $Ctx = (Get-AzStorageAccount -ResourceGroupName $RGName -Name $Name).Context
    
  If ($Container -ne $null)
  {
   
    $total_usage = 0
    $blob_continuation_token = $null
    do {
     $blobs = Get-AzStorageBlob -Context $Ctx -Container $Container -MaxCount 5000 -IncludeDeleted -ContinuationToken $blob_continuation_token
     $blob_continuation_token = $null;
     if ($blobs -ne $null)
     {
      $blob_continuation_token = $blobs[$blobs.Count - 1].ContinuationToken
      for ([int] $b = 0; $b -lt $blobs.Count; $b++)
      {
      
        if($blobs[$b].ICloudBlob.Uri.AbsolutePath -match $Folder)
        {     
        $total_usage += $blobs[$b].Length

         Write-Host $blobs[$b].ICloudBlob.Uri.AbsolutePath
        
        }
       
      }
      If ($blob_continuation_token -ne $null)
      {
       Write-Verbose "Blob listing continuation token = {0}".Replace("{0}",$blob_continuation_token.NextMarker)
      }
     }
    }while ($blob_continuation_token -ne $null)
    if ($total_usage -gt 0)
    {
     Write-Host "The blobs in container $Container. Total Size = $total_usage "
    }
   
  }
  
}

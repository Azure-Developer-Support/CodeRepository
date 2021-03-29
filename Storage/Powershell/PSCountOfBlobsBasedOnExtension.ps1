# The below PowerShell script helps you to get count of blobs based on the extensions that the blobs have in a container.
# The script can be modified based on your requirements.

#Instructions :
#1.Launch PowerShell and set the subscription context using
        Set-AzContext -SubscriptionID <yoursubscription>
#3.Execute this function in the PowerShell
#4. To Get the output from the function, run the function as below:
        Get-AllBlobs -RGName YourResourceGroupName -Name YourStorageAccountName -Container YourContainerName


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

 
function Get-AllBlobs
{
param(
  [Parameter(Mandatory=$true, HelpMessage="Resource Group Name")]
  [String] $RGName,
  [Parameter(Mandatory=$true, HelpMessage="Storage Account Name")]
  [String] $Name,
  [Parameter(Mandatory=$true, HelpMessage="Container Name")]
  [String] $Container
  )


$Ctx = (Get-AzStorageAccount -ResourceGroupName $RGName -Name $Name).Context
    
  If ($Container -ne $null)
  {
  $Target = @()
   
    $total_count = 0
    $blob_continuation_token = $null
    do {
     $blobs = Get-AzStorageBlob -Context $Ctx -Container $Container -MaxCount 5000 -ContinuationToken $blob_continuation_token
     $blob_continuation_token = $null;
     if ($blobs -ne $null)
     {
      $blob_continuation_token = $blobs[$blobs.Count - 1].ContinuationToken
               
        $res = $blobs.Name | ForEach-Object { [System.IO.Path]::GetExtension($_).ToLower()}
                   
        $Target += $res


      If ($blob_continuation_token -ne $null)
      {
       Write-Verbose "Blob listing continuation token = {0}".Replace("{0}",$blob_continuation_token.NextMarker)
      }
     }
    }while ($blob_continuation_token -ne $null)

   
    $Target | group -NoElement | sort count -Descending 

     }
  
} 

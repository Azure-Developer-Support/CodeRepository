#The below script helps in uploading a blob in a given container using Invoke-RestMethod with a programmatically generated SAS token

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

$storageAccount = "<--your storage account name-->"
$containerName = "<--container name-->"
$blobName = "<--blob name-->"
$SharedKey = "<--storage account access key-->"

$Uri= "https://$storageAccount.blob.core.windows.net/$containerName/$blobName"

$date = [System.DateTime]::UtcNow.ToString("R",[Globalization.CultureInfo]::InvariantCulture)
#Write-Output $date
 
$body = "Test Content"
$contentLength = [System.Text.Encoding]::UTF8.GetByteCount($body)
#Write-Output $contentLength


$stringToSign = "PUT`n`n`n$contentLength`n`n`n`n`n`n`n`n`nx-ms-blob-type:BlockBlob`nx-ms-date:$date`nx-ms-version:2018-03-28`n/$storageAccount/$containerName/$blobName"

Write-Output $stringToSign

$hmacsha = New-Object System.Security.Cryptography.HMACSHA256
$hmacsha.key = [Convert]::FromBase64String($SharedKey)
$signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
$signature = [Convert]::ToBase64String($signature)

$authHeader = "SharedKey " + $storageAccount + ":" + $signature
#Write-Output $authHeader

# Define the headers for the request
$headers = @{
    "x-ms-version" = "2018-03-28"
    "x-ms-date" = $date
    #"Content-Type" = "application/xml;charset=UTF-8"
    "x-ms-blob-type" = "BlockBlob"
    "Authorization" = $authHeader
    "Content-Length" = $contentLength
}
# Add the content length to the headers
#$headers["Content-Length"] = $contentLength

#$headers["Authorization"] = $authHeader #- correct
#$headers["x-ms-date"] = $date
 
#Write-Output $URI
Write-Output $headers
#Write-Output $body

Write-Output $signature
 
Invoke-RestMethod -Method 'PUT' -Uri $URI -Headers $headers -Body $body

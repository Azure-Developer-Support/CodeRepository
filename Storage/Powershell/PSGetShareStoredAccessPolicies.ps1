#The below PowerShell script helps to set the access policy for a file share through calling fileshare Get Share ACL REST API.
#n this script we will construct a string to sign and generate a signature using access key to get the access policy details of a file share.


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

#Connect-AzAccount
$storageAccount = "<Storage account name>"
$accesskey = "<access key>";
$resource = "<file share name>"
$version="2019-02-02"
$date = [System.DateTime]::UtcNow.ToString("R",[Globalization.CultureInfo]::InvariantCulture)
$stringToSign = "GET`n`n`n`n`n`n`n`n`n`n`n`n"+
           "x-ms-date:$date`nx-ms-version:$version`n" +
           "/$storageAccount/$resource`ncomp:list"
$stringToSign = "GET`n`n`n`n`n`n`n`n`n`n`n`n"+
           "x-ms-date:$date`nx-ms-version:$version`n" +
           "/$storageAccount/$resource`ncomp:acl`nrestype:share"
Write-Output $stringToSign
$hmacsha = New-Object System.Security.Cryptography.HMACSHA256
$hmacsha.key = [Convert]::FromBase64String($accesskey)
$signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
#$signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($StringToSign1))
$signature = [Convert]::ToBase64String($signature)
$headers=@{"x-ms-date"=$date;
"x-ms-version"= $version;
"Authorization"= "SharedKey $($storageAccount):$signature"
}
Write-Output $headers
$URI = "https://$storageAccount.file.core.windows.net/$($resource)?restype=share&comp=acl"
# Perform the Set Share ACL operation using the authorization header and XML body
$response = Invoke-RestMethod -Method $URI -Method 'GET' $URI -Headers $headers -UseBasicParsing
$response

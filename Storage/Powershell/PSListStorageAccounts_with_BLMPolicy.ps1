# The Below PowerShell script helps you to to list storage accounts, check for management policy and get you the rules configured in the policy. You can also modify the script based on your requirement.

# Disclaimer

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

#We need AzureServicePrincipalAccount module to run the Get-AzureADToken command.
#Install-Module AzureServicePrincipalAccount
#Import-Module AzureServicePrincipalAccount

$subscriptionID = "your subscription ID"
#Acquire auth token for management.azure.com
$token = Get-AzureADToken -UserName 'email ID of the user who has permissions to get the details' -TenantID 'tenant ID' -ResourceURI 'https://management.azure.com/'

$URI = https://management.azure.com/subscriptions/ + $subscriptionId + "/providers/Microsoft.Storage/storageAccounts?api-version=2021-04-01"
$Method = "GET"
$headers = @{'Authorization' = $token
}
#Invoking REST API to get List of all storage accounts
$res = Invoke-RestMethod -Uri $URI -Method $Method -Headers $headers
for($i = 0; $i -lt $res.value.Count; $i++)
{
$storageaccountNames = $res.value[$i].id
$storageaccountNames = $storageaccountNames.Split("/") | Select-Object -Last 5
$storageaccountNames = $storageaccountNames -join "/"

#REST API to get details of lifecycle management policy
$URIforGetOLCM = "https://management.azure.com/subscriptions/" + $subscriptionID + "/resourceGroups/" + $storageaccountNames + "/managementPolicies/default?api-version=2021-04-01"

try
{
$result = Invoke-RestMethod -Uri $URIforGetOLCM -Method $Method -Headers $headers -ErrorAction Continue
Write-Output "The policy details for Storage account" $res.value[$i].Name "`n" $result.properties.policy.rules "`n"

}

catch
{

if($_.Exception.Response.StatusCode.value__ -eq 404)
{
Write-Output "Policy Not set for storage account" $res.value[$i].Name "`n"

}
}
} 


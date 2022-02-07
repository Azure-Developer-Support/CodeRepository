# DISCLAIMER #
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 

#While Remediation, modifying the resource count is possible from the portal directly. It ranges from 500 to 50,000. But there is no provision to do the same via PowerShell as the PowerShell command doesn't have the parameter for Resource Count
#We will leverage REST API to pass the resource count using powershell

##Create a variable to ensure that access token is provided while the REST API is accessed
$val = Get-AzAccessToken

##Fetching only token property from the AccessToken
$token = $val.Token

##Passing the token to the Header for authorization when the REST API is executed
$Header = @{
        "authorization" = "Bearer $token"
    }

##Specifying the resource count in the body
$BodyJson = '{
  "properties": {
    "policyAssignmentId": "<Policy Assignement ID>",
    "resourceDiscoveryMode": "ExistingNonCompliant",
    "resourceCount": 50000,
    "parallelDeployments": 10,
    "failureThreshold": {
      "percentage": 1
    }
  }
}'

##Passing the variables or Header and BodyJson in this Parameters variable
$Parameters = @{
Method      = "PUT"
Uri         = "https://management.azure.com/subscriptions/<SubId>/providers/Microsoft.PolicyInsights/remediations/<remediation Name>?api-version=2021-10-01"
Headers     = $Header
ContentType = "application/json"
Body        = $BodyJson
}

##Invoking the REST API
Invoke-RestMethod @Parameters

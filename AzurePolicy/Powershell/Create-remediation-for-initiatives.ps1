# DISCLAIMER #
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 

##Create two variable Policy Assignment Id and PolicySetDefinitionId
$policyAssignmentId = '<Add-Policy-Assignment-Id>'
$policySetDefID = '<Add-Policy-Set-Definition-Id>'

##Fetch the policy set definition properties
$policySetDef = Get-AzPolicySetDefinition -Id $policySetDefID

##Adding Policy Set Definitinos array to a variable 
$definitions = $policySetDef.Properties.PolicyDefinitions

##Create remediation task for all the policy definition which are part of initiative definition
Foreach ($def in $definitions){
$rID = $def.policydefinitionReferenceId
Start-AzPolicyRemediation -Name $rId -PolicyDefinitionReferenceId $rId -PolicyAssignmentId $policyAssignmentId 
} 

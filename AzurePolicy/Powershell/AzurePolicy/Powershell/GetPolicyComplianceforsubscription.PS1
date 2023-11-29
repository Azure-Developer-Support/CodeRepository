# Sign in to Azure (if not already signed in)
Connect-AzAccount
$SubscriptionId = "XXXXXXXXX"  # Replace {subscriptionId} with your actual subscription ID

# Get all policy assignments at the specified scope
$policyAssignments = Get-AzPolicyState -SubscriptionId $SubscriptionId #-SubscriptionId

# Initialize counters
$compliant = 0
$exempt = 0
$unknown = 0
$nonCompliant = 0
$conflicting = 0
$errorCount = 0
$protected = 0

# Count assignments based on compliance state
foreach ($assignment in $policyAssignments) {
    switch ($assignment.ComplianceState) {
        "Compliant" { $compliant++ }
        "Exempt" { $exempt++ }
        "Unknown" { $unknown++ }
        "NonCompliant" { $nonCompliant++ }
        "Conflicting" { $conflicting++ }
        "Error" { $errorCount++ }
        "Protected" { $protected++ }
    }
}

# Calculate overall compliance percentage
$totalNumerator = $compliant + $exempt + $unknown + $protected
$totalDenominator = $compliant + $exempt + $unknown + $nonCompliant + $conflicting + $errorCount + $protected

# Handle the case where there are no assignments to avoid division by zero
if ($totalDenominator -gt 0) {
    $compliancePercentage = ($totalNumerator / $totalDenominator) * 100
} else {
    $compliancePercentage = 100  # If no assignments, consider compliance as 100%
}

Write-Host "Total Policy Assignments: $($policyAssignments.Count)"
Write-Host "Compliant: $compliant"
Write-Host "Exempt: $exempt"
Write-Host "Unknown: $unknown"
Write-Host "Non-Compliant: $nonCompliant"
Write-Host "Conflicting: $conflicting"
Write-Host "Error: $errorCount"
Write-Host "Protected: $protected"
Write-Host "Overall Compliance Percentage: $compliancePercentage%"

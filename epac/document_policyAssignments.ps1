### Policy Assignment Section ###

# Get all .jsonc files in the "policyAssignments" folder except for the ones that end with "policySet.jsonc"
$jsoncFiles = Get-ChildItem -Path 'policyAssignments' -Filter '*.jsonc' | Where-Object { $_.Name -notlike '*policySet.jsonc' }

# Initialize the markdown table header
$mdTableHeader = @()
$mdTableHeader += "# Individual Policies"
$mdTableHeader += "| Policy ID | Display Name | Assignment Scopes |"
$mdTableHeader += "| --- | --- | --- |"

# Write the markdown table header to a .md file
$mdTableHeader -join "`n" | Out-File -FilePath 'policyDetails.md'

# Loop through each .jsonc file
foreach ($jsoncFile in $jsoncFiles) {
    # Read the JSONC file content
    $jsoncFileName = $jsoncFile.Name
    $jsoncContent = Get-Content -Path .\policyAssignments\$jsoncFileName -Raw

    # Parse the JSONC content to a PowerShell object
    $jsonObject = ConvertFrom-Json -InputObject $jsoncContent

    # Initialize the list of assignment scopes
    $assignmentScopesList = @()


    if ($true -eq $jsonObject.definitionEntry.policyId) {
        # Extract the policyId and displayName
        $policyId = $jsonObject.definitionEntry.policyId
        $displayName = $jsonObject.definitionEntry.displayName

        # Remove "/providers/Microsoft.Authorization/policyDefinitions/" from the policyId
        $policyId = $policyId.Replace("/providers/Microsoft.Authorization/policyDefinitions/", "")

    }
    elseif ($true -eq $jsonObject.definitionEntry.policyName) {
        # Extract the policyId and displayName
        $policyId = $jsonObject.definitionEntry.policyName
        $displayName = $jsonObject.definitionEntry.displayName
    }
    if ($true -eq $jsonObject.children) {
        # Loop through the children array to extract the assignment scopes
        foreach ($child in $jsonObject.children) {
        $assignmentScopesList += $child.scope.tenantRoot
        }

        # Loop through the list and replace the string in each element
        for ($i=0; $i -lt $assignmentScopesList.Count; $i++) {
        $assignmentScopesList[$i] = $assignmentScopesList[$i].Replace("/providers/Microsoft.Management/managementGroups/", "")
        }

        # Join the assignment scopes with commas
        $assignmentScopes = $assignmentScopesList -join ', '

    }
    elseif ($false -eq $jsonObject.children) {

        # Loop through the scope array to extract the assignment scopes
        foreach ($scope in $jsonObject.scope.tenantRoot) {
            $assignmentScopesList += $child.scope.tenantRoot
            }
        
        # Loop through the list and replace the string in each element
        for ($i=0; $i -lt $assignmentScopesList.Count; $i++) {
            $assignmentScopesList[$i] = $assignmentScopesList[$i].Replace("/providers/Microsoft.Management/managementGroups/", "")
            }
        
        # Join the assignment scopes with commas
        $assignmentScopes = $assignmentScopesList -join ', '

    }

    # Initialize the markdown table row
    $mdTableRow = @()
    $mdTableRow += "| $policyId | $displayName | $assignmentScopes |"

    # Append the markdown table row to the .md file
    $mdTableRow -join "`n" | Out-File -FilePath 'policyDetails.md' -Append

    #Cleanup the policyId and displayName variable
    $policyId = $null
    $displayName = $null
}


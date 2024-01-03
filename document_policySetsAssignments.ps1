### Policy Initiatives Section ###

# Get all .jsonc files in the "policyAssignments" folder except for the ones that end with "policySet.jsonc"
$jsoncFiles = Get-ChildItem -Path 'policyAssignments' -Filter '*.jsonc' | Where-Object { $_.Name -like '*-policySet.jsonc' }

# Initialize the markdown table header
$mdTableHeader = @()
$mdTableHeader += "# Policy Initiatives (Policy Sets)"
$mdTableHeader += "| PolicySet | Display Name | Assignment Scopes |"
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


    if ($true -eq $jsonObject.definitionEntry.policySetName) {
        # Extract the policyId and displayName
        $policySetId = $jsonObject.definitionEntry.policySetName
        $displayName = $jsonObject.definitionEntry.displayName

        # Remove "/providers/Microsoft.Authorization/policyDefinitions/" from the policyId
        $policySetId = $policySetId.Replace("/providers/Microsoft.Authorization/policySetDefinitions/", "")

    }
    
    elseif ($true -eq $jsonObject.definitionEntry.policySetId) {
       # Extract the policyId and displayName
       $policySetId = $jsonObject.definitionEntry.policySetId
       $displayName = $jsonObject.definitionEntry.displayName

       # Remove "/providers/Microsoft.Authorization/policyDefinitions/" from the policyId
       $policySetId = $policySetId.Replace("/providers/Microsoft.Authorization/policySetDefinitions/", "") 
    }

    # Get the scoping information
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
    $mdTableRow += "| $policySetId | $displayName | $assignmentScopes |"

    # Append the markdown table row to the .md file
    $mdTableRow -join "`n" | Out-File -FilePath 'policyDetails.md' -Append

    #Cleanup the policyId and displayName variable
    $policySetId = $null
    $displayName = $null
}


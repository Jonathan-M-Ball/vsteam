function Get-VSTeamApproval {
    [CmdletBinding()]
    param(
        [ValidateSet('Approved', 'ReAssigned', 'Rejected', 'Canceled', 'Pending', 'Rejected', 'Skipped', 'Undefined')]
        [string] $StatusFilter,
        [Alias('ReleaseIdFilter')]
        [int[]] $ReleaseIdsFilter,
        [string] $AssignedToFilter,
        [Parameter(Mandatory=$true, Position = 0 )]
        [ValidateProject()]
        [ArgumentCompleter([ProjectCompleter])]
        $ProjectName
    )
    process {
                try {
            # Build query string and determine if the includeMyGroupApprovals should be added.
            $queryString = @{statusFilter = $StatusFilter; assignedtoFilter = $AssignedToFilter; releaseIdsFilter = ($ReleaseIdsFilter -join ',')}
            # The support in TFS and VSTS are not the same.
            $instance = $([VSTeamVersions]::Account)
            if ( $instance -like "*.visualstudio.com*" -or $instance -like "https://dev.azure.com/*") {
                if ([string]::IsNullOrEmpty($AssignedToFilter) -eq $false) {
                    $queryString.includeMyGroupApprovals = 'true';
                }
            }
            else {
                # For TFS all three parameters must be set before you can add
                # includeMyGroupApprovals.
                if ([string]::IsNullOrEmpty($AssignedToFilter) -eq $false -and
                    [string]::IsNullOrEmpty($ReleaseIdsFilter) -eq $false -and
                    $StatusFilter -eq 'Pending') {
                    $queryString.includeMyGroupApprovals = 'true';
                }
            }
            # Call the REST API
            $resp = _callAPI -ProjectName $ProjectName -Area release -Resource approvals -SubDomain vsrm -Version $([VSTeamVersions]::Release) -QueryString $queryString
            # Apply a Type Name so we can use custom format view and custom type extensions
            foreach ($item in $resp.value) {
                $item.PSObject.TypeNames.Insert(0, 'Team.TfvcBranch')
            }
            Write-Output $resp.value
        }
        catch {
            _handleException $_
        }
    }
}

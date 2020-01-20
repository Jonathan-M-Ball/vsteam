function Show-VSTeamRelease {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(ParameterSetName = 'ByID', ValueFromPipelineByPropertyName = $true, Mandatory = $true, Position = 1)]
        [Alias('ReleaseID')]
        [int] $id,
        [Parameter(Mandatory=$true, Position = 0 )]
        [ValidateProject()]
        [ArgumentCompleter([ProjectCompleter])]
        $ProjectName
    )
    process {
        Write-Debug 'Show-VSTeamRelease Process'
        if ($id -lt 1) {
            Throw "$id is not a valid id. Value must be greater than 0."
        }
                # Build the url
        Show-Browser "$([VSTeamVersions]::Account)/$ProjectName/_release?releaseId=$id"
    }
}

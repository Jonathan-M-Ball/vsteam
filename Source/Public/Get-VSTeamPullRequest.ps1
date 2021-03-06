function Get-VSTeamPullRequest {
   [CmdletBinding(DefaultParameterSetName = "SearchCriteriaWithStatus")]
   param (
      [Alias('PullRequestId')]
      [Parameter(ParameterSetName = "ById")]
      [string] $Id,

      [Parameter(ParameterSetName = "SearchCriteriaWithStatus")]
      [Parameter(ParameterSetName = "SearchCriteriaWithAll")]
      [Guid] $RepositoryId,

      [Parameter(ParameterSetName = "SearchCriteriaWithAll")]
      [Parameter(ParameterSetName = "SearchCriteriaWithStatus")]
      [Guid] $SourceRepositoryId,

      [Parameter(ParameterSetName = "SearchCriteriaWithAll")]
      [Parameter(ParameterSetName = "SearchCriteriaWithStatus")]
      [ValidatePattern('^refs/.*')]
      [string] $SourceBranchRef,

      [Parameter(ParameterSetName = "SearchCriteriaWithAll")]
      [Parameter(ParameterSetName = "SearchCriteriaWithStatus")]
      [ValidatePattern('^refs/.*')]
      [string] $TargetBranchRef,

      [Parameter(ParameterSetName = "SearchCriteriaWithStatus")]
      [ValidateSet("abandoned", "active", "all", "completed", "notSet")]
      [string] $Status,

      [Parameter(ParameterSetName = "SearchCriteriaWithAll")]
      [switch] $All,

      [Parameter(ParameterSetName = "SearchCriteriaWithAll")]
      [Parameter(ParameterSetName = "SearchCriteriaWithStatus")]
      [int] $Top,

      [Parameter(ParameterSetName = "SearchCriteriaWithAll")]
      [Parameter(ParameterSetName = "SearchCriteriaWithStatus")]
      [int] $Skip
   )

   DynamicParam {
      _buildProjectNameDynamicParam -Mandatory $false
   }

   Process {
      # Bind the parameter to a friendly variable
      $ProjectName = $PSBoundParameters["ProjectName"]

      try {
         if ($Id) {
            if ($ProjectName) {
               $resp = _callAPI -ProjectName $ProjectName -Area git -Resource pullRequests -Version $(_getApiVersion Git) -Id $Id
            }
            else {
               $resp = _callAPI -Area git -Resource pullRequests -Version $(_getApiVersion Git) -Id $Id
            }
         }
         else {
            $queryString = @{
               'searchCriteria.sourceRefName'      = $SourceBranchRef
               'searchCriteria.sourceRepositoryId' = $SourceRepositoryId
               'searchCriteria.targetRefName'      = $TargetBranchRef
               'searchCriteria.status'             = if ($All.IsPresent) { 'all' } else { $Status }
               '$top'                              = $Top
               '$skip'                             = $Skip
            }

            if ($RepositoryId) {
               if ($ProjectName) {
                  $resp = _callAPI -ProjectName $ProjectName -Id "$RepositoryId/pullRequests" -Area git -Resource repositories -Version $(_getApiVersion Git) -QueryString $queryString
               }
               else {
                  $resp = _callAPI -Id "$RepositoryId/pullRequests" -Area git -Resource repositories -Version $(_getApiVersion Git) -QueryString $queryString
               }
            }
            else {
               if ($ProjectName) {
                  $resp = _callAPI -ProjectName $ProjectName -Area git -Resource pullRequests -Version $(_getApiVersion Git) -QueryString $queryString
               }
               else {
                  $resp = _callAPI -Area git -Resource pullRequests -Version $(_getApiVersion Git) -QueryString $queryString
               }
            }
         }

         if ($resp.PSobject.Properties.Name -contains "value") {
            $pullRequests = $resp.value
         }
         else {
            $pullRequests = $resp
         }

         foreach ($respItem in $pullRequests) {
            _applyTypesToPullRequests -item $respItem
         }

         Write-Output $pullRequests
      }
      catch {
         _handleException $_
      }
   }
}
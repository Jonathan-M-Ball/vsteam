Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here/../../Source/Classes/VSTeamVersions.ps1"
. "$here/../../Source/Classes/VSTeamProjectCache.ps1"
. "$here/../../Source/Private/common.ps1"
. "$here/../../Source/Public/$sut"

Describe 'Show-VSTeamApproval' -Tag 'unit', 'approvals' {
   # Set the account to use for testing. A normal user would do this
   # using the Set-VSTeamAccount function.
   Mock _getInstance { return 'https://dev.azure.com/test' }
   
   # Mock the call to Get-Projects by the dynamic parameter for ProjectName
   Mock Invoke-RestMethod { return @() } -ParameterFilter {
      $Uri -like "*_apis/projects*"
   }

   # Load the mocks to create the project name dynamic parameter
   . "$PSScriptRoot\mocks\mockProjectNameDynamicParamNoPSet.ps1"

   Context 'Succeeds' {
      Mock Show-Browser -Verifiable

      Show-VSTeamApproval -projectName project -ReleaseDefinitionId 1

      It 'should open in browser' {
         Assert-VerifiableMock
      }
   }
}
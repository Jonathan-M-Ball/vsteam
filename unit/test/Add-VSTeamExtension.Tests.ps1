Set-StrictMode -Version Latest

Import-Module SHiPS

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here/../../Source/Classes/VSTeamLeaf.ps1"
. "$here/../../Source/Classes/VSTeamVersions.ps1"
. "$here/../../Source/Classes/VSTeamInstallState.ps1"
. "$here/../../Source/Classes/VSTeamExtension.ps1"
. "$here/../../Source/Private/common.ps1"
. "$here/../../Source/Public/$sut"

Describe 'VSTeamExtension' {
   Mock _getInstance { return 'https://dev.azure.com/test' } -Verifiable
      
   $singleResult = [PSCustomObject]@{
      extensionId     = 'test'
      extensionName   = 'test'
      publisherId     = 'test'
      publisherName   = 'test'
      version         = '1.0.0'
      registrationId  = '12345678-9012-3456-7890-123456789012'
      manifestVersion = 1
      baseUri         = ''
      fallbackBaseUri = ''
      scopes          = [PSCustomObject]@{ }
      installState    = [PSCustomObject]@{
         flags       = 'none'
         lastUpdated = '2018-10-09T11:26:47.187Z'
      }
   }

   Context 'Add-VSTeamExtension without version' {
      BeforeAll {
         $env:Team_TOKEN = '1234'
      }

      AfterAll {
         $env:TEAM_TOKEN = $null
      }

      Mock _callAPI { return $singleResult }

      It 'Should add an extension without version' {
         Add-VSTeamExtension -PublisherId 'test' -ExtensionId 'test'

         Assert-MockCalled _callAPI -Exactly 1 -Scope It -ParameterFilter {
            $Method -eq 'Get' -and
            $subDomain -eq 'extmgmt' -and
            $version -eq [VSTeamVersions]::ExtensionsManagement -and
            $uri
            $Url -like "*https://extmgmt.dev.azure.com/test/_apis/_apis/extensionmanagement/installedextensionsbyname/test/test*"
         }
      }
   }

   Context 'Add-VSTeamExtension with version' {
      BeforeAll {
         $env:Team_TOKEN = '1234'
      }

      AfterAll {
         $env:TEAM_TOKEN = $null
      }

      Mock _callAPI { return $singleResult }

      It 'Should add an extension with version' {
         Add-VSTeamExtension -PublisherId 'test' -ExtensionId 'test' -Version '1.0.0'

         Assert-MockCalled _callAPI -Exactly 1 -Scope It -ParameterFilter {
            $Method -eq 'Get' -and
            $subDomain -eq 'extmgmt' -and
            $version -eq [VSTeamVersions]::ExtensionsManagement
            $Url -like "*https://extmgmt.dev.azure.com/test/_apis/_apis/extensionmanagement/installedextensionsbyname/test/test/1.0.0*"
         }
      }
   }
}
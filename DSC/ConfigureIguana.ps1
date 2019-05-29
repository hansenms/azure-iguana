configuration ConfigureASEBuildAgentDsc
{
    param
    (
        [Parameter(Mandatory=$false)]
        [String]$IguanaInstallerUrl = "https://raw.githubusercontent.com/hansenms/azure-iguana/master/README.md"
    )
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node localhost
    {                
        Script DownloadInstaller
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {
                $installerUrl = $using:IguanaInstallerUrl
                $installerFile = "$env:TEMP" + "\README.md"
                Write-Host "Downloading TFS: $installerUrl"
                Invoke-WebRequest -Uri $installerUrl -OutFile $installerFile
            }
            TestScript = {
                $installerFile = "$env:TEMP" + "\README.md"
                Test-Path $installerFile
            }
        }
    }
}
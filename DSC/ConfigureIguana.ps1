configuration ConfigureIguanaDsc
{
    param
    (
        # TODO: Replace with correct file
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

                # TODO: Replace with appropriate name
                $installerFile = "$env:TEMP" + "\README.md"

                Write-Host "Downloading TFS: $installerUrl"
                Invoke-WebRequest -Uri $installerUrl -OutFile $installerFile
            }
            TestScript = {
                # TODO: Replace with appropriate name
                $installerFile = "$env:TEMP" + "\README.md"
                Test-Path $installerFile
            }
        }

        Script InstallIguana
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {

                # TODO: Replace with configuration code
                Write-Host "Installing Iguana...."

            }
            TestScript = {
                # TODO: Replace with appropriate test to validate Iguana is configured and installed
                # Always run for now
                Return $false
            }
            DependsOn  = "[Script]DownloadInstaller"
        }
    }
}
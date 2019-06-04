configuration ConfigureIguanaDsc
{
    param
    (
        [Parameter(Mandatory=$true)]
        [String]$clientId,

        [Parameter(Mandatory=$true)]
        [String]$clientSecret,

        [Parameter(Mandatory=$true)]
        [String]$tenantId,


        [Parameter(Mandatory=$true)]
        [String]$fhirUrl,

        [Parameter(Mandatory=$false)]
        [String]$downloadLink = "https://bitbucket.org/interfaceware/microsoft-fhir-poc/downloads/Iguana.zip"
    )
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    #1. Declare Variables and create file path
    $downloadFolder='C:\Downloads'
    $path = $downloadFolder + '\Iguana.zip'
    $installDir = 'C:\Program Files'
    $FHIRsrc = $installDir + '\Iguana\FHIR'
    $FHIRdir = 'C:\'
    $Appdir = 'Iguana\ApplicationDir\6.1.2\iNTERFACEWARE-Iguana'
    $script = $installDir + '\Iguana\ApplicationDir\6.1.2\iNTERFACEWARE-Iguana\start-iguana_service.bat'
    $workingDir = $installDir + '\Iguana\WorkingDir'
    $iguanaEnv = $workingDir + '\IguanaEnv.txt'

    Node localhost
    {   
        
        File DownloadFolder {
            Type = 'Directory'
            DestinationPath = $downloadFolder
            Ensure = "Present"
        }

        File InstallFolder {
            Type = 'Directory'
            DestinationPath = $downloadFolder
            Ensure = "Present"
        }

        Script DownloadIguana
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Write-Host "Downloading Iguana: " + $using:downloadLink
                Invoke-WebRequest -Uri $using:downloadLink -OutFile $using:path
            }
            TestScript = {
                Test-Path $using:path
            }
            DependsOn = "[File]DownloadFolder"
        }

        Archive UnzipIguana
        {
            Destination = $installDir
            Path = $path
            DependsOn = "[Script]DownloadIguana","[File]InstallFolder"
        }

        Script MoveFhirSource
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {
               Move-Item -Path $using:FHIRsrc -Destination $using:FHIRdir
            }
            TestScript = {
                Test-Path $using:FHIRdir
            }
            DependsOn = "[Archive]UnzipIguana"
        }


        File IguanaEnvFile {
            DestinationPath = $IguanaEnv
            Type = "File"
            Contents = 'clientId=' + ($clientId)+ "`r`n" + 'clientSecret=' + ($clientSecret)+ "`r`n" + 'tenantId=' +($tenantId)+ "`r`n" + 'fhirUrl=' + ($fhirUrl)
            DependsOn = "[Archive]UnzipIguana"
        }

        Script InstallStartProcess
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {
                Start-Process -FilePath $using:script -Verb RunAs -Wait
            }
            TestScript = {
                return $false
            }
            DependsOn = "[File]IguanaEnvFile"
        }

        Script RunIguanaProcess
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {
                Get-Service "iNTERFACEWARE-Iguana 6.1.2" | Where-Object {$_.status -eq "Stopped"} | Start-Service            
            }
            TestScript = {
                return $false
            }
            DependsOn = "[Script]InstallStartProcess"
        }
    }
}
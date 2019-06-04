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
            DestinationPath = $using:downloadFolder
            Ensure = "Present"
        }

        File InstallFolder {
            Type = 'Directory'
            DestinationPath = $using:downloadFolder
            Ensure = "Present"
        }

        Script DownloadIguana
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {
                Write-Host "Downloading Iguana: " + $using:downloadLink
                Invoke-WebRequest -Uri $using:downloadLink -OutFile $using:path
            }
            TestScript = {
                Test-Path $using:path
            }
            DependsOn = "[File]DownloadFolder"
        }

        Script UnzipIgunana
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {
                [IO.Compression.ZipFile]::ExtractToDirectory($using:path, $using:installDir)
            }
            TestScript = {
                Test-Path $using:script
            }
            DependsOn = "[Script]DownloadIguana","[File]InstallFolder"
        }

        File MoveFhirSource {
            SourcePath = $using:FHIRsrc
            DestinationPath = $using:FHIRdir
            Recurse = $true
            Type = "Directory"
            DependsOn = "[Script]UnzipIguana"
        }

        File IguanaEnvFile {
            DestinationPath = $using:IguanaEnv
            Type = "File"
            Contents = 'clientId=' + ($using:clientId)+ "`r`n" + 'clientSecret=' + ($using:clientSecret)+ "`r`n" + 'tenantId=' +($using:tenantId)+ "`r`n" + 'fhirUrl=' + ($using:fhirUrl)
            DependsOn = "[Script]UnzipIguana"
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
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
        Script InstallIguana
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {

                # Hide PowerShell Console
                #0. Start Script as Admin
                $dir= Get-Location
                PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -File ""$dir&IguanaAuto.ps1""' -Verb RunAs}";

                #1. Declare Variables 
                $downloadLink='http://dl.interfaceware.com/iguana/windows/6_1_2/iguana_noinstaller_6_1_2_windows_x64.zip'
                $dlName='iguana_noinstaller_6_1_2_windows_x64.zip'
                $downloadFolder='C:\Downloads'
                $installDIR='C:\Program Files\Iguana\ApplicationDir\6.1.2'
                $wDir='C:\Program Files\Iguana\WorkingDir'
                $Logs='C:\Program Files\Iguana\LogDir'
                $sName='iNTERFACEWARE-Iguana 6.1.2'
                $sDName='iNTERFACEWARE-Iguana 6.1.2'
                $port='65430'

                #1.5 Create Directories if they do not exist
                New-Item -ItemType Directory -Force -Path $downloadFolder


                #3 Generate Batch Script to install Iguana

                $part1="@echo off
                REM ###############################################################################################
                REM Iguana Sudo-Autoinstaller for Windows, using Powershell/DOS.
                REM Enter Install Parameters Here
                setlocal EnableDelayedExpansion
                SET downloadLink=$downloadLink
                SET dlName=$dlName
                SET downloadFolder=$downloadFolder
                SET installDIR=$installDIR
                SET wDir=$wDir
                SET Logs=$Logs
                SET sName=$sName
                SET sDName=$sDName
                SET port=$port
                SET a=1
                SET b=2
                REM ###############################################################################################
                "
                $part2='

                mkdir "%installDIR%"
                mkdir "%wDir%"
                mkdir "%Logs%"

                echo 1. Starting download of Iguana...
                powershell -Command "(New-Object Net.WebClient).DownloadFile(''%downloadlink%'', ''%downloadFolder%\%dlName%'')"

                echo 1. Download complete.
                @TIMEOUT /t 1 /nobreak>nul
                echo.

                echo 2. Extract Iguana...
                powershell.exe -nologo -noprofile -command "& { Add-Type -A ''System.IO.Compression.FileSystem''; [IO.Compression.ZipFile]::ExtractToDirectory(''%downloadFolder%\%dlName%'', ''%downloadFolder%\%dlName:~0,-4%''); }"

                echo 2. Extract complete. 
                @TIMEOUT /t 1 /nobreak>nul 
                echo.

                echo 3. Modify iguana.hdf...
                setlocal enableextensions
                cd %downloadFolder%\%dlName:~0,-4%\iNTERFACEWARE-Iguana
                powershell -Command "(Get-Content iguana_service.hdf).replace(''command_line=iguana.exe'', ''command_line=iguana.exe --working_dir """"%wDir%""""'') | Set-Content iguana_service.hdf"
                powershell -Command "(Get-Content iguana_service.hdf).replace(''service_display_name=iNTERFACEWARE Iguana'', ''service_display_name=%sDName%'') | Set-Content iguana_service.hdf"
                powershell -Command "(Get-Content iguana_service.hdf).replace(''service_name=Iguana'', ''service_name=%sName%'') | Set-Content iguana_service.hdf"

                echo 3. Modify complete. 
                echo Working directory will be "%wDir%".
                @TIMEOUT /t 1 /nobreak>nul
                echo.

                REM echo Iguana will be executed to generate configuration repo (and then killed).
                cd %downloadFolder%\%dlName:~0,-4%\
                move iNTERFACEWARE-Iguana "%installDIR%" 
                (
                echo cd "%installDIR%\iNTERFACEWARE-Iguana"
                echo iguana.exe --run --working_dir "%wDir%"
                echo EXIT /B
                )>"%installDIR%\iNTERFACEWARE-Iguana\run-iguana.bat"
                echo 4. Starting Iguana to initialize variables (8 seconds)... 
                start "run-iguana.bat" "%installDIR%\iNTERFACEWARE-Iguana\run-iguana.bat"
                @TIMEOUT /t 8 /nobreak>nul
                echo.

                echo 4. Variables initialized.
                @TIMEOUT /t 1 /nobreak>nul
                echo.

                echo 5. Stopping Iguana...
                powershell -Command "Get-Process | Where-Object { $_.MainWindowTitle -like ''*run-iguana.bat'' } | Stop-Process"
                echo.

                echo 5. Iguana Stopped.
                @TIMEOUT /t 1 /nobreak>nul
                echo.

                echo 6. Modifying Iguana Config...
                cd "%wDir%\IguanaConfigurationRepo"
                powershell -Command "([regex]''port=.*'').Replace((Get-Content ''IguanaConfiguration.xml'' -Raw), ''port=""""%port%""""'', 1) | Set-Content ''IguanaConfiguration.xml''"
                powershell -Command "([regex]''log_directory=.*'').Replace((Get-Content ''IguanaConfiguration.xml'' -Raw), ''log_directory=""""%Logs%""""'', 1) | Set-Content ''IguanaConfiguration.xml''"
                echo 7. Modifying Iguana Config complete.
                @TIMEOUT /t 3 /nobreak>nul
                echo.

                echo 8. Installing Iguana Service...
                (
                echo cd "%installDIR%\iNTERFACEWARE-Iguana"
                echo iguana_service.exe --install
                REM echo pause
                )>"%installDIR%\iNTERFACEWARE-Iguana\start-iguana_service.bat"
                start "start-iguana_service.bat" "%installDIR%\iNTERFACEWARE-Iguana\start-iguana_service.bat"
                @TIMEOUT /t 3 /nobreak>nul
                echo.

                powershell -Command "Get-Process | Where-Object { $_.MainWindowTitle -like ''*start-iguana_service.bat'' } | Stop-Process"
                echo.

                echo 8. Done. 
                echo.

                echo 9 Starting Iguana Service...
                net start "%sDName%"
                echo.

                COLOR 02
                echo Installation Complete.
                @TIMEOUT /t 3 /nobreak>nul
                echo.
                echo.
                REM END
                COLOR 07

                rmdir /s /q %downloadFolder%\%dlName:~0,-4%
                del /s /q %downloadFolder%\%dlName%

                echo To start using Iguana:
                echo         1. Open your Internet browser 
                echo         2. Navigate to localhost:%port%  
                echo         3. Login and start configuring your Iguana.
                echo.
                echo If needed, shut down Iguana from Windows Services to change additional parameters.
                pause
                (goto) 2>nul & del "%~f0"'

                $part3=$part1+$part2
                $part4=$downloadFolder +'\autoinstall.bat' 
                "$part3" | Out-File $part4 -Encoding ascii
                $part5=$downloadFolder +'\autoinstall.bat'
                Powershell -Command "& { Start-Process ""$part5"" -verb RunAs}"
            }
            TestScript = {
                # TODO: Replace with appropriate name
                $installerFile = "$env:TEMP" + "\README.md"
                Test-Path $installerFile
            }
        }
    }
}
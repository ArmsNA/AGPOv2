Write-Host "Hello, $env:UserName. Welcome to Armsna's Automated Group Policy Object Program."

$sourceUri="https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip"
$dlPath="C:\Users\$env:UserName\Downloads\LGPO.zip"
$destPath="C:\Program Files\LGPO"
$truePath='C:\Program Files\LGPO\LGPO_30'
$prevPath=[string](Get-Location)
#install lgpo ms utility to user (env) downloads
Set-ExecutionPolicy Unrestricted

Write-Host "Installing LGPO Microsoft Utility now..."
Invoke-Webrequest -Uri $sourceUri -OutFile $dlPath 
Write-Host "Unzipping lgpo.zip..."
Expand-Archive -Path $dlpath -DestinationPath $destPath -Force

Write-Host "Creating a backup directory if none is found..."
cd $truePath

if ([string](Get-Location) -ieq $truePath){
	if (Test-Path -Path "$truePath\Backup") {
		Write-Host "Backup directory found. Storing GPO information in $truePath\Backup."
        $bPath="$truePath\Backup"
        Write-Host -NoNewLine "Would you like to overwrite the previous backup? Y/N: "
        for ($i=1; $i -gt 0; $i++){
            $answer=Read-Host
            if ($answer -ieq "Y"){
                rm -Recurse $bPath
                .\LGPO.exe /b $truePath /n "Backup"
                #latest=$(dir -td -- */ | head -n 1)
                $latest=gci $truePath | sort LastWriteTime | select -last 1
                mv $latest $bPath
  	            Write-Host "Backup directory overwritten. Storing GPO information in $truePath\Backup."
  	            $i=-1
            }
            elseif ($answer -ieq "n"){
  	            Write-Host "OK."
                $i=-1
            }
            else{
  	            Write-Host "Invalid response. Please specify answer with Y/N: "
            }
        }
    }
	else{
        #mkdir Backups
        .\LGPO.exe /b $truePath /n "Backup"
        $bPath="$truePath\Backup"
        #Sorts directories by latest mod time and returns 1st on list stored in latest var
        #latest=$(ls -td -- */ | head -n 1)
        $latest=gci $truePath | sort LastWriteTime | select -last 1
        mv $latest $bPath
        
		Write-Host "Backup directory created. Storing GPO information in $bPath."
    }
}

$mRegPath="$bpath\DomainSysvol\GPO\Machine\registry.pol"
$uRegPath="$bpath\DomainSysvol\GPO\User\registry.pol"
for ($i=1; $i -gt 0; $i++){
    $usrChoice=Read-Host -Prompt "Please select options from the list below. 
1)ParseMachineRegistryFileSettings 2)ParseUserRegistryFileSettings 3)ParseAllRegistryFilesAllSettings 
4)ApplyExistingGPOsToMachineSettings 5)ApplyExistingGPOsToUserSettings 6)ApplyExistingGPOsToAllSettings 
7)ApplyMeetComplianceSettings 8)ApplyBackupMachineSettings 9)ApplyBackupUserSettings
10)ApplyBackupAllSettings 11)Quit
Input 11 to quit."
    switch ($usrChoice){
        1{.\LGPO.exe /parse /m $mRegPath > lgpoMachine.txt}
        2{.\LGPO.exe /parse /u $uRegPath > lgpoUser.txt}
        3{.\LGPO.exe /parse /m $mRegPath > lgpoMachine.txt
            .\LGPO.exe /parse /u $uRegPath > lgpoUser.txt
        }
        4{for($i=1;$i -gt 0; $i++){
            $answer=Read-Host -Prompt "Provide a path to existing GPO Machine Settings: "
            if(Test-Path -Path $answer -Include '*.pol', '*.txt'){
                if (!(Test-Path -Path "$truePath\New")){mkdir "$truePath\New"}
                if (!(Test-Path -Path "$truePath\New\Machine")){mkdir "$truePath\New\Machine"}
                if(Test-Path -Path $answer -Include '*.pol'){
                    .\LGPO.exe /parse /m $answer > lgpoMachine.txt
                    .\LGPO.exe /t "$truePath\lgpoMachine.txt"
                    # OR
                    .\LGPO.exe /r "$truePath\lgpoMachine.txt" /w "$truePath\New\Machine\registry.pol"
                    #.\LGPO.exe /m "$truePath\New\Machine\registry.pol"
                }else{
                    .\LGPO.exe /t $answer
                    # OR
                    .\LGPO.exe /r $answer /w "$truePath\New\Machine\registry.pol"
                    #.\LGPO.exe /m "$truePath\New\Machine\registry.pol"
                }
                $i=-1
            }else{
                Write-Output "Invalid Path. Path does not exist."
        }
        }}
        5{for($i=1;$i -gt 0; $i++){
            $answer=Read-Host -Prompt "Provide a path to existing GPO User Settings: "
            if(Test-Path -Path $answer -Include '*.pol', '*.txt'){
                if (!(Test-Path -Path "$truePath\New")){mkdir "$truePath\New"}
                if (!(Test-Path -Path "$truePath\New\User")){mkdir "$truePath\New\User"}
                if(Test-Path -Path $answer -Include '*.pol'){
                    .\LGPO.exe /parse /u $answer > lgpoUser.txt
                    #Apply reg commands from txt
                    .\LGPO.exe /t "$truePath\lgpoUser.txt"
                    # OR
                    #Create new reg.pol from reg commands in txt
                    .\LGPO.exe /r "$truePath\lgpoUser.txt" /w "$truePath\New\User\registry.pol"
                    #Import new reg.pol
                    #.\LGPO.exe /u "$truePath\New\User\registry.pol"
                }else{
                    .\LGPO.exe /t $answer
                    # OR
                    .\LGPO.exe /r $answer /w "$truePath\New\User\registry.pol"
                    #.\LGPO.exe /u "$truePath\New\User\registry.pol"
                }
                $i=-1
            }else{
                Write-Output "Invalid Path. Path does not exist."
            }
        }}
        6{for($i=1;$i -gt 0; $i++){
            $answer=Read-Host -Prompt "Provide a path to existing GPO Machine Settings: "
            if(Test-Path -Path $answer -Include '*.pol', '*.txt'){
                if (!(Test-Path -Path "$truePath\New")){mkdir "$truePath\New"}
                if (!(Test-Path -Path "$truePath\New\Machine")){mkdir "$truePath\New\Machine"}
                if(Test-Path -Path $answer -Include '*.pol'){
                    .\LGPO.exe /parse /m $answer > lgpoMachine.txt
                    .\LGPO.exe /t "$truePath\lgpoMachine.txt"
                    # OR
                    .\LGPO.exe /r "$truePath\lgpoMachine.txt" /w "$truePath\New\Machine\registry.pol"
                    #.\LGPO.exe /m "$truePath\New\Machine\registry.pol"
                }else{
                    .\LGPO.exe /t $answer
                    # OR
                    .\LGPO.exe /r $answer /w "$truePath\New\Machine\registry.pol"
                    #.\LGPO.exe /m "$truePath\New\Machine\registry.pol"
                }
                $i=-1
            }else{
                Write-Output "Invalid Path. Path does not exist."
        }
        }
        for($i=1;$i -gt 0; $i++){
            $answerTwo=Read-Host -Prompt "Provide a path to existing GPO User Settings: "
            if(Test-Path -Path $answerTwo -Include '*.pol', '*.txt'){
                if (!(Test-Path -Path "$truePath\New")){mkdir "$truePath\New"}
                if (!(Test-Path -Path "$truePath\New\User")){mkdir "$truePath\New\User"}
                if(Test-Path -Path $answerTwo -Include '*.pol'){
                    .\LGPO.exe /parse /u $answerTwo > lgpoUser.txt
                    #Apply reg commands from txt
                    .\LGPO.exe /t "$truePath\lgpoUser.txt"
                    # OR
                    #Create new reg.pol from reg commands in txt
                    .\LGPO.exe /r "$truePath\lgpoUser.txt" /w "$truePath\New\User\registry.pol"
                    #Import new reg.pol
                    #.\LGPO.exe /u "$truePath\New\User\registry.pol"
                }else{
                    .\LGPO.exe /t $answerTwo
                    # OR
                    .\LGPO.exe /r $answerTwo /w "$truePath\New\User\registry.pol"
                    #.\LGPO.exe /u "$truePath\New\User\registry.pol"
                }
                $i=-1
            }else{
                Write-Output "Invalid Path. Path does not exist or does not contain valid file extensions."
        }
        }}
        7{for ($j=1; $j -gt 0; $j++){
            $usrChoicev2=Read-Host -Prompt "Please specify where compliance settings are stored.
    1)ThisPC 2)RemovableStorage
    3)Online 4)Quit
    Input 4 to quit."
            switch ($usrChoicev2){
                1{$usrPath=Read-Host -Prompt "Please enter local path for compliance settings: "

            }
                2{$usrPath=Read-Host -Prompt "Please enter external path (i.e. preceeding D:\, E:\ for compliance settings: )"

            }
                3{$usrPath=Read-Host -Prompt "Please enter uri for compliance settings: "
                #i.e. https://github.com/ArmsNA/AGPOv2/archive/refs/heads/main.zip
                $dlpath=
                Invoke-Webrequest -Uri $usrPath -OutFile $dlPath 
                Expand-Archive -Path $dlpath -DestinationPath $destPath -Force

            }
                4{$j=-1}
                default{'Invalid input. Please pick an item from the list numbered 1-4.'}
            }
        }
        Write-Host "Compliance Settings Applied"}
        8{.\LGPO.exe /m $mRegPath}
        9{.\LGPO.exe /u $uRegPath}
        10{.\LGPO.exe /m $mRegPath
        .\LGPO.exe /u $uRegPath
        }
        11{$i=-1}
        default{'Invalid input. Please pick an item from the list numbered 1-11.'}
    }
}

Write-Host "Cleaning up..."
rm -Recurse $dlPath
#Won't delete because lgpo is running @ destPath
#rm -Recurse $destPath
cd $prevPath
Write-Host "Done."
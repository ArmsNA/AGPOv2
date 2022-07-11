Write-Host "Hello, $env:UserName. Welcome to Armsna's Automated Group Policy Object Program."

$sourceUri="https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip"
$dlPath="C:\Users\$env:UserName\Downloads\LGPO.zip"
$destPath="C:\Program Files\LGPO"
$truePath='C:\Program Files\LGPO\LGPO_30'
#install lgpo ms utility to user (env) downloads
Set-ExecutionPolicy Unrestricted

Write-Host "Installing LGPO Microsoft Utility now..."
Invoke-Webrequest -Uri $sourceUri -OutFile $dlPath 
Write-Host "Unzipping lgpo.zip..."
Expand-Archive -Path $dlpath -DestinationPath $destPath -Force

Write-Host "Creating a backup directory if none is found..."
cd $truePath

# == and -ef work here
if ([string](Get-Location) -ieq $truePath){
	if (Test-Path -Path "$truePath\Backup") {
		Write-Host "Backup directory found. Storing GPO information in $truePath\Backup."
        Write-Host -NoNewLine "Would you like to overwrite the previous backup? Y/N: "
        for ($i=1; $i -gt 0; $i++){
            $answer=Read-Host
            if ($answer -ieq "Y"){
                rm -Recurse $truePath\Backup
                .\LGPO.exe /b $truePath /n "Backup"
                #latest=$(dir -td -- */ | head -n 1)
                $latest=gci $truePath | sort LastWriteTime | select -last 1
                mv $latest "$truePath\Backup"
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

for ($i=1; $i -gt 0; $i++){
    $usrChoice=Read-Host -Prompt "Please select options from the list below. 
1)ParseMachineRegistryFileANDApplySettings 2)ParseUserRegistryFileANDApplySettings 3)ParseAllRegistryFilesANDApplySettings 
4)ApplyExistingGPOsToMachineSettings 5)ApplyExistingGPOsToUserSettings 6)ApplyExistingGPOsToAllSettings 
7)ApplyMeetComplianceSettings 8)Quit
Input 8 to quit."
    switch ($usrChoice){
        1{.\LGPO.exe /parse /m "$bPath\DomainSysvol\GPO\Machine\registry.pol" > lgpoMachine.txt
            .\LGPO.exe /t "$truePath\lgpoMachine.txt"}
        2{.\LGPO.exe /parse /u "$bPath\DomainSysvol\GPO\User\registry.pol" > lgpoUser.txt
            .\LGPO.exe /u "$truePath\lgpoUser.txt"}
        3{.\LGPO.exe /parse /m "$bPath\DomainSysvol\GPO\Machine\registry.pol" > lgpoMachine.txt
            .\LGPO.exe /parse /u "bPath\DomainSysvol\GPO\User\registry.pol" > lgpoUser.txt
            .\LGPO.exe /t "$truePath\lgpoMachine.txt"
            .\LGPO.exe /u "$truePath\lgpoUser.txt"}
        4{for($i=1;$i -gt 0; $i++){
            $answer=Read-Host -Prompt "Provide a path to existing GPO Machine Settings: "
            if(Test-Path -Path $answer){
                .\LGPO.exe /t "$answer"
                $i=-1
            }else{
                Write-Output "Invalid Path. Path does not exist."
        }
        }}
        5{for($i=1;$i -gt 0; $i++){
            $answer=Read-Host -Prompt "Provide a path to existing GPO User Settings: "
            if(Test-Path -Path $answer){
                .\LGPO.exe /u "$answer"
                $i=-1
            }else{
                Write-Output "Invalid Path. Path does not exist."
            }
        }}
        6{for($i=1;$i -gt 0; $i++){
            $answer=Read-Host -Prompt "Provide a path to existing GPO Machine Settings: "
            if(Test-Path -Path $answer){
                .\LGPO.exe /t "$answer"
                $i=-1
            }else{
                Write-Output "Invalid Path. Path does not exist."
        }
        }
        for($i=1;$i -gt 0; $i++){
            $answerTwo=Read-Host -Prompt "Provide a path to existing GPO User Settings: "
            if(Test-Path -Path $answerTwo){
                .\LGPO.exe /u "$answerTwo"
                $i=-1
            }else{
                Write-Output "Invalid Path. Path does not exist."
        }
        }}
        7{#Apply compliance settings, pull from github? i.e. NIST 800-171
            Write-Host "Compliance Settings Applied"}
        8{$i=-1}
        default{'Invalid input. Please pick an item from the list numbered 1-8.'}
    }
}

[CmdletBinding()]
Param(
    [switch] $full = $false
)

$oPC = Read-Host -Prompt "Old PC name"
#Connection test old.
if (-not (Test-Connection -ComputerName $oPC -Count 1 -Quiet)){
    Throw "$oPC not found!"
}else{
    Write-Verbose -Message "$oPC connected successfully." 
}

$nPC = Read-Host -Prompt "New PC name"
#Connection test new.
if (-not (Test-Connection -ComputerName $nPC -Count 1 -Quiet)){
    Throw "$nPC not found!"
}else{
    Write-Verbose -Message "$nPC connected successfully." 
}

#Convert to SAMName: https://9to5it.com/powershell-find-ad-user-full-name/ (requires test in AD environment.)
$userName = Read-Host -Prompt "User to migrate"
#user test on old.
if (-not (Test-Path -Path "\\$oPC\c$\users\$userName")){
    Throw "User $userName doesn't have an account on $oPC."    
}else{
    $oldFolder = "\\$oPC\c$\users\$userName"
    Write-Verbose -Message "Profile for user, $userName, found on $oPC."
}

#user test on new.
if (-not (Test-Path -Path "\\$nPC\c$\users\$userName")){
    $prompt = Read-Host -Prompt "User $userName doesn't have an account. Create Backup folder?"
    if ($prompt -eq "y" -or $prompt -eq "yes"){
        New-Item -Path "\\$nPC\c$\Backup_$oPc_$userName" -ItemType Directory -Force
        Write-Host "C:\Backup__$oPC_$userName created."
        $newFolder = "\\$nPC\c$\Backup_$oPC_$userName"
    }else{
        $newFolder = "\\$nPC\c$\users\$userName"
        Write-Verbose -Message "Profile for user, $userName, found on $nPC."
    }
}

if ($full){
    Write-Verbose -Message "Copying data."
}else{
    Write-Host "Choose data to copy."
}

#Desktop
if (Test-Path -Path "$oldFolder\Desktop"){
    $fs = ((Get-ChildItem -Path "$oldFolder\Desktop" -Recurse | Measure-Object -Property Length -Sum).Sum / 1Mb)
    #Only if bigger than 2Kb = probably some default shortcuts.
    if ($fs -gt 0.002 -or $full){
        $fs = [math]::Round($fs, 2)
        if (-not $full) {
            $prompt = Read-Host -Prompt "Desktop contains $fs Mbs of data. Copy to $nPC?"
        }else{
            $prompt = "y"
        }
        if ($prompt -eq "y" -or $prompt -eq "yes"){
            Robocopy.exe "$oldFolder\Desktop" "$newFolder\Desktop" /E
            Write-Verbose -Message "Copying Desktop."
        }elseif($prompt -eq "n" -or $prompt -eq "no"){
            Write-Verbose -Message "Skipping Desktop."
        }else{
            Throw "Invalid input."
        }
    }else{
        Write-Verbose -Message "Desktop appears to be empty. Moving on."
    }
} else{
    Write-Verbose -Message "Desktop not found. Moving on."
}

#Pictures
if (Test-Path -Path "$oldFolder\Pictures"){
    $fs = ((Get-ChildItem -Path "$oldFolder\Pictures" -Recurse | Measure-Object -Property Length -Sum).Sum / 1Mb)
    if ($fs -gt 0.002 -or $full){
        $fs = [math]::Round($fs, 2)
        if (-not $full) {
            $prompt = Read-Host -Prompt "Pictures contains $fs Mbs of data. Copy to $nPC?"
        }else{
            $prompt = "y"
        }
        if ($prompt -eq "y" -or $prompt -eq "yes"){
            Robocopy.exe "$oldFolder\Pictures" "$newFolder\Pictures" /E
            Write-Verbose -Message "Copying Pictures."
        }elseif($prompt -eq "n" -or $prompt -eq "no"){
            Write-Verbose -Message "Skipping Pictures."
        }else{
            Throw "Invalid input."
        }
    }else{
        Write-Verbose -Message "Pictures appears to be empty. Moving on."
    }
} else{
    Write-Verbose -Message "Pictures not found. Moving on."
}

#Videos
if (Test-Path -Path "$oldFolder\Videos"){
    $fs = ((Get-ChildItem -Path "$oldFolder\Videos" -Recurse | Measure-Object -Property Length -Sum).Sum / 1Mb)
    if ($fs -gt 0.002 -or $full){
        $fs = [math]::Round($fs, 2)
        if (-not $full) {
            $prompt = Read-Host -Prompt "Videos contains $fs Mbs of data. Copy to $nPC?"
        }else{
            $prompt = "y"
        }
        if ($prompt -eq "y" -or $prompt -eq "yes"){
            Robocopy.exe "$oldFolder\Videos" "$newFolder\Videos" /E
            Write-Verbose -Message "Copying Videos."
        }elseif($prompt -eq "n" -or $prompt -eq "no"){
            Write-Verbose -Message "Skipping Videos."
        }else{
            Throw "Invalid input."
        }
    }else{
        Write-Verbose -Message "Videos appears to be empty. Moving on."
    }
} else{
    Write-Verbose -Message "Videos not found. Moving on."
}

#Skipping downloads and music because:
#1) Downloads is mostly junk and tends to contain duplicates.
#2) Music is rarelly used.
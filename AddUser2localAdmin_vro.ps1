function Resolve-SamAccount {
param(
    [string]
        $SamAccount,
    [boolean]
        $Exit
)
    process {
        try
        {
            $ADResolve = ([adsisearcher]"(samaccountname=$Trustee)").findone().properties['samaccountname']
        }
        catch
        {
            $ADResolve = $null
        }

        if (!$ADResolve) {
            Write-Warning "User `'$SamAccount`' not found in AD, please input correct SAM Account"
            if ($Exit) {
                exit
            }
        }
        $ADResolve
    }
}


$Trustee = [trustee]
$Computer = hostname

if (!$Trustee) {
    $Trustee = Read-Host "Please input trustee"
}

if ($Trustee -notmatch '\\') {
    $ADResolved = (Resolve-SamAccount -SamAccount $Trustee -Exit:$true)
    $Trustee = 'WinNT://',"$env:userdomain",'/',$ADResolved -join ''
} else {
    $ADResolved = ($Trustee -split '\\')[1]
    $DomainResolved = ($Trustee -split '\\')[0]
    $Trustee = 'WinNT://',$DomainResolved,'/',$ADResolved -join ''
}


if (!$Computer) {
	$Computer = Read-Host "Please input computer name"
}
[string[]]$Computer = $Computer.Split(',')
$Computer | ForEach-Object {
	$_
	Write-Host "Adding `'$ADResolved`' to Administrators group on `'$_`'"
	try {
		([ADSI]"WinNT://$_/Administrators,group").add($Trustee)
		Write-Host -ForegroundColor Green "Successfully completed command for `'$ADResolved`' on `'$_`'"
	} catch {
		Write-Warning "$_"
	}	
}
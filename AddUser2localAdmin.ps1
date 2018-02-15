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
            "User `'$SamAccount`' not found in AD, please input correct SAM Account" | out-file -FilePath 'c:/Windows/Temp/AddUserVro.log' -Append
            if ($Exit) {
                exit
            }
        }
        $ADResolve
    }
}

$Trustee = [Trustee]
$Computer = [Computer]

$ADResolved = (Resolve-SamAccount -SamAccount $Trustee -Exit:$true)
$Trustee = 'WinNT://',"$env:userdomain",'/',$ADResolved -join ''
"Starting Script to add $Trustee to Local Administrator" | Out-File -FilePath 'c:/Windows/Temp/AddUserVro.log'

[string[]]$Computer = $Computer.Split(',')
$Computer | ForEach-Object {
	$_
	"Adding `'$ADResolved`' to Administrators group on `'$_`'" | out-file -FilePath 'c:/Windows/Temp/AddUserVro.log' -Append
	try {
		([ADSI]"WinNT://$_/Administrators,group").add($Trustee)
		"Successfully completed command for `'$ADResolved`' on `'$_`'" | Out-File -FilePath 'c:/Windows/Temp/AddUserVro.log' -Append
	} catch {
		"ERROR: $_" | out-file -FilePath 'c:/Windows/Temp/AddUserVro.log' -Append
	}	
}

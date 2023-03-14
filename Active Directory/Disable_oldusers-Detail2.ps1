import-module activedirectory

#enter domain
$domain = "czg4s.local"

#lastlogontimestamp - last logged in since number of days  
$DaysInactive = 90  
$time = (Get-Date).Adddays(-($DaysInactive))
$logtime = get-date -format yyyy-MM-dd-HH-mm

# Creates file with list of Users, which not logged since specified date
Get-ADUser -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp,LastLogonDate,CanonicalName,Enabled | Select-object -Property Name,CanonicalName,LastLogonDate,Enabled | out-file -FilePath "C:\Scripts\OLD_User_$logtime.txt"

# Creates file with list of Users, which not logged since specified date in csv
Get-ADUser -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp,LastLogonDate,CanonicalName,Enabled,GivenName,Surname | Select-object -Property Name,GivenName,Surname,CanonicalName,LastLogonDate,LastLogonTimeStamp,Enabled | Export-Csv -Path "C:\Scripts\OLD_User_$logtime.txt" -Encoding UTF8

# If you would like to Disable these User accounts, uncomment the following line:
Get-ADUser -Property Name,lastLogonDate -Filter {lastLogonDate -lt $time} | Set-ADUser -Enabled $false

# If you would like to Disable users from editd list, where time stamp no longer applies
$Users = Get-Content "C:\scripts\disable_users_test.txt"
ForEach($User in $Users){
Get-ADUser -Filter {DisplayName -eq $User} |
Set-ADUser -Enabled $false -Verbose

}

# If you would like to Remove these User accounts, uncomment the following line:
# Get-ADUser -Property Name,lastLogonDate -Filter {lastLogonDate -lt $time} | Remove-ADUser

# Specify path to the text file with the User account names.
$Users = Get-Content "C:\scripts\OLD_User_$logtime.txt"

# Specify the path to the OU where Users will be moved.
$TargetOU =  "OU=ToDelete,DC=gennet,DC=cz"
ForEach( $User in $Users){
    Get-ADUser $User |
    Move-ADObject -TargetPath $TargetOU

}

# If you would like to Disable users from custom list
$Users = Get-Content "C:\scripts\disable_users_test.txt"
ForEach($User in $Users){
Get-ADUser -Filter {DisplayName -eq $User} |
Set-ADUser -Enabled $false -Verbose -WhatIf

}
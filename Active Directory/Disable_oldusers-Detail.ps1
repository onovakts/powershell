import-module activedirectory

#enter domain
$domain = "gennet.cz"

#lastlogontimestamp - last logged in since number of days  
$DaysInactive = 180  
$time = (Get-Date).Adddays(-($DaysInactive))
$logtime = get-date -format yyyy-MM-dd-HH-mm

# Creates file with list of Users, which not logged since specified date
Get-ADUser -Filter {LastLogonTimeStamp -lt $time -and Enabled -eq $TRUE} -Properties LastLogonTimeStamp,LastLogonDate,CanonicalName,Enabled | Select-object -Property Name,CanonicalName,LastLogonDate,Enabled | out-file -FilePath "C:\Scripts\OLD_User_$logtime.txt"

# If you would like to Disable these User accounts, uncomment the following line:
Get-ADUser -Property Name,lastLogonDate -Filter {lastLogonDate -lt $time} | Set-ADUser -Enabled $false

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
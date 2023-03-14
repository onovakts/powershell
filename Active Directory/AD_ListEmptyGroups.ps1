# Imports Module to PowerShell Session
Import-Module ActiveDirectory

# Get a list of all security groups in the domain
$groups = Get-ADGroup -Filter {GroupCategory -eq 'Security'} -Properties Members, DistinguishedName

# Iterate through each group and check if it has any members
foreach ($group in $groups) {
  # If the group has no members, output the group name and distinguished name
  if ($group.Members.Count -eq 0) {
    Write-Output "$($group.Name) - $($group.DistinguishedName)"
  }
}

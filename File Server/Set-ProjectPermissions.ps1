#OU where security groups will be created!
$ou = "OU=Test,OU=Skupiny,DC=cz,DC=kajimaeurope,DC=com"

# Import list of folders
$subfolders = Import-Csv -Path .\security_groups.csv -Encoding UTF8

# Loop through each subfolder

foreach ($subfolder in $subfolders) {
    Write-Host "Working on folder: $($subfolder.Path)" -ForegroundColor Cyan

    # Create the security groups in Active Directory

    #New-ADGroup -Name $subfolder.R -GroupScope Global -GroupCategory Security -Description $subfolder.Path -Path $ou

    #New-ADGroup -Name $subfolder.RW -GroupScope Global -GroupCategory Security -Description $subfolder.Path -Path $ou



    # Get the security descriptor for the subfolder

    $acl = Get-Acl $subfolder.Path



    # Create a new access rule for the read-only security group
    $readGroupName = $subfolder.R

    $readAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($readGroupName, "ReadAndExecute","ContainerInherit,ObjectInherit", "NoPropagateInherit", "Allow")

    $acl.SetAccessRule($readAccessRule)



    # Create a new access rule for the read/write security group
    $readWriteGroupName = $subfolder.RW

    $readWriteAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($readWriteGroupName, "Modify","ContainerInherit,ObjectInherit", "NoPropagateInherit", "Allow")

    $acl.SetAccessRule($readWriteAccessRule)



    # Set the modified security descriptor on the subfolder

    Set-Acl $subfolder.Path $acl


<#
    # Recursively set the permissions on all subfolders and files within the subfolder

    Get-ChildItem $subfolder.FullName -Recurse | ForEach-Object {

        # Get the security descriptor for the current item

        $itemAcl = Get-Acl $_.FullName



        # Set the modified security descriptor on the current item

        Set-Acl $_.FullName $itemAcl

    }

    #>

}


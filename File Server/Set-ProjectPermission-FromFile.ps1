# Set the path to the folder containing the subfolders you want to create groups for
$folderPath = "C:\Scripts\Projects"

# Get a list of subfolders in the specified folder path
$subfolders = Get-ChildItem $folderPath | Where-Object { $_.PSIsContainer }

# Loop through each subfolder
foreach ($subfolder in $subfolders) {
    # Create the names for the two security groups based on the subfolder name
    $readGroupName = $subfolder.Name + "_R"
    $readWriteGroupName = $subfolder.Name + "_RW"

    # Create the security groups in Active Directory
    New-ADGroup -Name $readGroupName -GroupScope Global -GroupCategory Security -Path ""
    New-ADGroup -Name $readWriteGroupName -GroupScope Global -GroupCategory Security -Path ""

    # Get the security descriptor for the subfolder
    $acl = Get-Acl $subfolder.FullName

    # Create a new access rule for the read-only security group
    $readAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($readGroupName, "ReadAndExecute","ContainerInherit,ObjectInherit", "NoPropagateInherit", "Allow")
    $acl.SetAccessRule($readAccessRule)

    # Create a new access rule for the read/write security group
    $readWriteAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($readWriteGroupName, "Modify","ContainerInherit,ObjectInherit", "NoPropagateInherit", "Allow")
    $acl.SetAccessRule($readWriteAccessRule)

    # Set the modified security descriptor on the subfolder
    Set-Acl $subfolder.FullName $acl

    # Recursively set the permissions on all subfolders and files within the subfolder
    Get-ChildItem $subfolder.FullName -Recurse | ForEach-Object {
        # Get the security descriptor for the current item
        $itemAcl = Get-Acl $_.FullName

        # Set the modified security descriptor on the current item
        Set-Acl $_.FullName $itemAcl
    }
}

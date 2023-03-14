# Import the Active Directory module
Import-Module ActiveDirectory

# Set the input and output file paths
$inputFile = 'C:\path\to\input.txt'
$outputFile = 'C:\path\to\output.txt'

# Read the names from the input file
$names = Get-Content $inputFile

# Initialize an empty array to store the SamAccountNames
$samAccountNames = @()

# Loop through the names and get the corresponding SamAccountName for each
foreach ($name in $names) {
   $user = Get-ADUser -Filter "Name -eq '$name'" -Properties SamAccountName
   $samAccountNames += $user.SamAccountName
}

# Write the SamAccountNames to the output file
$samAccountNames | Out-File $outputFile

# Display a message indicating the script has completed
Write-Output "Transformation complete!"

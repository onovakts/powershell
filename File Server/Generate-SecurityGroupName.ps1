# Set the path to the folder containing the subfolders you want to create groups for
$folderPath = "P:\xxx"

# Get a list of subfolders in the specified folder path
$subfolders = Get-ChildItem $folderPath | Where-Object { $_.PSIsContainer }
$groupsList = @()

# Loop through each subfolder
foreach ($subfolder in $subfolders) {

    # Remove diacritics from folder name and replace spec. chars
    $normalized = $($subfolder.Name).Normalize( [Text.NormalizationForm]::FormD )
    $sb = new-object Text.StringBuilder
    $normalized.ToCharArray() | % { 
        if( [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($_)
        }
    }
    $normalized = $sb.ToString() -replace '\.','_' -replace ' ','_' -replace ',','' -replace '\+','-'

    
    $object = [PSCustomObject]@{
        Path     = $subfolder.FullName
        R = $normalized + "_R"
        RW    = $normalized + "_RW"
    }

    $groupsList += $object
 
}

$groupsList | Export-Csv -Path .\security_groups.csv -Encoding UTF8 -NoTypeInformation


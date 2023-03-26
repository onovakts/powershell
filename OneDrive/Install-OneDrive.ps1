# Set the error action preference to silently continue
$ErrorActionPreference = "SilentlyContinue"

# Initialize logging
$logSource = "OneDrive Per-Machine Deployment"
if (![System.Diagnostics.EventLog]::SourceExists($logSource)){
    new-eventlog -LogName Application -Source $logSource
}

# Configuration details go here
# Specify the location of the OneDriveSetup.exe
$installationSource = "\\Network\Path\Here"
# Specify the destination path for the installation
$destinationPath = "C:\Program Files (x86)\Microsoft OneDrive"
# Get the version of the currently installed OneDrive
$installedVersion = (Get-Command "$destinationPath\OneDriveSetup.exe").FileVersionInfo.FileVersion

# Attempt to get the target version of OneDrive
try{
    # Set the error action preference to stop so that any errors are thrown and caught in the catch block
    $ErrorActionPreference = "Stop"
    # Get the version of the target OneDrive
    $targetVersion = (Get-Command "$installationSource\OneDriveSetup.exe").FileVersionInfo.FileVersion
} catch{
    # Log an error event if the target version cannot be determined and exit the script
    write-eventlog -LogName Application -Source $logSource -EntryType Error -EventId 900 -Message "Unable to determine target OneDrive version - check network connectivity or existence of deployment files."
    Exit
}

# Set the error action preference back to silently continue
$ErrorActionPreference = "SilentlyContinue"

# Log events for each step of the deployment process
if ($targetVersion -ne $installedVersion){
    # Log an information event if OneDrive is not installed or out of date
    write-eventlog -LogName Application -Source $logSource -EntryType Information -EventId 1 -Message "Microsoft OneDrive not installed or out of date. Installed version: $installedVersion; target version: $targetVersion. Installation starting..."

    if (Test-Path ($destinationPath)){
        # Remove the existing OneDrive installation if it exists
        Remove-Item $destinationPath -recurse
        # Log an information event if the existing installation was removed
        write-eventlog -LogName Application -Source $logSource -EntryType Information -EventId 2 -Message "Existing OneDrive installation removed"
    }

    # Install the new version of OneDrive
    & "$installationSource\OneDriveSetup.exe" /allusers

    # Log an information event when the installation is complete
    write-eventlog -LogName Application -Source $logSource -EntryType Information -EventId 5 -Message "OneDrive installation complete"
}

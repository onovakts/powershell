# Set the source and destination directories
$source = "C:\"
$destination = "C:\BMPN\"

# Get all .bpmn files in the source directory
$bpmnFiles = Get-ChildItem $source -Include *.bpmn -Recurse

# Copy each .bpmn file to the destination directory
foreach ($file in $bpmnFiles) {
    Copy-Item $file.FullName $destination
}

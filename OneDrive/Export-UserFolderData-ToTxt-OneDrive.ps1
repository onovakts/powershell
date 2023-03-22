#Generate Certificate
#New-PnPAzureCertificate -OutPfx pnp.pfx -OutCert pnp.cer
#Install Certificate in Machine Personal store
#Import-PfxCertificate -Exportable -CertStoreLocation Cert:\LocalMachine\My -FilePath .\pnp.pfx -Confirm

#Set Runtime Parameters  
$AdminSiteURL=

#Global Admin  
$SiteCollAdmin=

#AppInfo - Select From AAD and App Registration
$clientid = 
$thumbrint = 
$tenantid = 

#Document Library from OneDrive
$Listname = "Documents"
$Pagesize = 500
$ExportFolder="C:\Scripts"
$ExportFile="OD.txt"

#Connect to SharePoint Online Admin Center  
Connect-PnPOnline -tenant $tenantid -url $AdminSiteURL -ClientId $clientid -Thumbprint $thumbrint

#Get all OneDrive for Business Site collections  
$OneDriveSites = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'"
Write-Host -f Yellow "Total Number of OneDrive Sites Found: "$OneDriveSites.count  

#Create txt file with all OD in Tenant
$OneDriveSites.Url | Out-File -FilePath $ExportFolder\$ExportFile
$Content=Get-Content -Path "$ExportFolder\$ExportFile"

Read-Host -Prompt "Export was created in $ExportFolder\$ExportFile, check the content or edit it, If you want to continue press ENTER or CTRL+C to quit"

#Add Site Collection Admin to each OneDrive and list through their OD  
Foreach($Site in $Content)  
{  
    #Adds SiteCollectionAdmin for OneDrive for Business
    Connect-PnPOnline -tenant $tenantid -url $Site -ClientId $clientid -Thumbprint $thumbrint
    Write-Host -f Yellow "Adding Site Collection Admin to: "$Site 
    Add-PnPSiteCollectionAdmin -Owners $SiteCollAdmin -Verbose 
    
    $List = Get-PnPList -Identity $ListName
    $global:counter = 0;
    $ListItems = Get-PnPListItem -List $ListName -PageSize $Pagesize -Fields Author, Editor, Created, File_x0020_Type -ScriptBlock `
    { Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete ($global:Counter / ($List.ItemCount) * 100) -Activity `
    "Getting Documents from Library '$($List.Title)'" -Status "Getting Documents data $global:Counter of $($List.ItemCount)";} | Where {$_.FileSystemObjectType -eq "Folder"}
    
    #Array to store results
    $Results = @()

    $ItemCounter = 0
    #Iterate through each item
    Foreach ($Item in $ListItems)
    {
    $Results += New-Object PSObject -Property ([ordered]@{
    Name = $Item["FileLeafRef"]
    Type = $Item.FileSystemObjectType
    FileType = $Item["File_x0020_Type"]
    RelativeURL = $Item["FileRef"]
    #CreatedByEmail = $Item["Author"].Email
    #CreatedOn = $Item["Created"]
    #Modified = $Item["Modified"]
    #ModifiedByEmail = $Item["Editor"].Email      
    })
    $ItemCounter++
    Write-Progress -PercentComplete ($ItemCounter / ($List.ItemCount) * 100) -Activity "Exporting data from Documents $ItemCounter of $($List.ItemCount)" -Status "Exporting Data from Document '$($Item['FileLeafRef'])"
    
    $Users = $Item["Author"].LookupValue
    $ReportOutput = "C:\scripts\$Users.csv"

    #Export the results to CSV
    $Results | Export-Csv -Path $ReportOutput -NoTypeInformation -Encoding utf8
    
    }
  
}  
Write-Host "Export Done" -f Green
$Desktop = (Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -name "Desktop").Desktop

if ($Desktop -notlike "*Onedrive*") {
    ##configure kfm
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1" -Name "KfmIsDoneSilentOptIn" -Value 0 -Force -type dword
    write-host "successfully set the regkey to force the kfm"

    $filename = $env:username + ".txt"
    $filepath = "\\rogo-file-01\Users Folders\OneDrive\kfm\open\" + $filename
    (get-date) | out-file $filepath -append -force
}
else {
    ## set a marker file that the kfm move is done
    $filename = $env:username + ".txt"
    $filepath = "\\rogo-file-01\Users Folders\OneDrive\kfm\done\" + $filename
    $oldfilename = "\\rogo-file-01\Users Folders\OneDrive\kfm\open\" + $filename

    if (test-path $oldfilename) { 
        remove-item -path $oldfilename -Force 
    }
    (get-date) | out-file $filepath -append -force


    ## cleanup recycle bin folders

    $allfoldertypes = @("desktop", "downloads", "dokumente", "documents")
    foreach ($singlefoldertype in $allfoldertypes) {

        $folderpath = $env:OneDriveCommercial + "\$singlefoldertype"
        $allsubfolders = get-childitem $folderpath 
        foreach($singlesubfolder in $allsubfolders)
        { $foldername = $singlesubfolder.name
            if ($foldername -eq "\$RECYCLE.BIN") { 
                $foldername = $singlesubfolder.fullname
                remove-item -path $foldername -force -recurse 
            }
        }
    }
}

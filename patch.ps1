Write-Host "`nLethal Company Online Patch by: https://github.com/meguminsama`n"

Write-Host "Make sure you're using a modern version of PowerShell. Otherwise this might break."
Write-Host "If you're not, you can download it here:"
Write-Host "https://github.com/PowerShell/PowerShell/releases/tag/v7.4.0`n"

function Main {
    $levelDir = "Lethal Company_Data"
    $file = "level1"
    $levelFile = "$levelDir\$file"
    $backupFile = "$levelDir\$file.bak"

    Write-Host "Reading Level File"
    $data = Read-LevelFile($levelFile)
    
    # if already patched, don't patch again
    if (Get-IsPrePatched($data)) {
        Write-Host "`nLevel File is already patched."
        Write-Host "`nTo remove the patch:"
        Write-Host "  1. Navigate to the `"$levelDir`" folder"
        Write-Host "  2. Delete the `"$file`" file"
        Write-Host "  2. Rename `"$file.bak`" to `"$file`"`n"
        cmd /c
        exit
    }
    
    # back up level1
    Write-Host "Backing up Level File..."
    Copy-Item -Path $levelFile -Destination $backupFile -Force
    
    Write-Host "`nApplying Online Patch..."
    $data = Invoke-Patch($data)
    
    Set-Content -Path $levelFile -AsByteStream -Value $data
    
    Write-Host "Online Patch Applied...`n"

    cmd /c
}

function Invoke-Patch {
    param (
        [string] $data
    )
    $data = $data -replace '\b80 2 1E 0\b', 'E0 1 0 0'
    [byte[]] $data = -split $data -replace '^', '0x'
    return $data
}

function Read-LevelFile {
    param (
        [string] $path
    )
    $data = Get-Content $path -Raw -AsByteStream
    $data = $data.forEach('ToString', 'X') -join ' '
    return $data
}

function Get-IsPrePatched {
    param (
        [string] $data
    )
    $result = $data.Contains('E0 1 0 0') -And -Not $data.Contains('80 2 1E 0')
    return $result
}

Main

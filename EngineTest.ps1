$scriptDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptDir)) { $scriptDir = $PWD.Path }
$jsonPath = Join-Path $scriptDir "rules.json"

# Sesuaikan folder uji coba
$source = "D:\1. Project\Asisten Perapih - v2\Testing Fase 1\Sumber" 
$dest = "D:\1. Project\Asisten Perapih - v2\Testing Fase 1\Tujuan"   

if (!(Test-Path $jsonPath)) {
    Write-Host "Error: File rules.json tidak ditemukan!" -ForegroundColor Red
    return
}

$rules = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json
$allFiles = Get-ChildItem -LiteralPath $source -File -Recurse

Write-Host "1. Memulai Pemindaian & Pemindahan File..." -ForegroundColor Cyan
Write-Host "---------------------------------"

foreach ($file in $allFiles) {
    $matchedTopic = $null
    $matchedFallback = $null
    $fileName = $file.Name.ToLower()
    $fileExt = $file.Extension.ToLower()

    # Cek Topik Dulu
    foreach ($topic in $rules.TopicRules) {
        foreach ($kw in $topic.Keywords) {
            if ($fileName -like "*$kw*") {
                $matchedTopic = $topic.CategoryName
                break
            }
        }
        if ($matchedTopic) { break }
    }

    if ($matchedTopic) {
        $targetFolder = Join-Path $dest $matchedTopic
    } else {
        # Cek Ekstensi Jika Topik Tidak Cocok
        foreach ($fallback in $rules.ExtensionFallback) {
            if ($fallback.Extensions -contains $fileExt) {
                $matchedFallback = $fallback.CategoryName
                break
            }
        }
        if ($matchedFallback) {
            $targetFolder = Join-Path $dest $matchedFallback
        } else {
            $targetFolder = Join-Path $dest "5_File_Lainnya"
        }
    }

    if (!(Test-Path -LiteralPath $targetFolder)) { New-Item -ItemType Directory -Force -Path $targetFolder | Out-Null }
    
    # Blok Try-Catch menggunakan ROBOCOPY sebagai Ultimate Fallback
    try {
        Move-Item -LiteralPath $file.FullName -Destination $targetFolder -Force -ErrorAction Stop
        Write-Host "SUKSES -> $($file.Name)" -ForegroundColor Gray
    } catch {
        try {
            # Trik pamungkas: Pakai ROBOCOPY (kebal limit 260 karakter dari Windows)
            # Syntax: robocopy "FolderAsal" "FolderTujuan" "NamaFile" /MOV (pindahkan)
            $roboArgs = "`"$($file.DirectoryName)`" `"$targetFolder`" `"$($file.Name)`" /MOV /NJH /NJS /NDL /NC /NS /NP"
            $runRobo = Start-Process "robocopy.exe" -ArgumentList $roboArgs -Wait -WindowStyle Hidden -PassThru
            
            # Robocopy sukses jika ExitCode di bawah 8
            if ($runRobo.ExitCode -lt 8) {
                Write-Host "SUKSES (Mode Paksa Robocopy) -> $($file.Name)" -ForegroundColor Yellow
            } else {
                throw "Robocopy gagal membaca file."
            }
        } catch {
            Write-Host "GAGAL TOTAL -> $($file.Name)" -ForegroundColor Red
            Write-Host "Alasan: File sedang dibuka di aplikasi lain!" -ForegroundColor DarkRed
        }
    }
}

Write-Host "---------------------------------"
Write-Host "2. Membersihkan Sub-folder Kosong..." -ForegroundColor Cyan

$emptyFolders = Get-ChildItem -LiteralPath $source -Directory -Recurse | 
    Sort-Object -Property @{Expression={$_.FullName.Length};Descending=$true}

foreach ($folder in $emptyFolders) {
    if ((Get-ChildItem -LiteralPath $folder.FullName -Force).Count -eq 0) {
        Remove-Item -LiteralPath $folder.FullName -Force
    }
}

Write-Host "---------------------------------"
Write-Host "Uji Coba Mesin Selesai!" -ForegroundColor Green
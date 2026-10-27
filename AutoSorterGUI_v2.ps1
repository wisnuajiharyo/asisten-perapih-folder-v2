# Memuat modul antarmuka grafis Windows
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- SETUP JSON & PATH ---
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptDir)) { $scriptDir = $PWD.Path }
$jsonPath = Join-Path $scriptDir "rules.json"

# Buat JSON Default jika belum ada
if (!(Test-Path $jsonPath)) {
    $defaultJson = @{
        TopicRules = @(
            @{ CategoryName = "Laporan Keuangan"; Keywords = @("keuangan", "anggaran", "rka", "rincian belanja") },
            @{ CategoryName = "Berkas Kepegawaian"; Keywords = @("sipp", "siasn", "sk", "kinerja") }
        )
        ExtensionFallback = @(
            @{ CategoryName = "1_Dokumen"; Extensions = @(".pdf", ".docx", ".doc", ".xlsx", ".xls", ".ppt", ".pptx", ".csv", ".txt", ".rtf") },
            @{ CategoryName = "2_Gambar"; Extensions = @(".png", ".jpg", ".jpeg", ".mp4") },
            @{ CategoryName = "3_Aplikasi"; Extensions = @(".exe", ".msi", ".bat") },
            @{ CategoryName = "4_Arsip_ZIP"; Extensions = @(".zip", ".rar") }
        )
    } | ConvertTo-Json -Depth 4
    Set-Content -Path $jsonPath -Value $defaultJson
}

# 1. Membuat Jendela Utama
$form = New-Object System.Windows.Forms.Form
$form.Text = "Asisten Perapih Folder v2.0 (whizz-projectz)"
$form.Size = New-Object System.Drawing.Size(520,530)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# 2. Panel Pilihan Folder
$lblFolder = New-Object System.Windows.Forms.Label
$lblFolder.Text = "1. Pilih Folder yang Akan Dirapikan:"
$lblFolder.Location = New-Object System.Drawing.Point(20,20)
$lblFolder.AutoSize = $true
$form.Controls.Add($lblFolder)

$txtFolder = New-Object System.Windows.Forms.TextBox
$txtFolder.Location = New-Object System.Drawing.Point(20,40)
$txtFolder.Size = New-Object System.Drawing.Size(350,20)
$form.Controls.Add($txtFolder)

$btnFolder = New-Object System.Windows.Forms.Button
$btnFolder.Text = "Cari Folder..."
$btnFolder.Location = New-Object System.Drawing.Point(380,38)
$form.Controls.Add($btnFolder)

$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$btnFolder.Add_Click({
    if ($FolderBrowser.ShowDialog() -eq 'OK') { $txtFolder.Text = $FolderBrowser.SelectedPath }
})

# 3. Panel Manajemen Aturan Cepat
$groupRules = New-Object System.Windows.Forms.GroupBox
$groupRules.Text = "2. Buat Pengelompokan Khusus (Opsional)"
$groupRules.Location = New-Object System.Drawing.Point(20, 75)
$groupRules.Size = New-Object System.Drawing.Size(460, 110)
$form.Controls.Add($groupRules)

$lblKat = New-Object System.Windows.Forms.Label
$lblKat.Text = "Nama Kategori (Sub-folder):"
$lblKat.Location = New-Object System.Drawing.Point(15, 25)
$lblKat.AutoSize = $true
$groupRules.Controls.Add($lblKat)

$txtKat = New-Object System.Windows.Forms.TextBox
$txtKat.Location = New-Object System.Drawing.Point(15, 45)
$txtKat.Size = New-Object System.Drawing.Size(200,20)
$groupRules.Controls.Add($txtKat)

$lblKw = New-Object System.Windows.Forms.Label
$lblKw.Text = "Jika file mengandung kata (pisah koma):"
$lblKw.Location = New-Object System.Drawing.Point(230, 25)
$lblKw.AutoSize = $true
$groupRules.Controls.Add($lblKw)

$txtKw = New-Object System.Windows.Forms.TextBox
$txtKw.Location = New-Object System.Drawing.Point(230, 45)
$txtKw.Size = New-Object System.Drawing.Size(215,20)
$groupRules.Controls.Add($txtKw)

$btnAddRule = New-Object System.Windows.Forms.Button
$btnAddRule.Text = "+ Simpan Kategori Pengelompokan"
$btnAddRule.Location = New-Object System.Drawing.Point(15, 75)
$btnAddRule.Size = New-Object System.Drawing.Size(430, 25)
$groupRules.Controls.Add($btnAddRule)

# Logika Tombol Simpan Aturan
$btnAddRule.Add_Click({
    if ($txtKat.Text -eq "" -or $txtKw.Text -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Nama Folder dan Kata Kunci harus diisi!", "Peringatan", 0, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    $newKeywords = $txtKw.Text -split "," | ForEach-Object { $_.Trim().ToLower() }
    
    $configData = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json
    $newRule = [PSCustomObject]@{ CategoryName = $txtKat.Text; Keywords = $newKeywords }
    $configData.TopicRules += $newRule
    
    $configData | ConvertTo-Json -Depth 4 | Set-Content -Path $jsonPath
    [System.Windows.Forms.MessageBox]::Show("Kategori '$($txtKat.Text)' berhasil disimpan!", "Sukses", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
    $txtKat.Text = ""; $txtKw.Text = ""
})

# 4. Panel Opsi Eksekusi
$groupOps = New-Object System.Windows.Forms.GroupBox
$groupOps.Text = "3. Pengaturan Tambahan (Aman Digunakan)"
$groupOps.Location = New-Object System.Drawing.Point(20, 195)
$groupOps.Size = New-Object System.Drawing.Size(460, 110)
$form.Controls.Add($groupOps)

$chkDeepScan = New-Object System.Windows.Forms.CheckBox
$chkDeepScan.Text = "Rapikan juga file yang terselip di dalam sub-folder"
$chkDeepScan.Location = New-Object System.Drawing.Point(15, 25)
$chkDeepScan.Size = New-Object System.Drawing.Size(430, 20)
$chkDeepScan.Checked = $true
$groupOps.Controls.Add($chkDeepScan)

$chkCleanup = New-Object System.Windows.Forms.CheckBox
$chkCleanup.Text = "Bersihkan folder lama yang sudah benar-benar kosong"
$chkCleanup.Location = New-Object System.Drawing.Point(15, 50)
$chkCleanup.Size = New-Object System.Drawing.Size(430, 20)
$chkCleanup.Checked = $true
$groupOps.Controls.Add($chkCleanup)

$lblPreset = New-Object System.Windows.Forms.Label
$lblPreset.Text = "Pola Folder:"
$lblPreset.Location = New-Object System.Drawing.Point(15, 80)
$lblPreset.AutoSize = $true
$groupOps.Controls.Add($lblPreset)

$comboPreset = New-Object System.Windows.Forms.ComboBox
$comboPreset.Location = New-Object System.Drawing.Point(90, 77)
$comboPreset.Size = New-Object System.Drawing.Size(355, 20)
$comboPreset.DropDownStyle = "DropDownList"
@("1. Pengelompokan Bebas (Sesuai Aturan)", "2. Metode PARA (Projects, Areas, Resources, Archives)") | ForEach-Object { [void]$comboPreset.Items.Add($_) }
$comboPreset.SelectedIndex = 0
$groupOps.Controls.Add($comboPreset)

# 5. UI Progress & Eksekusi
$btnProses = New-Object System.Windows.Forms.Button
$btnProses.Text = "Mulai Rapikan Folder"
$btnProses.Location = New-Object System.Drawing.Point(20, 320)
$btnProses.Size = New-Object System.Drawing.Size(460, 45)
$btnProses.BackColor = "LightGreen"
$btnProses.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnProses)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 380)
$progressBar.Size = New-Object System.Drawing.Size(460, 20)
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(20, 405)
$lblStatus.Size = New-Object System.Drawing.Size(460, 40)
$lblStatus.Text = "Menyiapkan..."
$lblStatus.Visible = $false
$form.Controls.Add($lblStatus)

# 6. Logika Utama (The Brain integration)
$btnProses.Add_Click({
    $targetDir = $txtFolder.Text
    if ($targetDir -eq "") { [System.Windows.Forms.MessageBox]::Show("Pilih folder yang ingin dirapikan terlebih dahulu!"); return }
    
    $btnProses.Enabled = $false; $progressBar.Visible = $true; $lblStatus.Visible = $true
    [System.Windows.Forms.Application]::DoEvents()

    $rules = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json
    $isPara = $comboPreset.SelectedIndex -eq 1
    
    if ($chkDeepScan.Checked) { $allFiles = Get-ChildItem -LiteralPath $targetDir -File -Recurse } 
    else { $allFiles = Get-ChildItem -LiteralPath $targetDir -File }

    if ($allFiles.Count -eq 0) {
        $lblStatus.Text = "Tidak ada file untuk diproses.";
        $btnProses.Enabled = $true; return
    }

    $progressBar.Maximum = $allFiles.Count
    $progressBar.Value = 0

	foreach ($file in $allFiles) {
        $lblStatus.Text = "Memproses: $($file.Name)"
        [System.Windows.Forms.Application]::DoEvents()
        
        $fileName = $file.Name.ToLower()
        $fileExt = $file.Extension.ToLower()
        $targetFolder = ""

        if ($isPara) {
            if ($fileName -match "(proyek|project|rka|revisi|draft)") { $targetFolder = Join-Path $targetDir "1_Projects" }
            elseif ($fileName -match "(pajak|kepegawaian|sipp|siasn|laporan)") { $targetFolder = Join-Path $targetDir "2_Areas" }
            elseif ($fileName -match "(template|aset|icon|panduan)") { $targetFolder = Join-Path $targetDir "3_Resources" }
            else { $targetFolder = Join-Path $targetDir "4_Archives" }
        } else {
            $matchedTopic = $null
            foreach ($topic in $rules.TopicRules) {
                foreach ($kw in $topic.Keywords) {
                    if ($fileName -like "*$kw*") { $matchedTopic = $topic.CategoryName; break }
                }
                if ($matchedTopic) { break }
            }
            if ($matchedTopic) { $targetFolder = Join-Path $targetDir $matchedTopic } 
            else {
                $matchedFallback = $null
                foreach ($fallback in $rules.ExtensionFallback) {
                    if ($fallback.Extensions -contains $fileExt) { $matchedFallback = $fallback.CategoryName; break }
                }
                if ($matchedFallback) { $targetFolder = Join-Path $targetDir $matchedFallback } 
                else { $targetFolder = Join-Path $targetDir "5_File_Lainnya" }
            }
        }

        # --- BLOK SENSOR (TETAP DIPERTAHANKAN) ---
        if ($file.DirectoryName -eq $targetFolder) { 
            $progressBar.Value++; continue 
        }

        if (!(Test-Path -LiteralPath $targetFolder)) { New-Item -ItemType Directory -Force -Path $targetFolder | Out-Null }
        
        # --- BLOK BARU: AUTO-RENAME POSTFIX MENCEGAH BENTROK ---
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $ext = $file.Extension
        $finalName = $file.Name
        $destPath = Join-Path $targetFolder $finalName

        $angka = 1
        while (Test-Path -LiteralPath $destPath) {
            $finalName = "${baseName}_${angka}${ext}"
            $destPath = Join-Path $targetFolder $finalName
            $angka++
        }
        
        try {
            Move-Item -LiteralPath $file.FullName -Destination $destPath -ErrorAction Stop
        } catch {
            try {
                if ($finalName -ne $file.Name) {
                    $renArgs = "/c ren `"$($file.FullName)`" `"$finalName`""
                    Start-Process "cmd.exe" -ArgumentList $renArgs -Wait -WindowStyle Hidden
                }
                
                $roboArgs = "`"$($file.DirectoryName)`" `"$targetFolder`" `"$finalName`" /MOV /NJH /NJS /NDL /NC /NS /NP"
                $runRobo = Start-Process "robocopy.exe" -ArgumentList $roboArgs -Wait -WindowStyle Hidden -PassThru
                if ($runRobo.ExitCode -ge 8) { throw "Robocopy Failed" }
            } catch {
                # Skip file terkunci
            }
        }
        $progressBar.Value++
    }

    if ($chkCleanup.Checked) {
        $lblStatus.Text = "Membersihkan sisa folder kosong..."
        [System.Windows.Forms.Application]::DoEvents()
        $emptyFolders = Get-ChildItem -LiteralPath $targetDir -Directory -Recurse | Sort-Object -Property @{Expression={$_.FullName.Length};Descending=$true}
        foreach ($folder in $emptyFolders) {
            $isTargetFolder = $false
            foreach ($rule in $rules.TopicRules) { if ($folder.Name -eq $rule.CategoryName) { $isTargetFolder = $true; break } }
            if ($isPara -and $folder.Name -match "^(1_Projects|2_Areas|3_Resources|4_Archives)$") { $isTargetFolder = $true }
            
            if (!$isTargetFolder -and (Get-ChildItem -LiteralPath $folder.FullName -Force).Count -eq 0) {
                Remove-Item -LiteralPath $folder.FullName -Force
            }
        }
    }

    $lblStatus.Text = "Selesai!"
    [System.Windows.Forms.MessageBox]::Show("Folder berhasil dirapikan!", "Sukses", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
    $btnProses.Enabled = $true; $progressBar.Visible = $false; $lblStatus.Visible = $false
})

$form.ShowDialog()
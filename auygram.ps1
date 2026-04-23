# Принудительная загрузка библиотек GUI
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$dec = [System.Text.Encoding]::UTF8
# Base64 строки для GUI (СЕССИИ TELEGRAM, ПЕРЕЗАПУСТИТЬ ПРОКСИ)
$txtTitle = $dec.GetString([System.Convert]::FromBase64String("0KHQldCh0KHQmNCYIFRFTEVHUkFN"))
$txtProxy = $dec.GetString([System.Convert]::FromBase64String("0J/QldCg0JXQl9CQ0J/Qo9Ch0KLQmNCi0Kwg0J/QoNCe0JrQodCY"))

$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$ErrorActionPreference = "SilentlyContinue"

# Поиск прокси
$proxy = $null
$searchPaths = @($base, "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Downloads")
foreach ($p in $searchPaths) {
    $exe = Join-Path $p "TgWsProxy_windows.exe"
    if (Test-Path $exe) { $proxy = $exe; break }
}

# Поиск сессий
$sessions = @()
$dirs = Get-ChildItem -Path $base -Directory
foreach ($d in $dirs) {
    $ayuLocal = Join-Path $d.FullName "AyuGram.exe"
    if (Test-Path $ayuLocal) {
        $obj = New-Object PSObject
        $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $d.Name
        $obj | Add-Member -MemberType NoteProperty -Name "Path" -Value $ayuLocal
        $sessions += $obj
    }
}
$sessions = $sessions | Sort-Object Name

# Создание окна
$form = New-Object System.Windows.Forms.Form
$form.Text = "AyuGram Launcher"
$form.Size = New-Object System.Drawing.Size(400, 550)
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.FormBorderStyle = "FixedDialog"
$form.StartPosition = "CenterScreen"
$form.MaximizeBox = $false

# Заголовок
$label = New-Object System.Windows.Forms.Label
$label.Text = $txtTitle
$label.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$label.ForeColor = [System.Drawing.Color]::DeepSkyBlue
$label.Size = New-Object System.Drawing.Size(380, 50)
$label.TextAlign = "MiddleCenter"
$label.Location = New-Object System.Drawing.Point(0, 20)
$form.Controls.Add($label)

# Панель списка кнопок
$flowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowPanel.Location = New-Object System.Drawing.Point(25, 80)
$flowPanel.Size = New-Object System.Drawing.Size(340, 340)
$flowPanel.AutoScroll = $true
$form.Controls.Add($flowPanel)

# Функция запуска
$launchAction = {
    param($path)
    if ($proxy -and -not (Get-Process -Name "TgWsProxy_windows" -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath $proxy -WindowStyle Minimized
        Start-Sleep -Seconds 1
    }
    Start-Process -FilePath $path -ArgumentList "-many" -WorkingDirectory (Split-Path $path)
    $form.Close()
}

# Генерация кнопок сессий
foreach ($s in $sessions) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $s.Name
    $btn.Size = New-Object System.Drawing.Size(310, 45)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 1
    $btn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(70, 70, 70)
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    $path = $s.Path
    $btn.Add_Click({ &$launchAction $path })
    
    # Эффект наведения
    $btn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60); $this.FlatAppearance.BorderColor = [System.Drawing.Color]::DeepSkyBlue })
    $btn.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45); $this.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(70, 70, 70) })
    
    $flowPanel.Controls.Add($btn)
}

# Кнопка управления прокси
if ($proxy) {
    $btnP = New-Object System.Windows.Forms.Button
    $btnP.Text = $txtProxy
    $btnP.Size = New-Object System.Drawing.Size(340, 40)
    $btnP.Location = New-Object System.Drawing.Point(25, 440)
    $btnP.FlatStyle = "Flat"
    $btnP.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnP.ForeColor = [System.Drawing.Color]::Yellow
    $btnP.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 0)
    $btnP.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    $btnP.Add_Click({
        Stop-Process -Name "TgWsProxy_windows" -Force -ErrorAction SilentlyContinue
        Start-Process -FilePath $proxy -WindowStyle Minimized
    })
    $form.Controls.Add($btnP)
}

[void]$form.ShowDialog()

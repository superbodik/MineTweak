# tweak-menu.ps1

function Show-MainMenu {
    Clear-Host
    Write-Host "==== Главное меню ====" -ForegroundColor Cyan
    Write-Host "1. Твики системы"
    Write-Host "2. Выход"
    $choice = Read-Host "Выберите пункт"

    switch ($choice) {
        "1" { Show-TweaksMenu }
        "2" { Exit }
        default {
            Write-Host "Неверный ввод..." -ForegroundColor Red
            Start-Sleep -Seconds 1
            Show-MainMenu
        }
    }
}

function Show-TweaksMenu {
    Clear-Host
    Write-Host "==== Меню твиков ====" -ForegroundColor Yellow
    Write-Host "1. Программы"
    Write-Host "2. Патчи"
    Write-Host "3. Назад"
    $choice = Read-Host "Выберите пункт"

    switch ($choice) {
        "1" { Install-Programs }
        "2" { Show-PatchMenu }
        "3" { Show-MainMenu }
        default {
            Write-Host "Неверный ввод..." -ForegroundColor Red
            Start-Sleep -Seconds 1
            Show-TweaksMenu
        }
    }
}

function Show-PatchMenu {
    Clear-Host
    Write-Host "==== Меню патчей ====" -ForegroundColor Green
    Write-Host "1. Установить и настроить Spicetify"
    Write-Host "2. Активация Windows (MAS)"
    Write-Host "3. Назад"
    $choice = Read-Host "Выберите пункт"

    switch ($choice) {
        "1" { Install-Spicetify }
        "2" { Activate-Windows }
        "3" { Show-TweaksMenu }
        default {
            Write-Host "Неверный ввод..." -ForegroundColor Red
            Start-Sleep -Seconds 1
            Show-PatchMenu
        }
    }
}


function Install-Spicetify {
    Clear-Host
    Write-Host "🔧 Проверка Spicetify..." -ForegroundColor Cyan

    if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {
        Write-Host "📥 Spicetify не найден. Устанавливаю..." -ForegroundColor Yellow

        $installScript = "$env:TEMP\spicetify-install.ps1"
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/spicetify/spicetify-cli/main/install.ps1" -OutFile $installScript
        powershell -ExecutionPolicy Bypass -File $installScript
    } else {
        Write-Host "✅ Spicetify уже установлен." -ForegroundColor Green
    }

    try {
        spicetify backup apply
        Write-Host "🎵 Spicetify настроен." -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Ошибка при применении Spicetify. Проверь установку Spotify." -ForegroundColor Red
    }

    $autoupdatePath = "$env:APPDATA\SpicetifyUpdater.ps1"
    @"
# Скрипт автообновления Spicetify
if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {
    Write-Host 'Spicetify не установлен.'
    exit
}
spicetify upgrade
spicetify backup apply
"@ | Out-File -Encoding UTF8 $autoupdatePath

    $shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\SpicetifyUpdater.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$autoupdatePath`""
    $shortcut.Save()

    Write-Host "🚀 Автообновление добавлено в автозагрузку." -ForegroundColor Green
    Pause
    Show-PatchMenu
}

function Activate-Windows {
    Clear-Host
    Write-Host "🔑 Активация Windows с помощью MAS (Massgravel)" -ForegroundColor Cyan

    if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) {
        Write-Host "❌ PowerShell не в Full Language Mode. Исправить: https://gravesoft.dev/fix_powershell" -ForegroundColor Red
        return
    }

    function Check3rdAV {
        $avList = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object { $_.displayName -notlike '*windows*' } | Select-Object -ExpandProperty displayName
        if ($avList) {
            Write-Host "⚠️ Антивирус может мешать выполнению скрипта: $($avList -join ', ')" -ForegroundColor Yellow
        }
    }

    function CheckFile { 
        param ([string]$FilePath) 
        if (-not (Test-Path $FilePath)) { 
            Check3rdAV
            Write-Host "❌ Ошибка: файл MAS не создан." -ForegroundColor Red
            throw 
        } 
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $URLs = @(
        'https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/67abcd0c8925832fcf4365b9cf3706ab6fbf8571/MAS/All-In-One-Version-KL/MAS_AIO.cmd',
        'https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd&versionType=Commit&version=67abcd0c8925832fcf4365b9cf3706ab6fbf8571',
        'https://git.activated.win/massgrave/Microsoft-Activation-Scripts/raw/commit/67abcd0c8925832fcf4365b9cf3706ab6fbf8571/MAS/All-In-One-Version-KL/MAS_AIO.cmd'
    )

    foreach ($URL in $URLs | Sort-Object { Get-Random }) {
        try { $response = Invoke-WebRequest -Uri $URL -UseBasicParsing; break } catch {}
    }

    if (-not $response) {
        Check3rdAV
        Write-Host "❌ Не удалось загрузить MAS. Повторите позже." -ForegroundColor Red
        return
    }

    $expectedHash = 'EF2F705B9E8BE2816598E2E8B70BADB200733F2287B917D6C9666D95C63AFBF9'
    $stream = New-Object IO.MemoryStream
    $writer = New-Object IO.StreamWriter $stream
    $writer.Write($response)
    $writer.Flush()
    $stream.Position = 0
    $actualHash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($stream)) -replace '-'
    if ($actualHash -ne $expectedHash) {
        Write-Host "⚠️ Контрольная сумма не совпадает. Возможная подмена файла. Прерывание." -ForegroundColor Red
        return
    }

    $rand = [Guid]::NewGuid().Guid
    $isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
    $FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\MAS_$rand.cmd" } else { "$env:USERPROFILE\AppData\Local\Temp\MAS_$rand.cmd" }

    Set-Content -Path $FilePath -Value "@::: $rand `r`n$response"
    CheckFile $FilePath

    Start-Process "cmd.exe" -ArgumentList "/c `"$FilePath`"" -Wait
    Remove-Item $FilePath -Force

    Write-Host "✅ MAS завершил выполнение." -ForegroundColor Green
    Pause
    Show-PatchMenu
}


function Invoke-RemoteScript {
    param (
        [Parameter(Mandatory)]
        [string]$Url
    )

    try {
        $scriptContent = Invoke-RestMethod -Uri $Url
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "❌ Ошибка при загрузке скрипта: $Url" -ForegroundColor Red
        Pause
    }
}

function Install-Programs {
    Clear-Host
    Write-Host "📦 Загружаю меню установки программ..." -ForegroundColor Cyan

    $scriptUrl = "https://raw.githubusercontent.com/superbodik/MineTweak/main/install-apps.ps1"
    $tempScript = "$env:TEMP\install-apps.ps1"

    try {
        Invoke-WebRequest -Uri $scriptUrl -OutFile $tempScript
        . $tempScript  

        Show-AppsMenu  =
    } catch {
        Write-Host "❌ Ошибка при загрузке скрипта: $scriptUrl" -ForegroundColor Red
    }

    Show-MainMenu 
}




Show-MainMenu

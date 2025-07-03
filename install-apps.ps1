# install-apps.ps1

function Show-Menu {
    Clear-Host
    Write-Host "====== УСТАНОВКА ПОЛЕЗНЫХ ПРОГРАММ ======" -ForegroundColor Cyan
    Write-Host "1. Установить 7-Zip"
    Write-Host "2. Установить Notepad++"
    Write-Host "3. Установить Visual Studio Code"
    Write-Host "4. Установить Spotify"
    Write-Host "5. Установить Spicetify (если Spotify уже установлен)"
    Write-Host "6. Активация Windows (MAS)"
    Write-Host "7. Установить всё"
    Write-Host "0. Выход"
    Write-Host ""
}

function Download-And-Install($url, $installerPath) {
    Write-Host "Скачиваем: $url"
    Start-BitsTransfer -Source $url -Destination $installerPath
    Write-Host "Устанавливаем: $installerPath"
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
    Remove-Item $installerPath -Force
}

function Install-7Zip {
    if (Get-Command "7z" -ErrorAction SilentlyContinue) {
        Write-Host "7-Zip уже установлен."
        return
    }
    $url = "https://www.7-zip.org/a/7z2301-x64.exe"
    $path = "$env:TEMP\7z_setup.exe"
    Download-And-Install $url $path
}

function Install-NotepadPP {
    $url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/latest/download/npp.8.6.4.Installer.x64.exe"
    $path = "$env:TEMP\npp_setup.exe"
    Download-And-Install $url $path
}

function Install-VSCode {
    $url = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
    $path = "$env:TEMP\vscode_setup.exe"
    Download-And-Install $url $path
}

function Install-Spotify {
    $url = "https://download.scdn.co/SpotifySetup.exe"
    $path = "$env:TEMP\spotify_setup.exe"
    Download-And-Install $url $path
}

function Install-Spicetify {
    if (-not (Get-Command "spicetify" -ErrorAction SilentlyContinue)) {
        Invoke-WebRequest -Uri "https://github.com/spicetify/spicetify-cli/releases/latest/download/spicetify-cli-windows-x64.zip" -OutFile "$env:TEMP\spicetify.zip"
        Expand-Archive "$env:TEMP\spicetify.zip" -DestinationPath "$env:ProgramFiles\spicetify" -Force
        $spicePath = "$env:ProgramFiles\spicetify"
        $envPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
        if ($envPath -notlike "*$spicePath*") {
            [System.Environment]::SetEnvironmentVariable("PATH", "$envPath;$spicePath", "User")
        }
        Write-Host "Spicetify установлен."
    } else {
        Write-Host "Spicetify уже установлен."
    }
}

function Run-MAS {
    Write-Host "Запуск MAS-активации Windows..."
    irm https://get.activated.win | iex
}

function Install-All {
    Install-7Zip
    Install-NotepadPP
    Install-VSCode
    Install-Spotify
    Install-Spicetify
    Run-MAS
}

do {
    Show-Menu
    $choice = Read-Host "Выберите пункт меню (0-7)"
    switch ($choice) {
        '1' { Install-7Zip }
        '2' { Install-NotepadPP }
        '3' { Install-VSCode }
        '4' { Install-Spotify }
        '5' { Install-Spicetify }
        '6' { Run-MAS }
        '7' { Install-All }
        '0' { Show-MainMenu }
        default { Write-Host "Неверный выбор. Попробуйте ещё раз." -ForegroundColor Red }
    }
    Pause
} while ($true)

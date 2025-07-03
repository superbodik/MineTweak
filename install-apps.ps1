function Show-AppsMenu {
    while ($true) {
        Clear-Host
        Write-Host "====== УСТАНОВКА ПОЛЕЗНЫХ ПРОГРАММ ======" -ForegroundColor Cyan
        Write-Host "1. Установить 7-Zip"
        Write-Host "2. Установить FireFox"
        Write-Host "3. Установить Discord"
        Write-Host "4. Установить Steam"
        Write-Host "5. Установить Spotify"
        Write-Host "===== Программирование ====="
        Write-Host "6. Установить Visual Studio Code"
        Write-Host "7. Установить Unity Hub"
        Write-Host "8. Установить Git"
        Write-Host "9. Установить Spicetify (если Spotify уже установлен)"
        Write-Host "10. Активация Windows (MAS)"
        Write-Host "0. Назад"

        $choice = Read-Host "Выберите пункт меню (0-10)"
        switch ($choice) {
            '1' { Install-7Zip }
            '2' { Install-Firefox }
            '3' { Install-Discord }
            '4' { Install-Steam }
            '5' { Install-Spotify }
            '6' { Install-VSCode }
            '7' { Install-UnityHub }
            '8' { Install-Git }
            '9' { Install-Spicetify }
            '10' { Run-MAS }
            '0' { return }  # Возврат в главное меню
            default { Write-Host "Неверный выбор. Попробуйте ещё раз." -ForegroundColor Red }
        }
        Pause
    }
}
function Download-And-Install {
    param($url, $installerPath)

    Write-Host "Скачиваем: $url"
    # Можно добавить проверку, если нужен прогресс, или заменить Start-BitsTransfer на Invoke-WebRequest
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

function Install-Firefox {
    $url = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=ru"
    $path = "$env:TEMP\firefox_setup.exe"
    Download-And-Install $url $path
}

function Install-Discord {
    $url = "https://discord.com/api/download?platform=win"
    $path = "$env:TEMP\discord_setup.exe"
    Download-And-Install $url $path
}

function Install-Steam {
    $url = "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe"
    $path = "$env:TEMP\steam_setup.exe"
    Download-And-Install $url $path
}

function Install-Spotify {
    $url = "https://download.scdn.co/SpotifySetup.exe"
    $path = "$env:TEMP\spotify_setup.exe"
    Download-And-Install $url $path
}

function Install-VSCode {
    $url = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
    $path = "$env:TEMP\vscode_setup.exe"
    Download-And-Install $url $path
}

function Install-UnityHub {
    $url = "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.exe"
    $path = "$env:TEMP\unityhub_setup.exe"
    Download-And-Install $url $path
}

function Install-Git {
    $url = "https://github.com/git-for-windows/git/releases/latest/download/Git-2.42.0-64-bit.exe"
    $path = "$env:TEMP\git_setup.exe"
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
    Install-Firefox
    Install-Discord
    Install-Steam
    Install-Spotify
    Install-VSCode
    Install-UnityHub
    Install-Git
    Install-Spicetify
    Run-MAS
}

function Show-AppsMenu {
    while ($true) {
        Clear-Host
        Write-Host "====== УСТАНОВКА ПОЛЕЗНЫХ ПРОГРАММ ======" -ForegroundColor Cyan
        Write-Host "1. Установить 7-Zip"
        Write-Host "2. Установить FireFox"
        Write-Host "3. Установить Discord"
        Write-Host "4. Установить Steam"
        Write-Host "5. Установить Spotify"
        Write-Host "===== Программирование ====="
        Write-Host "6. Установить Visual Studio Code"
        Write-Host "7. Установить Unity Hub"
        Write-Host "8. Установить Git"
        Write-Host "9. Установить Spicetify (если Spotify уже установлен)"
        Write-Host "10. Активация Windows (MAS)"
        Write-Host "0. Назад"

        $choice = Read-Host "Выберите пункт меню (0-10)"
        switch ($choice) {
            '1' { Install-7Zip }
            '2' { Install-Firefox }
            '3' { Install-Discord }
            '4' { Install-Steam }
            '5' { Install-Spotify }
            '6' { Install-VSCode }
            '7' { Install-UnityHub }
            '8' { Install-Git }
            '9' { Install-Spicetify }
            '10' { Run-MAS }
            '0' { return }  # Выход из меню назад
            default { Write-Host "Неверный выбор. Попробуйте ещё раз." -ForegroundColor Red }
        }
        Pause
    }
}

Show-AppsMenu

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

# Пример функции установки FireFox
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
function Install-All {
    Install-Git
    Install-UnityHub
    Install-Steam
    Install-Discord
    Install-Firefox
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

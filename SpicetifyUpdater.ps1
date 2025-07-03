# SpicetifyUpdater.ps1

function Is-SpicetifyInstalled {
    try {
        $ver = spicetify --version 2>$null
        return $true
    } catch {
        return $false
    }
}

function Install-Spicetify {
    Write-Host "Spicetify не найден. Запускаю tweak-menu.ps1 для управления настройками..."
    
    $menuScript = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "tweak-menu.ps1"
    if (Test-Path $menuScript) {
        & powershell -ExecutionPolicy Bypass -File $menuScript
    } else {
        Write-Host "Файл tweak-menu.ps1 не найден: $menuScript"
    }
    exit 1
}

function Update-Spicetify {
    Write-Host "Обновляю Spicetify..."
    spicetify update
    Write-Host "Применяю настройки Spicetify..."
    spicetify apply
}

function Register-AutoUpdate {
    $taskName = "SpicetifyAutoUpdate"
    $scriptPath = $MyInvocation.MyCommand.Path

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -Daily -At 3am
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal

    Write-Host "Задача автозагрузки для обновления Spicetify создана."
}

if (-not (Is-SpicetifyInstalled)) {
    Install-Spicetify
}

Update-Spicetify
Register-AutoUpdate

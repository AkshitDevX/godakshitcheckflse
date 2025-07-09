# Credit: GOD AKSHIT | CODERS CORP /// discord.gg/hindustan

function Monitor-HDPlayer {
    Write-Host "`n🔍 Waiting for HD-Player process to start..." -ForegroundColor Yellow

    $initialProcs = Get-Process | Select-Object Name, Id
    $initialSvcs = Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name, DisplayName

    while (-not (Get-Process -Name "HD-Player" -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 1
    }

    $hdpProc = Get-Process -Name "HD-Player"
    $hdpPID = $hdpProc.Id
    $hdpSID = $hdpProc.SessionId
    Write-Host "`n✅ HD-Player detected (PID: $hdpPID). Monitoring..." -ForegroundColor Green

    $runtimeOverlay = @()
    do {
        $currentProcs = Get-Process
        $overlay = $currentProcs | Where-Object {
            $_.SessionId -eq $hdpSID -and $_.MainWindowTitle -eq "" -and $_.Id -ne $hdpPID
        } | Select-Object Name, Id
        $runtimeOverlay += $overlay

        Start-Sleep -Seconds 2
    } while (Get-Process -Id $hdpPID -ErrorAction SilentlyContinue)

    Write-Host "`n🛑 HD-Player exited. Analyzing activity..." -ForegroundColor Red

    $finalProcs = Get-Process | Select-Object Name, Id
    $finalSvcs = Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name, DisplayName

    $newProcs = $finalProcs | Where-Object { $_.Id -notin $initialProcs.Id }
    $endedProcs = $initialProcs | Where-Object { $_.Id -notin $finalProcs.Id }

    $newSvcs = $finalSvcs | Where-Object { $_.Name -notin $initialSvcs.Name }
    $endedSvcs = $initialSvcs | Where-Object { $_.Name -notin $finalSvcs.Name }

    Write-Host "`n🧠 === ACTIVITY REPORT ===" -ForegroundColor Cyan

    if ($newProcs) {
        Write-Host "`n🚀 New Processes Started During HD-Player:"
        $newProcs | ForEach-Object { Write-Host " [+] $($_.Name) (PID: $($_.Id))" }
    }

    if ($endedProcs) {
        Write-Host "`n❌ Processes Ended During HD-Player:"
        $endedProcs | ForEach-Object { Write-Host " [-] $($_.Name) (PID: $($_.Id))" }
    }

    if ($newSvcs) {
        Write-Host "`n🚀 New Services Started During HD-Player:"
        $newSvcs | ForEach-Object { Write-Host " [+] $($_.DisplayName) ($($_.Name))" }
    }

    if ($endedSvcs) {
        Write-Host "`n❌ Services Stopped During HD-Player:"
        $endedSvcs | ForEach-Object { Write-Host " [-] $($_.DisplayName) ($($_.Name))" }
    }

    if ($runtimeOverlay.Count -gt 0) {
        Write-Host "`n👁️ Suspected Background/Overlay Processes During HD-Player:"
        $runtimeOverlay | Sort-Object Id -Unique | ForEach-Object {
            Write-Host " [~] $($_.Name) (PID: $($_.Id))"
        }
    } else {
        Write-Host "`n✅ No overlay/background process detected." -ForegroundColor Gray
    }

    Write-Host "`n👑 Credit: GOD AKSHIT | CODERS CORP /// discord.gg/hindustan" -ForegroundColor Magenta
}

# Start Monitoring
Monitor-HDPlayer

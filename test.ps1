function Analyze-ScheduledTasks {
    Write-Host "Analyzing Scheduled Tasks..." -ForegroundColor Cyan

    $bypassPrograms = @(
        "cmd.exe", "powershell.exe", "powershell_ise.exe", "rundll32.exe", "regsvr32.exe",
        "taskmgr.exe", "LaunchTM.exe", "WinRAR.exe"
    )

    $tasks = Get-ScheduledTask | ForEach-Object {
        $task = $_
        $actions = $task.Actions | ForEach-Object {
            $suspect = if ($_.Execute -match ($bypassPrograms -join "|")) {
                "Yes"
            } else {
                "No"
            }

            [PSCustomObject]@{
                TaskName   = $task.TaskName
                TaskPath   = $task.TaskPath
                Action     = $_.Execute
                Arguments  = $_.Arguments
                Suspicion  = $suspect
            }
        }
        $actions
    }

    if ($tasks) {
        $tasks | Out-GridView -Title "Scheduler Catcher by NOLW" -PassThru
    } else {
        Write-Host "No tasks found." -ForegroundColor Yellow
    }
}

function Get-DeletedFilesHistory {
    param ([string]$Directory)

    Write-Host "Fetching history of deleted files in: $Directory and subdirectories" -ForegroundColor Green

    $drive = $Directory.Substring(0, 2)
    
    # Capturar a lista de arquivos antes da análise
    $existingFiles = Get-ChildItem -Path $Directory -Recurse -File | Select-Object -ExpandProperty FullName

    $journalInfo = fsutil usn queryjournal $drive 2>&1
    if ($journalInfo -match "error") {
        Write-Host "NTFS Journal is not enabled on this drive." -ForegroundColor Red
        return
    }

    $usnData = fsutil usn readjournal $drive M 2>&1
    if ($usnData -match "error") {
        Write-Host "Error reading NTFS Journal." -ForegroundColor Red
        return
    }

    $deletedFiles = $usnData | Select-String "FileName: " | ForEach-Object { $_ -match "FileName: (.+)"; $matches[1] }

    # Filtrar arquivos deletados dentro do diretório e subdiretórios
    $deletedFilesInDirectory = $deletedFiles | Where-Object { $_ -like "$Directory\*" -or $_ -eq "$Directory" }

    # Remover arquivos que ainda existem (garantindo que só os deletados apareçam)
    $deletedFilesFiltered = $deletedFilesInDirectory | Where-Object { -not ($existingFiles -contains $_) }

    if ($deletedFilesFiltered.Count -gt 0) {
        Write-Host "Deleted files found in $Directory and subdirectories:" -ForegroundColor Yellow
        $deletedFilesFiltered | Out-GridView -Title "Deleted Files in $Directory"
    } else {
        Write-Host "No recently deleted files found in the directory or subdirectories." -ForegroundColor Green
    }
}

Write-Host "Scheduler Parser by nolw" -ForegroundColor Magenta
Start-Sleep -Seconds 1

Analyze-ScheduledTasks
Get-DeletedFilesHistory -Directory "C:\Windows\System32\Tasks"

Write-Host "by nolws" -ForegroundColor Magenta
Read-Host "Press Enter to exit"

Start-Sleep -Seconds 1
Write-Host "Made by nolw (the dogshit sser)" -ForegroundColor Red
Write-Host "Analyzing scheduled tasks..." -ForegroundColor Red
Start-Sleep -Seconds 1


$tasks = Get-ScheduledTask | ForEach-Object {
    $task = $_
    $actions = $task.Actions | ForEach-Object {
        
        $bypassPrograms = @(
            "cmd.exe", "powershell.exe", "powershell_ise.exe", "rundll32.exe", "regsvr32.exe", 
            "taskmgr.exe", "LaunchTM.exe", "WinRAR.exe"
        )
        
        
        $suspect = if ($_.Execute -match ($bypassPrograms -join "|")) {
            "Yes"
        } else {
            "No"
        }
        
        [PSCustomObject]@{
            TaskName = $task.TaskName
            TaskPath = $task.TaskPath
            Action = $_.Execute
            Arguments = $_.Arguments
            Suspicion = $suspect
        }
    }
    $actions
}

if ($tasks) {
    $tasks | Out-GridView -Title "Scheduler Parser" -PassThru
} else {
    Write-Host "No tasks found"
}


Write-Host "PRESS ENTER TO QUIT" -ForegroundColor White

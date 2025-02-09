Start-Sleep -Seconds 1
Write-Host "Scheduler Parser by nolw"
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
    $tasks | Out-GridView -Title "Scheduler catcher by NOLW" -PassThru
} else {
    Write-Host "No tasks found"
}


Read-Host "Press enter to quit"

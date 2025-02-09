Start-Sleep -Seconds 1
Write-Host "Scheduler Parser by nolw"
Start-Sleep -Seconds 1

# Obtém todas as tarefas agendadas e classifica as suspeitas
$tasks = Get-ScheduledTask | ForEach-Object {
    $task = $_
    $actions = $task.Actions | ForEach-Object {
        # Lista de executáveis potencialmente usados para bypass de segurança
        $bypassPrograms = @(
            "cmd.exe", "powershell.exe", "powershell_ise.exe", "rundll32.exe", "regsvr32.exe", 
            "taskmgr.exe", "LaunchTM.exe", "WinRAR.exe"
        )
        
        # Verifica se a ação está na lista de programas suspeitos
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
            Suspeita = $suspect
        }
    }
    $actions
}

if ($tasks) {
    $tasks | Out-GridView -Title "Scheduler catcher by NOLW" -PassThru
} else {
    Write-Host "No tasks found"
}

# Mantém a janela aberta para evitar fechamento automático
Read-Host "Press enter to quit"

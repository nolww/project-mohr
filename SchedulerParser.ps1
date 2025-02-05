Start-Sleep -Seconds 1
Write-Host "Executando Script para listar todas as tarefas agendadas"
Start-Sleep -Seconds 1

# Obtém todas as tarefas agendadas e classifica as suspeitas
$tasks = Get-ScheduledTask | ForEach-Object {
    $task = $_
    $actions = $task.Actions | ForEach-Object {
        # Lista de executáveis potencialmente usados para bypass de segurança
        $bypassPrograms = @(
            "cmd.exe", "powershell.exe", "wscript.exe", "cscript.exe", "bitsadmin.exe", "mshta.exe", "taskmgr.exe", 
            "regsvr32.exe", "rundll32.exe", "certutil.exe", "installutil.exe", "msbuild.exe", "schtasks.exe", "wmic.exe", 
            "psexec.exe", "wscript.exe", "cscript.exe", "bginfo.exe", "cmstp.exe", "msiexec.exe", "dxcap.exe", "esentutl.exe", 
            "forfiles.exe", "mavinject.exe", "odbcconf.exe", "syncappvpublishingserver.exe", "verclsid.exe", "xwizard.exe"
        )
        
        # Verifica se a ação está na lista de programas suspeitos ou não está em C:\Windows
        $suspect = if ($_.Execute -match ($bypassPrograms -join "|") -or ($_.Execute -and -not ($_.Execute -match "C:\\Windows\\"))) {
            "Sim"
        } else {
            "Não"
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
    $tasks | Out-GridView -Title "Todas as Tarefas Agendadas" -PassThru
} else {
    Write-Host "Nenhuma tarefa agendada encontrada."
}

# Mantém a janela aberta para evitar fechamento automático
Read-Host "Pressione Enter para sair"

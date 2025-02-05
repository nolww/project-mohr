$UserRN = $env:USERNAME
Start-Sleep -Seconds 1
Write-Host "Executando Script para o usuário: $UserRN"
Start-Sleep -Seconds 1

# Obtém as tarefas agendadas do usuário e exibe no Out-GridView
$tasks = Get-ScheduledTask |
    Where-Object { $_.Author -match $UserRN } |
    Select-Object TaskName, TaskPath, 
                  @{Name='Action';Expression={($_.Actions | ForEach-Object { $_.Execute })}}, 
                  @{Name='Arguments';Expression={($_.Actions | ForEach-Object { if ($_.Arguments) { $_.Arguments } else { 'Nenhum argumento' } })}}

if ($tasks) {
    $tasks | Out-GridView -Title "Author Parser by Nolw"
} else {
    Write-Host "Nenhuma tarefa agendada encontrada para o usuário: $UserRN"
}

# Mantém a janela aberta para evitar fechamento automático
Read-Host "Pressione Enter para sair"

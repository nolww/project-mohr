$UserRN = $env:USERNAME
Start-Sleep -Seconds 1
Write-Host "Executando Script para o usuário: $UserRN"
Start-Sleep -Seconds 1


$tasks = Get-ScheduledTask |
    Where-Object { $_.Author -match $UserRN } |
    Select-Object TaskName, TaskPath, 
                  @{Name='Action';Expression={($_.Actions | ForEach-Object { $_.Execute })}}, 
                  @{Name='Arguments';Expression={($_.Actions | ForEach-Object { if ($_.Arguments) { $_.Arguments } else { 'Nenhum argumento' } })}}

if ($tasks) {
    $tasks | Out-GridView -Title "Manual tasks by nolw"
} else {
    Write-Host "Nenhuma tarefa agendada encontrada para o usuário: $UserRN"
}


Read-Host "Pressione Enter para sair"

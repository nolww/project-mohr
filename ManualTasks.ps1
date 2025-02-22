$UserRN = $env:USERNAME
Start-Sleep -Seconds 1
Write-Host "Checking tasks created by $UserRN" -foregroundcolor red
Write-Host "made by nolws (dogshit sser)" -foregroundcolor red
Start-Sleep -Seconds 1


$tasks = Get-ScheduledTask |
    Where-Object { $_.Author -match $UserRN } |
    Select-Object TaskName, TaskPath, 
                  @{Name='Action';Expression={($_.Actions | ForEach-Object { $_.Execute })}}, 
                  @{Name='Arguments';Expression={($_.Actions | ForEach-Object { if ($_.Arguments) { $_.Arguments } else { 'Nenhum argumento' } })}}

if ($tasks) {
    $tasks | Out-GridView -Title "Manual tasks by nolw"
} else {
    Write-Host "No manually created tasks found"
}


Read-Host "Press enter"

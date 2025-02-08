Add-Type -AssemblyName System.Windows.Forms

$servicos = Get-WmiObject Win32_Service | Select-Object `
    DisplayName, Name, StartMode, State, StartName, PathName

$servicosWindowsComuns = @(
    "C:\Windows\System32\svchost.exe",
    "C:\Windows\System32\lsass.exe",
    "C:\Windows\System32\wininit.exe",
    "C:\Windows\System32\winlogon.exe",
    "C:\Windows\System32\services.exe",
    "C:\WINDOWS\system32\wbem\WmiApSrv.exe",
    "C:\WINDOWS\system32\locator.exe",
    "C:\WINDOWS\System32\DriverStore\FileRepository\u0376118.inf_amd64_d3964dd16c191eeb\B371320\atiesrxx.exe",
    "C:\WINDOWS\system32\dllhost.exe",
    "C:\WINDOWS\system32\msdtc.exe",
    "C:\WINDOWS\system32\vssvc.exe",
    "C:\WINDOWS\system32\CredentialEnrollmentManager.exe",
    "C:\WINDOWS\system32\vds.exe",
    "C:\WINDOWS\system32\fxssvc.exe",
    "C:\WINDOWS\system32\GameInputSvc.exe",
    "C:\WINDOWS\system32\TieringEngineService.exe",
    "C:\WINDOWS\SysWow64\perfhost.exe",
    "C:\WINDOWS\servicing\TrustedInstaller.exe",
    "C:\WINDOWS\system32\snmptrap.exe",
    "C:\WINDOWS\system32\AppVClient.exe",
    "C:\WINDOWS\System32\DriverStore\FileRepository\nv_disp.inf_amd64_1e8724cced6e93d4\Display.NvContainer\...",
    "C:\WINDOWS\System32\OpenSSH\ssh-agent.exe",
    "C:\WINDOWS\system32\sppsvc.exe",
    "C:\WINDOWS\system32\DiagSvcs\DiagnosticsHub.StandardCollector.Service.exe",
    "C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\SMsvcHost.exe",
    "C:\WINDOWS\system32\SensorDataService.exe",
    "C:\WINDOWS\system32\wbengine.exe",
    "C:\WINDOWS\system32\spectrum.exe",
    "C:\WINDOWS\system32\SecurityHealthService.exe",
    "C:\WINDOWS\system32\PerceptionSimulation\PerceptionSimulationService.exe",
    "C:\WINDOWS\system32\AgentService.exe",
    "C:\WINDOWS\system32\alg.exe",
    "C:\WINDOWS\system32\spoolsv.exe",
    "C:\WINDOWS\system32\SgrmBroker.exe",
    "C:\WINDOWS\system32\msiexec.exe",
    "C:\WINDOWS\system32\SearchIndexer.exe"
)

function Determina-OrigemServico {
    param ($Caminho)

    if (-not $Caminho -or $Caminho -eq "") { return "Unknown" }

    $caminhoLower = $Caminho.ToLower()

    if ($caminhoLower -match "c:\\windows\\system32\\svchost.exe" -or 
        $servicosWindowsComuns -contains $Caminho) {
        return "Windows"
    } elseif ($caminhoLower -match "c:\\program files" -or 
              $caminhoLower -match "c:\\program files \\(x86\)") {
        return "Third"
    } else {
        return "Unknown"
    }
}

Write-Host "Processando serviços do sistema..."

$servicosFormatados = @()

foreach ($servico in $servicos) {
    $origem = Determina-OrigemServico -Caminho $servico.PathName

    $servico | Add-Member -MemberType NoteProperty -Name "Origem" -Value $origem -PassThru
    $servicosFormatados += $servico
}

if ($servicosFormatados.Count -eq 0) {
    Write-Host "Nenhum serviço encontrado." -ForegroundColor Yellow
    pause
    exit
}

Write-Host "Exibindo lista de serviços..."

$servicosFormatados | Select-Object DisplayName, Name, State, StartMode, Origem, StartName, PathName | `
    Out-GridView -Title "SvcParser"

Write-Host "NOLW$" -ForegroundColor Green
pause

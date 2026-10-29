# Instala o MazyOS Scraper no Windows e abre no navegador.
# Uso: powershell -ExecutionPolicy Bypass -File instalar.ps1 [-NaoAbrir]
param([switch]$NaoAbrir)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Set-Location $PSScriptRoot

$exe = Join-Path $PSScriptRoot 'mazyos-scraper.exe'

function Baixar-Release {
    try {
        $rel = Invoke-RestMethod 'https://api.github.com/repos/mazzeoia/mazyos-scraper/releases/latest'
    } catch {
        return $false
    }
    $asset = $rel.assets | Where-Object { $_.name -like '*windows*.zip' } | Select-Object -First 1
    if (-not $asset) { return $false }

    Write-Host "Baixando $($asset.name) ($($rel.tag_name))..."
    $tmp = Join-Path $env:TEMP ('mazyos-scraper-' + [guid]::NewGuid())
    New-Item -ItemType Directory -Force $tmp | Out-Null
    $zip = Join-Path $tmp 'release.zip'
    Invoke-WebRequest $asset.browser_download_url -OutFile $zip
    Expand-Archive $zip -DestinationPath $tmp -Force
    $novo = Get-ChildItem $tmp -Recurse -Filter 'mazyos-scraper.exe' | Select-Object -First 1
    if (-not $novo) { return $false }
    Copy-Item $novo.FullName $exe -Force
    Remove-Item $tmp -Recurse -Force
    return $true
}

function Achar-Go {
    $cmd = Get-Command go -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $local = Join-Path $env:LOCALAPPDATA 'Programs\go\bin\go.exe'
    if (Test-Path $local) { return $local }

    $versao = (Select-String -Path go.mod -Pattern '^go (\S+)').Matches[0].Groups[1].Value
    $arq = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'amd64' }
    Write-Host "Instalando Go $versao (só pra compilar, na pasta do usuário)..."
    $zip = Join-Path $env:TEMP "go$versao.zip"
    Invoke-WebRequest "https://go.dev/dl/go$versao.windows-$arq.zip" -OutFile $zip
    $destino = Join-Path $env:LOCALAPPDATA 'Programs'
    New-Item -ItemType Directory -Force $destino | Out-Null
    Expand-Archive $zip -DestinationPath $destino -Force
    Remove-Item $zip -Force
    return $local
}

if (Test-Path $exe) {
    Write-Host 'mazyos-scraper.exe já existe, pulando a instalação.'
} elseif (-not (Baixar-Release)) {
    Write-Host 'Sem executável pronto no Release. Compilando a partir do código...'
    $go = Achar-Go
    & $go build -ldflags '-s -w' -o $exe .
    if ($LASTEXITCODE -ne 0) { throw 'A compilação falhou.' }
}

Write-Host ''
Write-Host 'MazyOS Scraper instalado.'
Write-Host 'Pra abrir depois: dois cliques em "Abrir MazyOS Scraper.cmd".'

if (-not $NaoAbrir) {
    Start-Process -FilePath (Join-Path $PSScriptRoot 'Abrir MazyOS Scraper.cmd') -WorkingDirectory $PSScriptRoot
    Write-Host 'Abrindo em http://localhost:8080 (a primeira busca baixa um navegador, uns 150 MB).'
}

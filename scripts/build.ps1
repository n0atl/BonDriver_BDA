param(
    [ValidateSet('Win32', 'x64')]
    [string]$Platform = 'x64',
    [ValidateSet('Release', 'Release_Static')]
    [string]$Configuration = 'Release'
)
$ErrorActionPreference = 'Stop'
$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
$msbuild = & $vswhere -latest -version '[17.0,18.0)' -products '*' -requires Microsoft.Component.MSBuild -find 'MSBuild\**\Bin\MSBuild.exe' | Select-Object -First 1
if (-not $msbuild) { throw 'Visual Studio 2022 MSBuild was not found.' }
$required = @(
    'common/common.h',
    '3rdParties/muparser/src/muParser.cpp',
    '3rdParties/Windows-classic-samples/Samples/Win7Samples/multimedia/directshow/baseclasses/arithutil.cpp'
)
foreach ($file in $required) {
    if (-not (Test-Path (Join-Path $sourceRoot $file))) {
        throw "Missing dependency: $file. Run git submodule update --init --recursive."
    }
}
# Build projects directly: the upstream solution also lists unavailable plugins.
# Use the VS 2022 compiler consistently for all three projects.
$properties = @(
    "/p:Configuration=$Configuration",
    "/p:Platform=$Platform",
    '/p:PlatformToolset=v143',
    ('/p:SolutionDir=' + $sourceRoot.Replace('\', '/') + '/')
)
foreach ($project in @(
    'projects/BaseClasses/BaseClasses.vcxproj',
    'projects/muparser/muparser.vcxproj',
    'BonDriver_BDA/BonDriver.vcxproj'
)) {
    & $msbuild (Join-Path $sourceRoot $project) /m /t:Build /nologo @properties
    if ($LASTEXITCODE -ne 0) { throw "Build failed: $project (exit $LASTEXITCODE)" }
}
$dll = Join-Path $sourceRoot "$Platform/$Configuration/BonDriver_BDA.dll"
if (-not (Test-Path $dll)) { throw "DLL was not generated: $dll" }
Write-Host "Built: $dll"

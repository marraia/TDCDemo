Param(
    [string]$sourcesDirectory, #the root of your project
    [string]$testAssembly, #the file pattern describing test assemblies to look for
    [string]$testFiltercriteria="", #test filter criteria (as in Run Visual Studio Tests task)
    [string]$openCoverFilters="" #OpenCover-specific filters
)
Add-Type -Path "$PSScriptRoot\vsts-task-lib\VsTsTaskSdk.dll"

. $PSScriptRoot\vsts-task-lib\LongPathFunctions.ps1
. $PSScriptRoot\vsts-task-lib\TraceFunctions.ps1
. $PSScriptRoot\vsts-task-lib\LegacyFindFunctions.ps1
. $PSScriptRoot\vsts-task-lib\FindFunctions.ps1

# resolve test assembly files (copied from VSTest.ps1)
$testAssemblyFiles = @()
# check for solution pattern
if ($testAssembly.Contains("*") -Or $testAssembly.Contains("?"))
{
    Write-Host "Pattern found in solution parameter. Calling Find-Files."
    Write-Host "Calling Find-Files with pattern: $testAssembly"    
    #$testAssemblyFiles = Find-Files -LegacyPattern $testAssembly -LiteralDirectory 'D:\Workspace\GIT\Efinance-Api\src\Tests'
	$testAssemblyFiles = Find-Files -LegacyPattern $testAssembly -LiteralDirectory $sourcesDirectory 
    Write-Host "Found files: $testAssemblyFiles"
}
else
{
    Write-Host "No Pattern found in solution parameter."
    $testAssembly = $testAssembly.Replace(';;', "`0") # Borrowed from Legacy File Handler
    foreach ($assembly in $testAssembly.Split(";"))
    {
        $testAssemblyFiles += ,($assembly.Replace("`0",";"))
    }
}

# build test assebly files string for vstest
$testFilesString = ""
foreach ($file in $testAssemblyFiles) {
    $testFilesString = $testFilesString + " ""$file"""
}

Write-Host $MyInvocation.MyCommand ": Removing old testresults"
Remove-Item -Path $PSScriptRoot\TestResults -Recurse -Force -ErrorAction SilentlyContinue 

$nugetOpenCoverPackage = Join-Path -Path $env:USERPROFILE -ChildPath "\.nuget\packages\OpenCover"
$latestOpenCover = Join-Path -Path ((Get-ChildItem -Path $nugetOpenCoverPackage | Sort-Object Fullname -Descending)[0].FullName) -ChildPath "tools\OpenCover.Console.exe"

$nugetReportGeneratorPackage = Join-Path -Path $env:USERPROFILE -ChildPath "\.nuget\packages\\reportgenerator"
$lastestReportGenerator = Join-Path -Path ((Get-ChildItem -Path $nugetReportGeneratorPackage | Sort-Object Fullname -Descending)[0].FullName) -ChildPath "tools\ReportGenerator.exe"


Write-Host $MyInvocation.MyCommand ": Running OpenCover using vstest.console.exe"
Start-Process $latestOpenCover -wait -NoNewWindow -ArgumentList "-register:user -filter:""$openCoverFilters"" -target:""C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\Extensions\TestPlatform\vstest.console.exe"" -targetargs:""$testFilesString /logger:trx;LogFileName=Resultado.trx"" -output:OpenCover.xml -mergebyhash -oldstyle""" -WorkingDirectory $PSScriptRoot

Write-Host $MyInvocation.MyCommand ": Generating HTML report"
Start-Process $lastestReportGenerator -Wait -NoNewWindow -ArgumentList "-reports:""$PSScriptRoot\OpenCover.xml"" -targetdir:""$PSScriptRoot\CoverageReport"" -reporttypes:Xml;Html"


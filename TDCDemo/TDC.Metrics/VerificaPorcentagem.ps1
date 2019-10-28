Param(
    [string]$XmlResultado
)

Write-Host "Verificando porcentagem de cobertura de código" -ForegroundColor Green
$xmlExecucaoCoverage = [xml](get-content $XmlResultado)
$variavel=$xmlExecucaoCoverage.CoverageReport.Summary.Linecoverage
$porcentagem = $variavel -replace '%'

If ([double]::Parse($porcentagem) -ge 95.0)
{
    Write-Host "Parabéns, a cobertura de testes atingiu"$variavel "de cobertura de código!" -ForegroundColor Green
}
else
{
    Write-Host "##vso[task.logissue type=error;] Os testes não atingiram mais de 95% de cobertura de código! Está em: "$variavel
	exit 1
}
Param(
    [string]$XmlResultado
)

Write-Host "Verificando porcentagem de cobertura de c�digo" -ForegroundColor Green
$xmlExecucaoCoverage = [xml](get-content $XmlResultado)
$variavel=$xmlExecucaoCoverage.CoverageReport.Summary.Linecoverage
$porcentagem = $variavel -replace '%'

If ([double]::Parse($porcentagem) -ge 95.0)
{
    Write-Host "Parab�ns, a cobertura de testes atingiu"$variavel "de cobertura de c�digo!" -ForegroundColor Green
}
else
{
    Write-Host "##vso[task.logissue type=error;] Os testes n�o atingiram mais de 95% de cobertura de c�digo! Est� em: "$variavel
	exit 1
}
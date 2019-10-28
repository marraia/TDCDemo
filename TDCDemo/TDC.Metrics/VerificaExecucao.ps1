Param(
    [string]$XmlResultado
)

Write-Host "Verificando execu��o dos testes" -ForegroundColor Green
$xmlExecucaoTeste = [xml](get-content $XmlResultado)
$condicao = $xmlExecucaoTeste.TestRun.ResultSummary

If ($condicao.outcome -eq "Failed")
{
    Write-Host "##vso[task.logissue type=error;] Existem testes executados com erro"
	exit 1
}
else
{
    Write-Host "Parab�ns, todos os testes foram executados com sucesso!" -ForegroundColor Green
}
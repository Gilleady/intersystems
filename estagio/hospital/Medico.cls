Class estagio.hospital.Medico Extends (%Persistent, estagio.hospital.Pessoa, estagio.hospital.Interface)
{

Index CredencialIndex On Credencial [ Unique ];

Property Credencial As %Integer [ Required, SqlColumnNumber = 2 ];

ClassMethod ListarMedicos()
{
	Do ..Header("Lista de Médicos")
	
	Set tSql = "SELECT ID, Nome, Cpf, Credencial, Telefone, Nascimento FROM estagio_hospital.Medico"
	Set tStatement = ##class(%SQL.Statement).%New()
	
	Set tStatus = tStatement.%Prepare(.tSql)
	If (tStatus'=1)
	{
		Do $SYSTEM.Status.DisplayError(tStatus)
		Quit
	}
	Set tResultSet = tStatement.%Execute()
	//Do tResultSet.%Display()
	
	Write !,"#|_ID_|______Nome______|__CPF_Medico_|__Telefone__|__Credencial__|_Nascimento_|#"
	While (tResultSet.%Next())
	{
		Hang .03
		Write !,"#|",?2,tResultSet.%Get("ID"),?6,"|",
		?7,$EXTRACT(tResultSet.%Get("Nome"),1,17),?23,"|",
		?25,tResultSet.%Get("Cpf"),?37,"|",
		?39,tResultSet.%Get("Telefone"),?50,"|",
		?52,tResultSet.%Get("Credencial"),?65,"|",
		?67,$ZDATE(tResultSet.%Get("Nascimento"),4),?78,"|#"
	}
	
	Set tNavegacao = ..Navegacao(2)
	Quit:((tNavegacao'=0) && (tNavegacao'=1))
	Do $CASE(tNavegacao, 0:..Inicio(), 1:..Editar())
}

ClassMethod CadastrarMedico(pCpf As %Integer = "") As %Status
{
	//NÃO COMPLETO
	Write !,"Obs.: (*) campos obrigatórios"
	If (pCpf="")
	{
		Read !,"*Insira o CPF: ", pCpf
	}
	Read !,"*Insira o nome: ", tNome
	Read !,"*Insira a data de nascimento: ", tNascimento
	Read !,"Insira o telefone: ", tTelefone
	Read !,"Insira a rua: ", tRua
	Read !,"Insira a cidade: ", tCidade
	Read !,"Insira o estado: ", tEstado
	Read !,"Insira o credencial: ", tCredencial
	
	Set tMedico = ..%New()
	
	Set tMedico.Cpf = pCpf
	Set tMedico.Nome = tNome
	Set tMedico.Nascimento = $ZDATEH(tNascimento,4)
	Set tMedico.Telefone = tTelefone
	Set tMedico.Endereco = tMedico.Endereco.SetarEndereco(tRua, tCidade, tEstado)
	Set tMedico.Credencial = tCredencial
	Set tSc = tMedico.%Save()
	
	Quit tSc
}

ClassMethod Editar()
{
}

Storage Default
{
<Data name="MedicoDefaultData">
<Subscript>"Medico"</Subscript>
<Value name="1">
<Value>Credencial</Value>
</Value>
<Value name="2">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<Data name="PessoaState">
<Value name="1">
<Value>Nome</Value>
</Value>
<Value name="2">
<Value>Cpf</Value>
</Value>
<Value name="3">
<Value>Nascimento</Value>
</Value>
<Value name="4">
<Value>Endereco</Value>
</Value>
<Value name="5">
<Value>Telefone</Value>
</Value>
<Value name="6">
<Value>Credencial</Value>
</Value>
</Data>
<DataLocation>^estagio.hospital.MedicoD</DataLocation>
<DefaultData>MedicoDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^estagio.hospital.MedicoD</IdLocation>
<IndexLocation>^estagio.hospital.MedicoI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>27</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Cpf">
<AverageFieldSize>7</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Credencial">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Endereco">
<AverageFieldSize>2,Cidade:2,Estado:2,Rua:2</AverageFieldSize>
<Selectivity>100.0000%,Cidade:100.0000%,Estado:100.0000%,Rua:100.0000%</Selectivity>
</Property>
<Property name="Idade">
<AverageFieldSize>1</AverageFieldSize>
</Property>
<Property name="Nascimento">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Nome">
<AverageFieldSize>13</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Telefone">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<StreamLocation>^estagio.hospital.MedicoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

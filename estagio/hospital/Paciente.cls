Class estagio.hospital.Paciente Extends (%Persistent, estagio.hospital.Pessoa, estagio.hospital.Interface)
{

Property Convenio As %String [ SqlColumnNumber = 6 ];

ClassMethod ListarPacientes()
{
	Do ..Header("Lista de Pacientes")
	
	Set tSql = "SELECT ID, Nome, Cpf, Telefone, Convenio, Nascimento FROM estagio_hospital.Paciente"
	Set tStatement = ##class(%SQL.Statement).%New()
	
	Set tStatus = tStatement.%Prepare(.tSql)
	If (tStatus'=1)
	{
		Do $SYSTEM.Status.DisplayError(tStatus)
		Quit
	}
	Set tResultSet = tStatement.%Execute()
	//Do tResultSet.%Display()
	
	Write !,"#|_ID_|_____Nome______|_CPF_Paciente|___Telefone__|___Convenio___|_Nascimento_|#"
	While (tResultSet.%Next())
	{
		Hang .03
		Write !,"#|",?2,tResultSet.%Get("ID"),?6,"|",
		?7,$EXTRACT(tResultSet.%Get("Nome"),1,15),?22,"|",
		?24,tResultSet.%Get("Cpf"),?36,"|",
		?38,tResultSet.%Get("Telefone"),?50,"|",
		?51,tResultSet.%Get("Convenio"),?65,"|",
		?67,$ZDATE(tResultSet.%Get("Nascimento"),4),?78,"|#"
	}
	
	Set tNavegacao = ..Navegacao(2)
	Quit:((tNavegacao'=0) && (tNavegacao'=1))
	Do $CASE(tNavegacao, 0:..Inicio(), 1:..Editar())
}

ClassMethod CadastrarPaciente(pCpf As %Integer = "", ByRef pPaciente As estagio.hospital.Paciente) As %Status
{
	Do ..Header("Cadastrar Paciente")
	Write !,"# Obs.: (*) campos obrigatórios", ?79,"#"
	If (pCpf="")
	{
		Read !,"# *Insira o CPF: ", tCpf, ?79,"#"
	}
	Else
	{
		Set tCpf = pCpf
		Write !,"# *Insira o CPF: ", tCpf, ?79,"#"
	}
	Read !,"# *Insira o nome: ", tNome, ?79,"#"
	Read !,"# *Insira a data de nascimento: ", tNascimento, ?79,"#"
	Read !,"# Insira o telefone: ", tTelefone, ?79,"#"
	Read !,"# Insira a rua: ", tRua, ?79,"#"
	Read !,"# Insira a cidade: ", tCidade, ?79,"#"
	Read !,"# Insira o estado: ", tEstado, ?79,"#"
	Read !,"# Insira o convênio: ", tConvenio, ?79,"#"
	
	Set tPaciente = ..%New()
	
	Set tPaciente.Cpf = tCpf
	Set tPaciente.Nome = tNome
	Set tPaciente.Nascimento = $ZDATEH(tNascimento,4)
	Set tPaciente.Telefone = tTelefone
	Set tPaciente.Endereco = tPaciente.Endereco.SetarEndereco(tRua, tCidade, tEstado)
	Set tPaciente.Convenio = tConvenio
	Set tSc = tPaciente.%Save()
	Set pPaciente = tPaciente
	
	
	If (pCpf="")
	{
		If (tSc = 1)
		{
			Write !,"#",?79,"#",!,"# Cadastro feito com sucesso.", ?79,"#"
		}
		Else
		{
			Do $SYSTEM.Status.DisplayError(tSc)
			Quit
		}
			
		Set tNavegacao = ..Navegacao(1)
		Quit:((tNavegacao'=0) && (tNavegacao'=1))
		Do $CASE(tNavegacao, 0:..Inicio(), 1:..CadastrarPaciente())
	}
	Else
	{
		Quit tSc
	}
}

ClassMethod Editar()
{
	Do ..Header("Editar dados do Paciente")
	Read !,"# Insira o CPF do paciente que deseja editar: ", tCpfPaciente,?79,"#"
	
	&sql(SELECT %ID INTO :tIdPaciente FROM estagio_hospital.Paciente WHERE Cpf = :tCpfPaciente)
	
	Quit:(SQLCODE<0)
	
	If (SQLCODE=0)
	{
		Set tPaciente = ..%OpenId(tIdPaciente)
	
		Write !,"# Nome.............: "_ tPaciente.Nome, ?79, "#"
		Write !,"# CPF..............: "_ tPaciente.Cpf, ?79, "#"
		Write !,"# Data Nascimento..: "_ $ZDATE(tPaciente.Nascimento,4), " - Idade: "_tPaciente.Idade ,?79, "#"
		Write !,"# Telefone.........: "_ tPaciente.Telefone, ?79, "#"
		Write !,"# Rua..............: "_ tPaciente.Endereco.Rua, ?79, "#"
		Write !,"# Cidade...........: "_ tPaciente.Endereco.Cidade, ?79, "#"
		Write !,"# UF...............: "_ tPaciente.Endereco.Estado, ?79, "#"
		Write !,"# Convênio.........: "_ tPaciente.Convenio, ?79, "#"
	}
	Elseif (SQLCODE=100)
	{
		Write !,"# ***Nenhum paciente encontrado***", ?79,"#"
	}
	
	Set tNavegacao = ..Navegacao(2)
	Quit:((tNavegacao'=0) && (tNavegacao'=1))
	Do $CASE(tNavegacao, 0:..Inicio(), 1:..Editar())
}

Storage Default
{
<Data name="PacienteDefaultData">
<Subscript>"Paciente"</Subscript>
<Value name="1">
<Value>Convenio</Value>
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
<Value>Convenio</Value>
</Value>
</Data>
<DataLocation>^estagio.hospital.PacienteD</DataLocation>
<DefaultData>PacienteDefaultData</DefaultData>
<ExtentSize>0</ExtentSize>
<IdLocation>^estagio.hospital.PacienteD</IdLocation>
<IndexLocation>^estagio.hospital.PacienteI</IndexLocation>
<StreamLocation>^estagio.hospital.PacienteS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

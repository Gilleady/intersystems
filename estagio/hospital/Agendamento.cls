Class estagio.hospital.Agendamento Extends (%Persistent, estagio.hospital.Interface)
{

Parameter CaminhoRelatorio = "C:\InterSystems\IRIS\mgr\user\hospital\relatorios\";

Property Paciente As estagio.hospital.Paciente [ Required ];

Property Medico As estagio.hospital.Medico [ Required ];

Property DataConsulta As %Date(FORMAT = 4) [ Required ];

Method %OnNew() As %Status
{
	Do ..RealizarAgendamento()
	
	Quit $$$OK
}

Method RealizarAgendamento()
{
	Do ..Header("Realizar novo agendamento")
	
	Read !,"# Insira o CPF do paciente: ", tCpfPaciente, ?79,"#"
	
	Set tId = ..Buscar(tCpfPaciente, "P")
	Quit:(tId=-1)
	
	If (tId>0)
	{
		Set ..Paciente = ##class(estagio.hospital.Paciente).%OpenId(tId)
	}
	Elseif (tId=0)
	{
		Write !,"# ***Nenhum paciente encontrado***", ?79,"#"
		Write !,"# Deseja cadastrar um paciente com o CPF "_tCpfPaciente_" ? (S/N): "
		Read tEscolha#1, ?79,"#"
		Do:((tEscolha'="S") && (tEscolha'="s")) ..Footer()
		Quit:((tEscolha'="S") && (tEscolha'="s"))

		Set tSc = ##class(estagio.hospital.Paciente).CadastrarPaciente(tCpfPaciente, .tPaciente)
		
		If (tSc = 1)
		{
			Do ..Header("Realizar novo agendamento")
			Set ..Paciente = tPaciente
			Write !,"# Insira o CPF do paciente: ", tCpfPaciente, ?79,"#"
			Write !,"# Cadastro feito com sucesso. Prossiga com o Agendamento", ?79,"#",!,"#",?79,"#"
		}
		Else
		{
			Do $SYSTEM.Status.DisplayError(tSc)
			Quit
		}
	}
	/*
	Else
	{
		
	}
	*/
	For i=1:1:3
	{
		Read !,"# Insira o CPF do médico: ", tCpf, ?79,"#"
		Set tId = ..Buscar(tCpf, "M")
		Quit:(tId=-1)
		
		If (tId>0)
		{
			Set ..Medico = ##class(estagio.hospital.Medico).%OpenId(tId)
			Quit
		}
		Elseif (tId=0)
		{
			Write !,"# ***Nenhum médico encontrado***", ?79,"#"
			Write !,"# Tente novamente", ?79,"#"
		}
		/*
		Else
		{
			
		}
		*/
	}
	
	If (($ISOBJECT(..Medico)) && ($ISOBJECT(..Paciente)))
	{
		Read !,"# Insira a data da consulta: ", tDataConsulta, ?79,"#"
		Set ..DataConsulta = $ZDATEH(tDataConsulta,4)
		
		Set tSc = ..%Save()
		If (tSc = 1)
		{
			Write !,"# Agendamento realizado com sucesso!", ?79,"#"
		}
		Else
		{
			Do $SYSTEM.Status.DisplayError(tSc)
			Quit
		}
	}
	
	Set tNavegacao = ..Navegacao(1)
	Quit:((tNavegacao'=0) && (tNavegacao'=1))
	Do $CASE(tNavegacao, 0:..Inicio(), 1:..RealizarAgendamento())
}

ClassMethod Buscar(pCpf As %Integer, pTabela As %String) As %Integer
{
	Set tStatement = ##class(%SQL.Statement).%New()
	
	Set tTabela = $CASE(pTabela,"M":"estagio_hospital.Medico","P":"estagio_hospital.Paciente")
	
	Set tSql = "SELECT ID FROM "_tTabela_" WHERE Cpf = "_pCpf
	Set tSc = tStatement.%Prepare(.tSql)
	
	If (tSc'=1)
	{
		Do $SYSTEM.Status.DisplayError(tSc)
		Set tId = -1
	}
	Else
	{
		Set tResultSet = tStatement.%Execute()
		//Do tResultSet.%Display()
		
		If (tResultSet.%Next())
		{
			Set tId = tResultSet.%Get("ID")
		}
		Else
		{
			Set tId = 0
		}
	}
	
	Quit tId
}

ClassMethod ListarAgendamentos(pFiltro As %Integer = "")
{
	Do ..Header("Lista de Agendamentos")
	Read:(pFiltro="") !,"# Filtrar por CPF (Opcional): ", pFiltro#11 ,?79,"#"
	Set tSql = "SELECT ID, Paciente->Nome As Nome_Paciente, Paciente->Cpf As Cpf_Paciente"
	Set tSql = tSql_", Medico->Nome As Nome_Medico, Medico->Cpf As Cpf_Medico"
	Set tSql = tSql_", DataConsulta As Data_Consulta FROM estagio_hospital.Agendamento"
	
	
	Set tStatement = ##class(%SQL.Statement).%New()
	If (pFiltro'="")
	{
		Set tSql = tSql_" WHERE Medico->Cpf %STARTSWITH ? OR Paciente->Cpf %STARTSWITH ?"
	}
	
	Set tStatus = tStatement.%Prepare(.tSql)
	
	If (tStatus'=1)
	{
		Do $SYSTEM.Status.DisplayError(tStatus)
		Quit
	}
	
	If (pFiltro'="")
	{		
		Set tResultSet = tStatement.%Execute(pFiltro,pFiltro)
	}
	Else
	{
		Set tResultSet = tStatement.%Execute()
	}
	
	/*
	If (pFiltro'="")
	{
		Set tSql = tSql_" WHERE Medico->Cpf %STARTSWITH "_pFiltro_" OR Paciente->Cpf %STARTSWITH "_pFiltro_""
	}
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatus = tStatement.%Prepare(.tSql)
	
	If (tStatus'=1)
	{
		Do $SYSTEM.Status.DisplayError(tStatus)
		Quit
	}
	
	Set tResultSet = tStatement.%Execute()
	//Do tResultSet.%Display()
	*/
	
	Write !,"#|_ID_|____Nome______|_CPF_Paciente|_Nome_Medico_|_CPF_Medico__|__Agendamento_|#"
	While (tResultSet.%Next())
	{		
		Hang .03
		Write !,"#|",?2,tResultSet.%Get("ID"),?6,"|",
		?7,$EXTRACT(tResultSet.%Get("Nome_Paciente"),1,14),?21,"|",
		?23,tResultSet.%Get("Cpf_Paciente"),?35,"|",
		?36,$EXTRACT(tResultSet.%Get("Nome_Medico"),1,14),?49,"|",
		?51,tResultSet.%Get("Cpf_Medico"),?63,"|",
		?66,$ZDATE(tResultSet.%Get("Data_Consulta"),4),?78,"|#"
	}
	
	Set tNavegacao = ..Navegacao(2)
	Quit:((tNavegacao'=0) && (tNavegacao'=1))
	Do $CASE(tNavegacao, 0:..Inicio(), 1:..Editar())
}

ClassMethod Editar()
{
	Write !,"Qual ID deseja editar"
}

ClassMethod GerarRelatorio()
{
	Do ..Header("Relatório de Agendamentos")
	
	Read !,"# Filtrar relatório por mês (OPCIONAL): ", tFiltro ,?79,"#"
	Set:(tFiltro'="") tFiltro = $ZDATEH(tFiltro,4)
	Set tSql = "SELECT ID, Paciente->Nome As Nome_Paciente, Paciente->Cpf As Cpf_Paciente"
	Set tSql = tSql_", Medico->Nome As Nome_Medico, Medico->Cpf As Cpf_Medico"
	Set tSql = tSql_", DataConsulta As Data_Consulta FROM estagio_hospital.Agendamento"
	
	Set tStatement = ##class(%SQL.Statement).%New()
	If (tFiltro'="")
	{
		Set tSql = tSql_" WHERE DataConsulta > ?"
	}
	Set tSql = tSql_" ORDER BY DataConsulta"
	
	Set tStatus = tStatement.%Prepare(.tSql)	
	If (tStatus'=1)
	{
		Do $SYSTEM.Status.DisplayError(tStatus)
		Quit
	}
	
	If (tFiltro'="")
	{		
		Set tResultSet = tStatement.%Execute(tFiltro)
	}
	Else
	{
		Set tResultSet = tStatement.%Execute()
	}
	
	Set tNome = "agendamentos_"_$ZD($H,8)_"_"_$TR($ZT($PIECE($H,",",2)), ":","")
	
	Set tFile=##class(%File).%New(..#CaminhoRelatorio_tNome_".txt")
	Do tFile.Open("WSN")
	
	Set tTitulo = "Relatório de Agendamentos"_$CASE(tFiltro,"":"",:" - Filtrado por: "_$ZDATE(tFiltro,4))
	Do tFile.WriteLine($JUSTIFY(tTitulo,(((78-$LENGTH(tTitulo))/2) + $LENGTH(tTitulo))))
	Do tFile.WriteLine("================================================================================")
	
	Do tFile.WriteLine("#|_ID_|____Nome______|_CPF_Paciente|_Nome_Medico_|_CPF_Medico__|__Agendamento_|#")
	While (tResultSet.%Next())
	{
		Do tFile.WriteLine("#|"_tResultSet.%Get("ID")_$JUSTIFY("|",(5-$LENGTH(tResultSet.%Get("ID"))))_
		$EXTRACT(tResultSet.%Get("Nome_Paciente"),1,14)_$JUSTIFY("| ",(16-$LENGTH(tResultSet.%Get("Nome_Paciente"))))
		_tResultSet.%Get("Cpf_Paciente")_" |"_
		$EXTRACT(tResultSet.%Get("Nome_Medico"),1,13)_$JUSTIFY("| ",(15-$LENGTH(tResultSet.%Get("Nome_Medico"))))
		_tResultSet.%Get("Cpf_Medico")_" |  "_
		$ZDATE(tResultSet.%Get("Data_Consulta"),4)_"  |#")	
	}
	
	Do tFile.Close()
	Write !,"# Arquivo de relatório gravado em: "_..#CaminhoRelatorio, ?79,"#"
	
	Quit:(..Navegacao()'=0)
	Do ..Inicio()
}

Storage Default
{
<Data name="AgendamentoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Paciente</Value>
</Value>
<Value name="3">
<Value>Medico</Value>
</Value>
<Value name="4">
<Value>DataConsulta</Value>
</Value>
<Value name="5">
<Value>DataAgendamento</Value>
</Value>
</Data>
<DataLocation>^estagio.hospital.AgendamentoD</DataLocation>
<DefaultData>AgendamentoDefaultData</DefaultData>
<ExtentSize>0</ExtentSize>
<IdLocation>^estagio.hospital.AgendamentoD</IdLocation>
<IndexLocation>^estagio.hospital.AgendamentoI</IndexLocation>
<StreamLocation>^estagio.hospital.AgendamentoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

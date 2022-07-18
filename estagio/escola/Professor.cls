Class estagio.escola.Professor Extends (%Persistent, estagio.escola.Pessoa)
{

Parameter CaminhoRelatorio = "C:\InterSystems\IRIS\mgr\user\escola\professores\";

Index CredencialIndex On Credencial [ Unique ];

Property Credencial As %Integer [ Required, SqlColumnNumber = 7 ];

/// Gera um arquivo a partir de registros consultados no banco de dados.
ClassMethod GerarArquivo()
{
	Set tSC = $SYSTEM.Status.OK()
	
	Try
	{
		Read !,"# Filtrar relatório por idade acima de (OPCIONAL): ", tIdade ,?79,"#"
		Set:('$ISVALIDNUM(tIdade,0)) tIdade = 0
		
		Set tSql = "SELECT %ID, Nome, CPF, Nascimento, Telefone, Credencial, Idade FROM estagio_escola.Aluno"
		
		If (tIdade'="")
		{
			Set tSql = tSql_" WHERE Idade > ?"
		}
		Set tSql = tSql_" ORDER BY Idade"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tSC = tStatement.%Prepare(.tSql)
		Throw:$$$ISERR(tSC)
		
		If (tIdade'="")
		{		
			Set tResult = tStatement.%Execute(tIdade)
		}
		Else
		{
			Set tResult = tStatement.%Execute()
		}
		
		Set tNome = "professores_"_$ZDATE($HOROLOG,8)_"_"_$TRANSLATE($ZTIME($PIECE($HOROLOG,",",2)), ":","")
		Set tFile=##class(%File).%New(..#CaminhoRelatorio_"relatorios\"_tNome_".txt")
		Set tSC = tFile.Open("WSN")
		Throw:$$$ISERR(tSC)
		
		Set tTitulo = "Relatório de Alunos"_$CASE(tIdade,"":"",:" - Filtrado por idade maior que: "_tIdade)
		
		Set tSC = tFile.WriteLine($JUSTIFY(tTitulo,(((78-$LENGTH(tTitulo))/2) + $LENGTH(tTitulo))))
		Do tFile.WriteLine("================================================================================")
		
		Do tFile.WriteLine("#|_ID_|______Nome_______|_____CPF_____|_Telefone__|__RP__|_Nascimento_|_Idade_|#")
		While (tResult.%Next())
		{
			Do tFile.WriteLine("#|"_tResult.%Get("ID")_$JUSTIFY("|",(5-$LENGTH(tResult.%Get("ID"))))
			_$EXTRACT(tResult.%Get("Nome"),1,17)_$JUSTIFY("| ",(19-$LENGTH(tResult.%Get("Nome"))))
			_tResult.%Get("CPF")_" | "_tResult.%Get("Telefone")_$JUSTIFY("|",(11-$LENGTH(tResult.%Get("Telefone"))))
			_tResult.%Get("Credencial")_"| "_$ZDATE(tResult.%Get("Nascimento"),4)_" |"_$JUSTIFY(tResult.%Get("Idade"), 5)_"  |#")	
		}
		
		Do tFile.Close()
		Write !,"# Arquivo de relatório gravado em: "_..#CaminhoRelatorio_"relatorios\", ?79,"#"
	}
	Catch EXCEPTION
	{
		Do $SYSTEM.Status.DisplayError(tSC)
		Set tSC = EXCEPTION.AsStatus()
		Do $SYSTEM.Status.DisplayError(tSC)
	}
}

/// Lê um arquivo extraindo as linhas em <B>objetos</B> e salvando-os em seguida.
ClassMethod LerArquivo()
{
	Set tSC = $SYSTEM.Status.OK()
	
	Try
	{
		Set tNome = "professores"
		Set tFile=##class(%File).%New(..#CaminhoRelatorio_tNome_".txt")
		Set tSC = tFile.Open("R")
		
		Throw:$$$ISERR(tSC)
		
		While (tFile.AtEnd'=1)
		{
			Set tDados = tFile.ReadLine(,.tSC)
		
			Set tProfessor = ..%New()
			Set tProfessor.Nome = $PIECE(tDados,";",1)
			Set tProfessor.Nascimento = ..NascimentoDisplayToLogical($PIECE(tDados,";",2))
			Set tProfessor.Telefone = $PIECE(tDados,";",3)
			Set tProfessor.Endereco = $PIECE(tDados,";",4)
			Set tProfessor.CPF = $PIECE(tDados,";",5)
			Set tProfessor.Credencial = $PIECE(tDados,";",6)
			
			;Set tSC = tProfessor.%Save()

			Throw:$$$ISERR(tSC)
			
			/*
			Write !,tProfessor.Nome,?20,"| "
			Write ..NascimentoLogicalToDisplay(tProfessor.Nascimento),?33,"| "
			Write tProfessor.Telefone,?45,"| "
			Write tProfessor.Endereco,?56,"| "
			Write tProfessor.CPF,?70,"| "
			Write tProfessor.Credencial,?79,"|"
			*/
		}
		
		Do tFile.Close()
		Do ..ListarProfessores()
	}
	Catch EXCEPTION
	{
		;Do $SYSTEM.Status.DisplayError(tSC)
		Set tSC = EXCEPTION.AsStatus()
		Do $SYSTEM.Status.DisplayError(tSC)
	}
}

/// Listagem de todos os registros de professores por busca de ID com SQL
/// e instanciamento de objetos dos ID's retornados
ClassMethod ListarProfessores()
{
	Set tSC = $SYSTEM.Status.OK()
	
	Try
	{
		Set tSql = "SELECT %ID FROM estagio_escola.Professor"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tSC = tStatement.%Prepare(.tSql)
		
		Throw:$$$ISERR(tSC)
		
		Set tResult = tStatement.%Execute("T")
		
		If (tResult.%SQLCODE'=0)
		{
			Write !,"Erro: "_tResult.%Message
			Quit //Throw?
		}
		
		If (tResult.%Next()=0)
		{
			Write !,"***NENHUM REGISTRO***"
			Quit //Throw?
		}	
			
		Write !,"#|_ID_|__________Nome_________|_____CPF_____|_Nascimento_|_Telefone__|___RP___|#"
		Do
		{
			Set tProfessor = ..%OpenId(tResult.%Get("ID"))
			
			Hang .03
			
			Write !,"#|",?2,tProfessor.%Id(),?6,"|",
			?7,$EXTRACT(tProfessor.Nome,1,23),?30,"|",
			?32,tProfessor.CPF,?44,"|",
			?46,..NascimentoLogicalToDisplay(tProfessor.Nascimento),?57,"|",
			?59,tProfessor.Telefone,?69,"|",
			?71,tProfessor.Credencial,?78,"|#"
			
		} While (tResult.%Next())
	}
	Catch EXCEPTION
	{
		;Do $SYSTEM.Status.DisplayError(tSC)
		Set tSC = EXCEPTION.AsStatus()
		Do $SYSTEM.Status.DisplayError(tSC)
	}
}

Storage Default
{
<Data name="ProfessorDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Nome</Value>
</Value>
<Value name="3">
<Value>Nascimento</Value>
</Value>
<Value name="4">
<Value>Telefone</Value>
</Value>
<Value name="5">
<Value>Endereco</Value>
</Value>
<Value name="6">
<Value>CPF</Value>
</Value>
<Value name="7">
<Value>Credencial</Value>
</Value>
</Data>
<DataLocation>^estagio.escola.ProfessorD</DataLocation>
<DefaultData>ProfessorDefaultData</DefaultData>
<ExtentSize>0</ExtentSize>
<IdLocation>^estagio.escola.ProfessorD</IdLocation>
<IndexLocation>^estagio.escola.ProfessorI</IndexLocation>
<StreamLocation>^estagio.escola.ProfessorS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

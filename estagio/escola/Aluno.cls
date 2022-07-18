Class estagio.escola.Aluno Extends (%Persistent, estagio.escola.Pessoa)
{

Parameter CaminhoRelatorio = "C:\InterSystems\IRIS\mgr\user\escola\alunos\";

Index RAIndex On RA [ Unique ];

Property RA As %Integer [ Required, SqlColumnNumber = 7 ];

/// Gera um arquivo a partir de registros consultados no banco de dados.
ClassMethod GerarArquivo()
{
	Set tSC = $SYSTEM.Status.OK()
	
	Try
	{
		Read !,"# Filtrar relatório por idade acima de (OPCIONAL): ", tIdade ,?79,"#"
		Set:('$ISVALIDNUM(tIdade,0)) tIdade = 0
		
		Set tSql = "SELECT %ID, Nome, CPF, Nascimento, Telefone, RA, Idade FROM estagio_escola.Aluno"
		Set tStatement = ##class(%SQL.Statement).%New()
		
		If (tIdade'="")
		{
			Set tSql = tSql_" WHERE Idade > ?"
		}
		Set tSql = tSql_" ORDER BY Idade"
		
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
		
		Set tNome = "alunos_"_$ZDATE($HOROLOG,8)_"_"_$TRANSLATE($ZTIME($PIECE($HOROLOG,",",2)), ":","")
		Set tFile=##class(%File).%New(..#CaminhoRelatorio_"relatorios\"_tNome_".txt")
		Set tSC = tFile.Open("WSN")
		Throw:$$$ISERR(tSC)
		
		Set tTitulo = "Relatório de Alunos"_$CASE(tIdade,"":"",:" - Filtrado por idade maior que: "_tIdade)
		
		Set tSC = tFile.WriteLine($JUSTIFY(tTitulo,(((78-$LENGTH(tTitulo))/2) + $LENGTH(tTitulo))))
		Do tFile.WriteLine("================================================================================")
		
		Do tFile.WriteLine("#|_ID_|______Nome_______|_____CPF_____|_Telefone__|__RA__|_Nascimento_|_Idade_|#")
		While (tResult.%Next())
		{
			Do tFile.WriteLine("#|"_tResult.%Get("ID")_$JUSTIFY("|",(5-$LENGTH(tResult.%Get("ID"))))
			_$EXTRACT(tResult.%Get("Nome"),1,17)_$JUSTIFY("| ",(19-$LENGTH(tResult.%Get("Nome"))))
			_tResult.%Get("CPF")_" | "_tResult.%Get("Telefone")_$JUSTIFY("|",(11-$LENGTH(tResult.%Get("Telefone"))))
			_tResult.%Get("RA")_"| "_$ZDATE(tResult.%Get("Nascimento"),4)_" |"_$JUSTIFY(tResult.%Get("Idade"), 5)_"  |#")	
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
		Set tNome = "alunos"
		Set tFile=##class(%File).%New(..#CaminhoRelatorio_tNome_".txt")
		Set tSC = tFile.Open("R")
		
		Throw:$$$ISERR(tSC)
		
		While (tFile.AtEnd'=1)
		{
			Set tDados = tFile.ReadLine(,.tSC)
		
			Set tAluno = ..%New()
			Set tAluno.Nome = $PIECE(tDados,";",1)
			Set tAluno.Nascimento = $ZDATEH($PIECE(tDados,";",2),4)
			Set tAluno.Telefone = $PIECE(tDados,";",3)
			Set tAluno.Endereco = $PIECE(tDados,";",4)
			Set tAluno.CPF = $PIECE(tDados,";",5)
			Set tAluno.RA = $PIECE(tDados,";",6)
			
			;Set tSC = tAluno.%Save()
			
			Throw:$$$ISERR(tSC)
			
			/*
			Write !,tAluno.Nome,?20,"| "
			Write $ZDATE(tAluno.Nascimento, 4),?33,"| "
			Write tAluno.Telefone,?45,"| "
			Write tAluno.Endereco,?56,"| "
			Write tAluno.CPF,?70,"| "
			Write tAluno.RA,?79,"|"
			*/
		}
		
		Do tFile.Close()
		Do ..ListarAlunos()
	}
	Catch EXCEPTION
	{
		;Do $SYSTEM.Status.DisplayError(tSC)
		Set tSC = EXCEPTION.AsStatus()
		Do $SYSTEM.Status.DisplayError(tSC)
	}
}

/// Listagem de todos os registros de alunos por busca de ID com SQL
/// e instanciamento de objetos dos ID's retornados
ClassMethod ListarAlunos()
{
	Set tSC = $SYSTEM.Status.OK()
	
	Try
	{
		Set tSql = "SELECT %ID, Nome, CPF, Nascimento, Telefone, RA FROM estagio_escola.Aluno"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tSC = tStatement.%Prepare(.tSql)
		
		Throw:$$$ISERR(tSC)
		
		Set tResult = tStatement.%Execute()

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
		
		Write !,"#|_ID_|__________Nome_________|_____CPF_____|_Nascimento_|_Telefone__|___RA___|#"
		Do
		{		
			Hang .03
			
			Write !,"#|",?2,tResult.%Get("ID"),?6,"|",
			?7,$EXTRACT(tResult.%Get("Nome"),1,23),?30,"|",
			?32,tResult.%Get("CPF"),?44,"|",
			?46,$ZDATE(tResult.%Get("Nascimento"),4),?57,"|",
			?59,tResult.%Get("Telefone"),?69,"|",
			?71,tResult.%Get("RA"),?78,"|#"
			
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
<Data name="AlunoDefaultData">
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
<Value>RA</Value>
</Value>
<Value name="5">
<Value>Endereco</Value>
</Value>
<Value name="6">
<Value>CPF</Value>
</Value>
<Value name="7">
<Value>Telefone</Value>
</Value>
</Data>
<DataLocation>^estagio.escola.AlunoD</DataLocation>
<DefaultData>AlunoDefaultData</DefaultData>
<ExtentSize>9</ExtentSize>
<IdLocation>^estagio.escola.AlunoD</IdLocation>
<IndexLocation>^estagio.escola.AlunoI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CPF">
<AverageFieldSize>7</AverageFieldSize>
<Selectivity>11.1111%</Selectivity>
</Property>
<Property name="Endereco">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Nascimento">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>11.1111%</Selectivity>
</Property>
<Property name="Nome">
<AverageFieldSize>14.33</AverageFieldSize>
<Selectivity>11.1111%</Selectivity>
</Property>
<Property name="RA">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Telefone">
<AverageFieldSize>6</AverageFieldSize>
<Selectivity>11.1111%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="RAIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^estagio.escola.AlunoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

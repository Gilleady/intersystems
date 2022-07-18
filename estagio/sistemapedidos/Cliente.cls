Class estagio.sistemapedidos.Cliente Extends (%Persistent, estagio.sistemapedidos.Interface)
{

Property Nome As %String [ Required, SqlColumnNumber = 2 ];

Property Endereco As %String [ Required, SqlColumnNumber = 3 ];

Property Telefone As %Integer [ Required, SqlColumnNumber = 4 ];

Index CpfIndex On Cpf [ Unique ];

Property Cpf As %Integer [ Required, SqlColumnNumber = 5 ];

Property Nascimento As %Date [ Required, SqlColumnNumber = 6 ];

Property Idade As %Integer [ Calculated, SqlComputeCode = { Set {Idade}=..CalcularIdade({Nascimento})
}, SqlComputed, SqlComputeOnChange = Nascimento ];

ClassMethod CalcularIdade(pNascimento As %Date = "") As %Integer [ CodeMode = expression ]
{
$Select(pNascimento="":"",1:($ZDATE($HOROLOG,8)-$ZDATE(pNascimento,8)\10000))
}

ClassMethod Cadastrar()
{
	Do ..Header("Cadastrar Clientes")

	New
	For
	{
		Read !,"# Nome.............: ", tNome, ?79, "#"
		If (tNome="")
		{
			Write !,"# Nome inválido, insira novamente", ?79, "#"
		}
		Quit:tNome'=""
	}
	For
	{
		Read !,"# Endereço.........: ", tEndereco, ?79, "#"
		If (tEndereco="")
		{
			Write !,"# Endereço inválido, insira novamente", ?79, "#"
		}
		Quit:tEndereco'=""
	}
	For 
	{
		Read !,"# Telefone.........: ", tTelefone, ?79, "#"
		
		Set isTel = ..ValidarTel(tTelefone)
		If (isTel)
		{
			Set telValido = 1
		}
		Else 
		{
			Write !,"# Número inválido, insira novamente", ?79, "#"
		}
		Quit:$DATA(telValido)
	}	
	For
	{
		Read !,"# CPF..............: ", tCpf, ?79, "#"
		
		Set tCpf = $TRANSLATE(tCpf," .-","")	
		Set isCpf = ..ValidarCpf(tCpf)
		If (isCpf)
		{
			Set cpfValido = 1
		}
		Else
		{
			Write !,"# CPF inválido, informe novamente", ?79, "#"
		}
		Quit:$DATA(cpfValido)
	}	
	For
	{
		Read !,"# Data Nascimento..: ", tNascimento, ?79, "#"
		
		Set isDate = ..ValidarData(tNascimento)			
		If (isDate)
		{
			Set tNascimento = $ZDATEH(tNascimento,4)	
			Set dtValida = 1
		}
		Else
		{
			Write !,"# Data inválida, informe novamente", ?79, "#"
		}
		Quit:$DATA(dtValida)
	}
	
	Set tCliente = ##class(estagio.sistemapedidos.Cliente).%New()
	Set tCliente.Nome = tNome
	Set tCliente.Endereco = tEndereco
	Set tCliente.Telefone = tTelefone
	Set tCliente.Cpf = tCpf
	Set tCliente.Nascimento = tNascimento
	
	Set tSc = tCliente.%Save()
	If (tSc=1)
	{
		Write !,"#", ?79, "#",!,"# Cadastro realizado com sucesso! ID: "_tCliente.%Id(), ?79, "#"
	}
	Else
	{
		Write !,"#", ?79, "#"
		Do $SYSTEM.Status.DisplayError(tSc)
	}
		
	Set tNavegacao = ##class(estagio.sistemapedidos.Interface).Navegacao(1)
	Quit:((tNavegacao'=1) && (tNavegacao'=0))
	Do $CASE(tNavegacao, 1:..Cadastrar(), 0:..SistemaPedidos())
}

ClassMethod Exibir()
{
	Do ..Header("Exibir Clientes")
	Set tOpcaoSubMenu = ..SubMenu()
	
	If (tOpcaoSubMenu=1)
	{
		/* ***LISTAGEM GERAL*** */
		Do ..ListarClientes()
	}
	Elseif (tOpcaoSubMenu=2)
	{
		/* ***PESQUISA INDIVIDUAL*** */
		Do ..ExibirCliente()
	}
	Elseif (tOpcaoSubMenu=0)
	{
		Do ..SistemaPedidos()
	}
	Else
	{
		Quit
	}
}

ClassMethod ListarClientes()
{
	&sql(SELECT COUNT(*) INTO :myvar FROM estagio_sistemapedidos.Cliente)
	Do ..Header("Listagem de "_myvar_" Clientes")
		
	Set tSatement = ##class(%SQL.Statement).%New()
	Set tStatus = tSatement.%PrepareClassQuery("estagio.sistemapedidos.Cliente", "SelectAll")
	
	If $$$ISERR(tStatus)
	{ 
		Do $SYSTEM.OBJ.DisplayError(tStatus)
		Quit  
	}
	
	Set tResultSet = tSatement.%Execute()
	//Do tResultSet.%Display()
	
	Write !,"#|_ID_|____Nome_____|____Endereço____|_Telefone__|______CPF______|_Nascimento_|#"
	While (tResultSet.%Next())
	{
		Hang .03
		Write !,"#|"_$JUSTIFY(tResultSet.%Get("ID"),4),
		?6,"|" _$EXTRACT(tResultSet.%Get("Nome"),1,12),
		?20,"|"_$EXTRACT(tResultSet.%Get("Endereco"),1,15),
		?37,"| "_..RetornarTel(tResultSet.%Get("Telefone")),
		"| "_..RetornarCpf(tResultSet.%Get("Cpf")),
		"| "_$ZDATE(tResultSet.%Get("Nascimento"),4),?78,"|#"
	}
	
	Set tNavegacao = ..Navegacao(2)
	Quit:((tNavegacao'=1) && (tNavegacao'=2) && (tNavegacao'=0))
	Do $CASE(tNavegacao, 1:..Exibir(), 2:..ExibirCliente(), 0:..SistemaPedidos())
}

Query SelectAll() As %SQLQuery [ SqlProc ]
{
	SELECT ID, Nome, Endereco, Telefone, Cpf, Nascimento FROM estagio_sistemapedidos.Cliente
 	ORDER BY ID
}

ClassMethod ExibirCliente(pClienteId As %Integer)
{
	Do ..Header("Exibir Cliente por ID")
	
	If ('$DATA(pClienteId))
	{
		For
		{
			Read !,"# Entre com o id desejado: ", tClienteID, ?79, "#"
			
			If (tClienteID?.N) && (tClienteID'="")
			{
				Set idValido = 1
			}
			Else
			{
				Write !,"# ID inválido, informe novamente", ?79, "#"
			}
			
			Quit:$DATA(idValido)
		}
	}
	Else
	{
		Set tClienteID = pClienteId
		Write !,"# Entre com o id desejado: ", tClienteID, ?79, "#"
	}

	If (..%ExistsId(tClienteID))
	{		
		Set tCliente = ..%OpenId(tClienteID)
	
		Write !,"# Nome.............: ", tCliente.Nome, ?79, "#"
		Write !,"# Endereço.........: ", tCliente.Endereco, ?79, "#"
		Write !,"# Telefone.........: ", ..RetornarTel(tCliente.Telefone), ?79, "#"
		Write !,"# CPF..............: ", ..RetornarCpf(tCliente.Cpf), ?79, "#"
		Write !,"# Data Nascimento..: ", $ZDATE(tCliente.Nascimento,4), " - Idade: "_tCliente.Idade ,?79, "#"
		
		Set tNavegacao = ..Navegacao(3)
		Quit:((tNavegacao'=1) && (tNavegacao'=2) && (tNavegacao'=3) && (tNavegacao'=0))
		Do $CASE(tNavegacao, 1:..Exibir(), 2:tCliente.Editar(), 3:tCliente.Excluir(), 0:..SistemaPedidos())
	}
	Else
	{	
		Write !,"# ***Nenhum registro encontrado***", ?79, "#"
		
		Set tNavegacao = ..Navegacao("")
		Quit:((tNavegacao'=1) && (tNavegacao'=0))
		Do $CASE(tNavegacao, 1:..Exibir(), 0:..SistemaPedidos())
	}
}

Method Editar()
{
	Do ..Header("Editar Cliente ID: "_..%Id())

    Set op = ..SubMenu("C")
	Do:op=0 ..SistemaPedidos()
	Quit:((op'=1) && (op'=2) && (op'=3) && (op'=4) && (op'=5))
	
	Write !,"#", ?79, "#"
	
	New
	If (op=1)
	{
		For
	    {
			Write !,"# Nome atual: "_..Nome, ?79,"#"
			Read !,"# Insira o novo nome...............: ", tNome, ?79, "#"
			If (tNome="")
			{
				Write !,"# Nome inválido, insira novamente", ?79, "#"
			}
			Else
			{
				Set ..Nome = tNome
			}
			Quit:tNome'=""
	    }
	}
	Elseif (op=2)
	{
		For
		{
			Write !,"# Endereço atual: "_..Endereco, ?79,"#"
			Read !,"# Insira o novo endereço...........: ", tEndereco, ?79, "#"
			If (tEndereco="")
			{
				Write !,"# Endereço inválido, insira novamente", ?79, "#"
			}
			Else
			{
				Set ..Endereco = tEndereco
			}
			Quit:tEndereco'=""
		}
	}
	Elseif (op=3)
	{
		For 
		{
			Write !,"# Telefone atual: "_..Telefone, ?79,"#"
			Read !,"# Insira o novo telefone...........: ", tTelefone, ?79, "#"
			
			Set isTel = ..ValidarTel(tTelefone)
			If (isTel)
			{
				Set ..Telefone = tTelefone
				Set telValido = 1
			}
			Else 
			{
				Write !,"# Número inválido, insira novamente", ?79, "#"
			}
			Quit:$DATA(telValido)
		}
	}
	Elseif (op=4)
	{
		For
		{
			Write !,"# CPF atual: "_..Cpf, ?79,"#"
			Read !,"# Insira o novo CPF................: ", tCpf, ?79, "#"
			
			Set tCpf = $TRANSLATE(tCpf," .-","")	
			Set isCpf = ..ValidarCpf(tCpf)
			If (isCpf)
			{
				Set ..Cpf = tCpf
				Set cpfValido = 1
			}
			Else
			{
				Write !,"# CPF inválido, informe novamente", ?79, "#"
			}
			Quit:$DATA(cpfValido)
		}
	}
	Elseif (op=5)
	{	
		For
		{
			Write !,"# Data de Nascimento atual: "_..Nascimento, ?79,"#"
			Read !,"# Insira a nova data de nascimento..: ", tNascimento, ?79, "#"
			
			Set isDate = ..ValidarData(tNascimento)			
			If (isDate)
			{
				Set tNascimento = $ZDATEH(tNascimento,4)	
				Set dtValida = 1
			}
			Else
			{
				Write !,"# Data inválida, informe novamente", ?79, "#"
			}
			Quit:$DATA(dtValida)
		}
	}
	
	Do ..Footer()
	
    Set tSc = ..%Save()
    If (tSc=1)
    {
		Write !,"#", ?79, "#",!,"# Registro atualizado com sucesso! ID: "_..%Id(), ?79, "#"
	}
	Else
	{
		Write !,"#", ?79, "#"
		Do $SYSTEM.Status.DisplayError(tSc)
	}
	
	Set op = ..Navegacao()
	Quit:((op'=1) && (op'=0))
	Do $CASE(op, 1:..Editar(), 0:..SistemaPedidos())
}

Method Excluir()
{
	Write !,"#", ?79,"#"
	Write !,"# Deseja realmente excluir o registro "_..%Id()_"? (S/N)"
	Read conf#1, ?79,"#"
	
	If ((conf="s") || (conf="S"))
	{	
		Set tSc = ..%DeleteId(..%Id())
		If (tSc=1)
		{
			Write !,"# Registro excluído com sucesso!", ?79,"#"
		}
		Else
		{
			Write !,"#", ?79, "#"
			Do $SYSTEM.Status.DisplayError(tSc)
		}
		
		Set op = ..Navegacao("")
		Quit:((op'=1) && (op'=0))
		Do $CASE(op, 1:..Exibir(), 0:..SistemaPedidos())
	} Else {
		Do ..Footer()
		Do ..ExibirCliente(..%Id())
	}
}

ClassMethod ValidarCpf(pCpf As %Integer) As %Integer
{
	/* && (pCpf'="11111111111") 
	&& (pCpf'="22222222222") && (pCpf'="33333333333") && (pCpf'="44444444444") 
	&& (pCpf'="55555555555") && (pCpf'="66666666666") && (pCpf'="77777777777") 
	&& (pCpf'="88888888888") && (pCpf'="99999999999") && (pCpf'="00000000000")*/
	If ((pCpf?11N)){
		// Calculo do 1º digito verificador
		Set peso = 10
		Set sm = 0
		
		For i = 1:1:9{
			Set num = $EXTRACT(pCpf,i)
			Set sm = sm + (num * peso)
			Set peso = peso - 1
		}
		
		Set r = 11 - (sm # 11)
		
		If ((r = 10) || (r = 11)){
			Set dig10 = 0
		}
		Else{
			Set dig10 = r
		}
		
		// Calculo do 2º digito verificador
		Set peso = 11
		Set sm = 0
		
		For i = 1:1:10{
			Set num = $EXTRACT(pCpf,i)
			Set sm = sm + (num * peso)
			Set peso = peso - 1
		}
		
		Set r = 11 - (sm # 11)
		
		If ((r = 10) || (r = 11)){
			Set dig11 = 0
		}
		Else{
			Set dig11 = r
		}
		
		//Verifica se os DV's são iguais aos informados
		If ((dig10 = $EXTRACT(pCpf, 10)) && (dig11 = $EXTRACT(pCpf,11))){
			Set tBoolean = 1
		}
		Else {
			Set tBoolean = 0
		}
		
	} Else {
		Set tBoolean = 0
	}
	Quit tBoolean
}

ClassMethod RetornarCpf(pCpf As %Integer) As %String
{
	Quit $EXTRACT(pCpf, 1, 3) _"."_ $EXTRACT(pCpf,4,6) _"."_ $EXTRACT(pCpf,7,9) _"-"_ $EXTRACT(pCpf,10,11)
}

ClassMethod ValidarData(pData As %String) As %Integer
{
	
	If (data?2N1"/"2N1"/"4N){

		If (($ZDATEH(data, 4) > 28853) && ($ZDATEH(data, 4) '> (+$HOROLOG))) {
			Set tBoolean = 1
		} Else {
			Set tBoolean = 0
		}
		
	} Else {
		Set tBoolean = 0
	}
	Quit tBoolean
}

ClassMethod ValidarTel(pTel As %Integer) As %Integer
{
	If (tel?9N) {
		Set tBoolean = 1
	} Else {
		Set tBoolean = 0
	}	
	Quit tBoolean
}

ClassMethod RetornarTel(pTel As %Integer) As %Integer
{
	Quit $EXTRACT(tel, 1, 5) _"-"_ $EXTRACT(tel,6,9)
}

Storage Default
{
<Data name="ClienteDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Nome</Value>
</Value>
<Value name="3">
<Value>Endereco</Value>
</Value>
<Value name="4">
<Value>Telefone</Value>
</Value>
<Value name="5">
<Value>Cpf</Value>
</Value>
<Value name="6">
<Value>Nascimento</Value>
</Value>
</Data>
<DataLocation>^estagio.sistemaped9D39.ClienteD</DataLocation>
<DefaultData>ClienteDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^estagio.sistemaped9D39.ClienteD</IdLocation>
<IndexLocation>^estagio.sistemaped9D39.ClienteI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
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
<Property name="Endereco">
<AverageFieldSize>15</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Nascimento">
<AverageFieldSize>11</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Nome">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Telefone">
<AverageFieldSize>6</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="CpfIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^estagio.sistemaped9D39.ClienteS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

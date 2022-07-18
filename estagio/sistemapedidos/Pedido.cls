Class estagio.sistemapedidos.Pedido Extends (%Persistent, estagio.sistemapedidos.Interface)
{

Property ClienteID As %Integer [ Required, SqlColumnNumber = 2 ];

Property ProdutoID As %Integer [ Required, SqlColumnNumber = 3 ];

Property Quantidade As %Integer [ Required, SqlColumnNumber = 4 ];

Property Total As %Decimal [ Transient ];

ClassMethod Cadastrar()
{
	Do ..Header("Realizar Pedidos")

	New
	For
	{	
		Read !,"# ID do Cliente....: ", tClienteID, ?79, "#"
		
		If (##class(estagio.sistemapedidos.Cliente).%ExistsId(tClienteID))
		{
			Set tClienteValido = 1
		}
		Else
		{
			Write !,"# Registro não encontrado", ?79, "#"
		}
		Quit:$DATA(tClienteValido)
	}
	For
	{
		Read !,"# ID do Produto....: ", tProdutoID, ?79, "#"
				
		If (##class(estagio.sistemapedidos.Produto).%ExistsId(tProdutoID))
		{
			Set tProdutoValido = 1
		}
		Else
		{
			Write !,"# Registro não encontrado", ?79, "#"
		}
		Quit:$DATA(tProdutoValido)
	}
	For
	{
		Read !,"# Quantidade.......: ", tQuantidade, ?79, "#"
		
		If ((tQuantidade?1.N) && (tQuantidade>0))
		{
			Set qtdValida = 1
		}
		Else
		{
			Write !,"# Quantidade inválida, insira novamente", ?79, "#"
		}
		Quit:$DATA(qtdValida)
	}
		
	Set tPedido = ..%New()
	Set tPedido.ClienteID = tClienteID
	Set tPedido.ProdutoID = tProdutoID
	Set tPedido.Quantidade = tQuantidade
	
	Set tSc = tPedido.%Save()
	If (tSc=1)
	{
		Write !,"#", ?79, "#",!,"# Pedido realizado com sucesso! ID: "_tPedido.%Id(), ?79, "#"
	}
	Else
	{
		Write !,"#", ?79, "#"
		Do $SYSTEM.Status.DisplayError(tSc)		
	}

	Set tNavegacao = ..Navegacao(1)
	Quit:((tNavegacao'=1) && (tNavegacao'=0))
	Do $CASE(tNavegacao, 1:..Cadastrar(), 0:..SistemaPedidos())
}

ClassMethod Exibir()
{
	Do ..Header("Exibir Pedidos")
	Set tOpcaoSubMenu = ..SubMenu()

	If (tOpcaoSubMenu=1) {
		/* ***LISTAGEM GERAL*** */
		Do ..ListarPedidos()
	} Elseif (tOpcaoSubMenu=2) {
		/* ***PESQUISA INDIVIDUAL*** */
		Do ..ExibirPedido()
	} Elseif (tOpcaoSubMenu=0) {
		Do ..SistemaPedidos()
	} Else {
		Quit
	}
}

ClassMethod ListarPedidos()
{
	&sql(SELECT COUNT(*) INTO :myvar FROM estagio_sistemapedidos.Pedido)
	Do ..Header("Listagem de "_myvar_" Pedidos")

	Set tSatement = ##class(%SQL.Statement).%New()
	Set tStatus = tSatement.%PrepareClassQuery("estagio.sistemapedidos.Pedido", "SelectAll")
	
	If $$$ISERR(tStatus)
	{ 
		Do $SYSTEM.OBJ.DisplayError(tStatus)
		Quit  
	}
	
	Set tResultSet = tSatement.%Execute()
	//Do tResultSet.%Display()
	
	Write !,"#|_ID_|_____Cliente_____|_IDC_|________Produto________|_IDP_|_Qtd_|___TOTAL___|#"	
	While (tResultSet.%Next())
	{
		Set tTotal = tResultSet.%Get("Preco") * tResultSet.%Get("Quantidade")
		
		Hang .03
		Write !,"#|"_ $JUSTIFY(tResultSet.%Get("ID"),4), ?6, "| ",
		$EXTRACT(tResultSet.%Get("NomeCliente"),1,15),
		?24,"|",$JUSTIFY(tResultSet.%Get("ClienteID"),5), ?30, "| ",
		$EXTRACT(tResultSet.%Get("NomeProduto"),1,21),
		?54,"|",$JUSTIFY(tResultSet.%Get("ProdutoID"),5), ?60,"|",
		$JUSTIFY(tResultSet.%Get("Quantidade"),5), ?66,"| R$",
		$JUSTIFY(tTotal,8,2),?78,"|#"
	}
	
    Set tNavegacao = ..Navegacao(2)
	Quit:((tNavegacao'=1) && (tNavegacao'=2) && (tNavegacao'=0))
	Do $CASE(tNavegacao, 1:..Exibir(), 2:..ExibirPedido(), 0:..SistemaPedidos())
}

Query SelectAll() As %SQLQuery [ SqlProc ]
{
	SELECT P.ID, ClienteID, C.Nome AS NomeCliente, ProdutoID, PR.Nome AS NomeProduto, PR.Preco AS Preco, Quantidade 
	FROM estagio_sistemapedidos.Pedido AS P 
	INNER JOIN estagio_sistemapedidos.Cliente AS C ON C.ID=P.ClienteID
	INNER JOIN estagio_sistemapedidos.Produto AS PR ON PR.ID=P.ProdutoID
 	ORDER BY P.ID
}

ClassMethod ExibirPedido(pPedidoId As %Integer)
{
	Do ..Header("Exibir Pedido por ID")
	
	If ('$DATA(pPedidoId))
	{
		For
		{
			Read !,"# Entre com o id desejado: ", tPedidoID, ?79, "#"
			
			If (tPedidoID?.N) && (tPedidoID'="")
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
		Set tPedidoID = pPedidoId
		Write !,"# Entre com o id desejado: ", tPedidoID, ?79, "#"
	}
		
	If (..%ExistsId(tPedidoID))
	{
		Set tPedido = ..%OpenId(tPedidoID)
		
		Set tCliente = ##class(estagio.sistemapedidos.Cliente).%OpenId(tPedido.ClienteID)
				
		Set tProduto = ##class(estagio.sistemapedidos.Produto).%OpenId(tPedido.ProdutoID)
		
		Set tPedido.Total = $FNUMBER((tProduto.Preco * tPedido.Quantidade),"",2)
		
		
		Write !,"# ID Cliente.......: ", tPedido.ClienteID, ?79, "#"
		Write !,"# Nome do Cliente..: ", tCliente.Nome, ?79, "#"
		Write !,"# ID Produto.......: ", tPedido.ProdutoID, ?79, "#"
		Write !,"# Nome do Produto..: ", tProduto.Nome, ?79, "#"
		Write !,"# Quantidade.......: ", tPedido.Quantidade, ?79, "#"
		Write !,"# TOTAL............: ", tPedido.Total, ?79, "#"
		
	    Set tNavegacao = ..Navegacao(3)
		Quit:((tNavegacao'=1) && (tNavegacao'=2) && (tNavegacao'=3) && (tNavegacao'=0))
		Do $CASE(tNavegacao, 1:..Exibir(), 2:tPedido.Editar(), 3:tPedido.Excluir(), 0:..SistemaPedidos())
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
    Do ..Header("Editar Pedido: "_..%Id())

	Set op = ..SubMenu("Pe")
	Do:op=0 ..SistemaPedidos()
	Quit:((op'=1) && (op'=2) && (op '= 3))
	
	For{
		Write !,"#", ?79, "#"
		Write !,"# Valor atual: "_$PIECE(^pedido(id),"^",op), ?79,"#"
	    Read !,"# Insira o novo valor: ", novoValor, ?79,"#"
	    
	    If ((op=1) && ((novoValor="") || ('$DATA(^cliente(novoValor))))) {
		 	Write !,"# Nenhum registro encontrado, informe novamente", ?79,"#"
	    } Elseif ((op=2) && ((novoValor="") || ('$DATA(^produto(novoValor))))){
		 	Write !,"# Nenhum registro encontrado, informe novamente", ?79,"#"
	    } Elseif ((op=3) && ((novoValor'?.N) || (novoValor=0))) {
		 	Write !,"# Quantidade inválida, informe novamente", ?79,"#"
	    } Else {
		 	Set valorValido = 1   
	    }
	    Quit:$DATA(valorValido)
	}
	New
	If (op=1)
	{
		For
		{ 
			Set tCliente = ##class(estagio.sistemapedidos.Cliente).%OpenId(..ClienteID)
			Write !,"# Cliente atual: "_..ClienteID_ " - "_tCliente.Nome, ?79,"#"
			Read !,"# Novo ID do Cliente....: ", tClienteID, ?79, "#"
			
			If (##class(estagio.sistemapedidos.Cliente).%ExistsId(tClienteID))
			{
				Set ..ClienteID=tClienteID
				Set tClienteValido = 1
			}
			Else
			{
				Write !,"# Registro não encontrado", ?79, "#"
			}
			Quit:$DATA(tClienteValido)
		}
	}
	Elseif (op=2)
	{
		For
		{
			Set tProduto = ##class(estagio.sistemapedidos.Cliente).%OpenId(..ProdutoID)
			Write !,"# Produto atual: "_..ProdutoID_ " - "_tProduto.Nome, ?79,"#"
			Read !,"# Novo ID do Produto....: ", tProdutoID, ?79, "#"
					
			If (##class(estagio.sistemapedidos.Produto).%ExistsId(tProdutoID))
			{
				Set ..ProdutoID=tProdutoID
				Set tProdutoValido = 1
			}
			Else
			{
				Write !,"# Registro não encontrado", ?79, "#"
			}
			Quit:$DATA(tProdutoValido)
		}
	}
	Elseif (op=3)
	{
		For
		{
			Read !,"# Quantidade.......: ", tQuantidade, ?79, "#"
			
			If ((tQuantidade?1.N) && (tQuantidade>0))
			{
				Set ..Quantidade=tQuantidade
				Set qtdValida = 1
			}
			Else
			{
				Write !,"# Quantidade inválida, insira novamente", ?79, "#"
			}
			Quit:$DATA(qtdValida)
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
		Do ..ExibirPedido(..%Id())
	}
}

Storage Default
{
<Data name="PedidoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ClienteID</Value>
</Value>
<Value name="3">
<Value>ProdutoID</Value>
</Value>
<Value name="4">
<Value>Quantidade</Value>
</Value>
<Value name="5">
<Value>Cliente</Value>
</Value>
<Value name="6">
<Value>Produto</Value>
</Value>
</Data>
<DataLocation>^estagio.sistemapedidos.PedidoD</DataLocation>
<DefaultData>PedidoDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^estagio.sistemapedidos.PedidoD</IdLocation>
<IndexLocation>^estagio.sistemapedidos.PedidoI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ClienteID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ProdutoID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Quantidade">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^estagio.sistemapedidos.PedidoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

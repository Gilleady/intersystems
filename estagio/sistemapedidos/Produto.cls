Class estagio.sistemapedidos.Produto Extends (%Persistent, estagio.sistemapedidos.Interface)
{

Index NomeIndex On Nome [ Unique ];

Property Nome As %String [ Required, SqlColumnNumber = 2 ];

Property Descricao As %String [ Required, SqlColumnNumber = 3 ];

Property Preco As %Decimal(FORMAT = ",", SCALE = 2) [ Required, SqlColumnNumber = 4 ];

ClassMethod Cadastrar()
{
	Do ..Header("Cadastrar Produtos")
	
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
		Read !,"# Descrição........: ", tDescricao, ?79, "#"
		If (tDescricao="")
		{
			Write !,"# Descrição inválida, insira novamente", ?79, "#"
		}
		Quit:tDescricao'=""
	}
	For
	{
		Read !,"# Preço............: R$ ", tPreco, ?79, "#"
		
		If (((tPreco?1.N1".".2N) || (tPreco?1.N)) && (tPreco>0))
		{
			Set precoValido = 1
		}
		Else
		{
			Write !,"# Preço inválido, informe novamente", ?79, "#"
		}
		Quit:$DATA(precoValido)
	}
		
	Set tProduto = ..%New()
	Set tProduto.Nome = tNome
	Set tProduto.Descricao = tDescricao
	Set tProduto.Preco = tPreco
	
	Set tSc = tProduto.%Save()
	
	If (tSc=1)
	{
		Write !,"#", ?79, "#",!,"# Cadastro realizado com sucesso! ID: "_tProduto.%Id(), ?79, "#"
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
	Do ..Header("Exibir Produtos")
	Set tOpcaoSubMenu = ..SubMenu()	
	
	If (tOpcaoSubMenu=1)
	{
		/* ***LISTAGEM GERAL*** */
		Do ..ListarProdutos()
	}
	Elseif (tOpcaoSubMenu=2)
	{
		/* ***PESQUISA INDIVIDUAL*** */
		Do ..ExibirProduto()
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

ClassMethod ListarProdutos()
{
	&sql(SELECT COUNT(*) INTO :myvar FROM estagio_sistemapedidos.Produto)
	DO ..Header("Listagem de "_myvar_" Produtos")
	
	Set tSatement = ##class(%SQL.Statement).%New()
	Set tStatus = tSatement.%PrepareClassQuery("estagio.sistemapedidos.Produto", "SelectAll")
	
	If $$$ISERR(tStatus)
	{ 
		Do $SYSTEM.OBJ.DisplayError(tStatus)
		Quit  
	}
	
	Set tResultSet = tSatement.%Execute()
	//Do tResultSet.%Display()
	
	Write !,"#|_ID_|_______Nome_______|________________Descrição________________|__Preço___|#"
	While (tResultSet.%Next())
	{
		Hang .03
		Write !,"#|"_$JUSTIFY(tResultSet.%Get("ID"),4),
		?6,"|" _$EXTRACT(tResultSet.%Get("Nome"),1,16),
		?25, "|"_$EXTRACT(tResultSet.%Get("Descricao"),1,39),
		?67, "| R$ "_$JUSTIFY(tResultSet.%Get("Preco"), 6,2), ?77,"|#"
	}
		
	Set tNavegacao = ..Navegacao(2)
	Quit:((tNavegacao'=1) && (tNavegacao'=2) && (tNavegacao'=0))
	Do $CASE(tNavegacao, 1:..Exibir(), 2:..ExibirProduto(), 0:..SistemaPedidos())
}

Query SelectAll() As %SQLQuery [ SqlProc ]
{
	SELECT ID, Nome, Descricao, Preco FROM estagio_sistemapedidos.Produto
 	ORDER BY ID
}

ClassMethod ExibirProduto(pProdutoId As %Integer)
{
	Do ..Header("Exibir Produto por ID")
	
	If ('$DATA(pProdutoId))
	{
		For
		{
			Read !,"# Entre com o id desejado: ", tProdutoID, ?79, "#"
			
			If (tProdutoID?.N) && (tProdutoID'="")
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
		Set tProdutoID = pProdutoId
		Write !,"# Entre com o id desejado: ", tProdutoID, ?79, "#"
	}
		
	If (..%ExistsId(tProdutoID))
	{	
		Set tProduto = ..%OpenId(tProdutoID)
	
		Write !,"# Nome.............: ", tProduto.Nome, ?79, "#"
		Write !,"# Descrição........: ", tProduto.Descricao, ?79, "#"
		Write !,"# Preço............: R$ ", $FNUMBER(tProduto.Preco,"",2), ?79, "#"
		
		Set tNavegacao = ..Navegacao(3)
		Quit:((tNavegacao'=1) && (tNavegacao'=2) && (tNavegacao'=3) && (tNavegacao'=0))
		Do $CASE(tNavegacao, 1:..Exibir(), 2:tProduto.Editar(), 3:tProduto.Excluir(), 0:..SistemaPedidos())
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
	Do ..Header("Editar Produto "_..%Id())

    Set op = ..SubMenu("Pr")
	Do:op=0 ..SistemaPedidos()
	Quit:((op'=1) && (op'=2) && (op '= 3))
	
	Write !,"#", ?79, "#"
	
	New	
	If (op=1)
	{
		For
		{
			Write !,"# Nome atual: "_..Nome, ?79,"#"
			Read !,"# Nome.............: ", tNome, ?79, "#"
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
			Write !,"# Descrição atual: "_..Descricao, ?79,"#"
			Read !,"# Descrição........: ", tDescricao, ?79, "#"
			If (tDescricao="")
			{
				Write !,"# Descrição inválida, insira novamente", ?79, "#"
			}
			Else
			{
				Set ..Descricao = tDescricao
			}
			Quit:tDescricao'=""
		}
	}
	Elseif (op=3)
	{
		For
		{
			Write !,"# Preço atual: "_..Preco, ?79,"#"
			Read !,"# Preço............: R$ ", tPreco, ?79, "#"
			
			If (((tPreco?1.N1".".2N) || (tPreco?1.N)) && (tPreco>0))
			{
				Set ..Preco = Preco
				Set precoValido = 1
			}
			Else
			{
				Write !,"# Preço inválido, informe novamente", ?79, "#"
			}
			Quit:$DATA(precoValido)
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
	Do $CASE(op, 1:..Editar(..%Id()), 0:..SistemaPedidos())
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
		Do ..ExibirProduto(..%Id())
	}
}

Storage Default
{
<Data name="ProdutoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Nome</Value>
</Value>
<Value name="3">
<Value>Descricao</Value>
</Value>
<Value name="4">
<Value>Preco</Value>
</Value>
</Data>
<DataLocation>^estagio.sistemaped9D39.ProdutoD</DataLocation>
<DefaultData>ProdutoDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^estagio.sistemaped9D39.ProdutoD</IdLocation>
<IndexLocation>^estagio.sistemaped9D39.ProdutoI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Descricao">
<AverageFieldSize>30</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Nome">
<AverageFieldSize>16</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Preco">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="NomeIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^estagio.sistemaped9D39.ProdutoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

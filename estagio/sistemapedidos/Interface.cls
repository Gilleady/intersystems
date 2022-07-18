Class estagio.sistemapedidos.Interface [ Abstract ]
{

// Do ##class(estagio.sistemapedidos.Interface).SistemaPedidos()

ClassMethod SistemaPedidos()
{
	Do ..Header("Sistema de Pedidos")	
	Write !,"# Menu", ?79, "#"
	Write !,"# 1- Cadastrar Cliente", ?79, "#"
	Write !,"# 2- Cadastrar Produto", ?79, "#"
	Write !,"# 3- Realizar Pedido", ?79, "#"
	Write !,"# 4- Exibir Clientes", ?79, "#"
	Write !,"# 5- Exibir Produtos", ?79, "#"
	Write !,"# 6- Exibir Pedidos", ?79, "#"
	Write !,"# 0- Sair", ?79, "#"
	Write !,"#", ?79, "#"
	Read !,"# Entre com a opção desejada: ", tOpcao#1, ?79, "#"
	Do ..Footer()
	
	Quit:tOpcao=0
	
	Do $CASE(tOpcao, 1:##class(estagio.sistemapedidos.Cliente).Cadastrar(),
	2:##class(estagio.sistemapedidos.Produto).Cadastrar(), 3:##class(estagio.sistemapedidos.Pedido).Cadastrar(),
	4:##class(estagio.sistemapedidos.Cliente).Exibir(), 5:##class(estagio.sistemapedidos.Produto).Exibir(),
	6:##class(estagio.sistemapedidos.Pedido).Exibir(), :..SistemaPedidos())
}

ClassMethod SubMenu(pTbl As %Integer) As %Integer
{
	Write !,"# Opções", ?79, "#"
	If '$DATA(pTbl) {
		Write !,"# 1- Listagem Geral", ?79, "#"
		Write !,"# 2- Pesquisar por ID", ?79, "#"
	} Elseif (pTbl="C") {
		Write !,"# 1- Editar Nome", ?79, "#"
		Write !,"# 2- Editar Endereço", ?79, "#"
		Write !,"# 3- Editar Telefone", ?79, "#"
		Write !,"# 4- Editar CPF", ?79, "#"
		Write !,"# 5- Editar Data Nascimento", ?79, "#"
	} Elseif (pTbl="Pr") {
		Write !,"# 1- Editar Nome", ?79, "#"
		Write !,"# 2- Editar Descrição", ?79, "#"
		Write !,"# 3- Editar Preço", ?79, "#"
	} Elseif (pTbl="Pe") {
		Write !,"# 1- Editar ID do Cliente", ?79, "#"
		Write !,"# 2- Editar ID do Produto", ?79, "#"
		Write !,"# 3- Editar Quantidade", ?79, "#"
	}
	Write !,"# 0- Retornar ao Menu Principal", ?79, "#"
	Write !,"# **Qualquer tecla para sair**", ?79, "#"
	Write !,"#", ?79, "#"
	Read !,"# Entre com a opção desejada: ", tOpcao#1, ?79, "#"
	Do ..Footer()
	Quit tOpcao
}

ClassMethod Navegacao(pCrud As %Integer) As %Integer
{
	Do ..Footer()				
	Write !,"#", ?79, "#"
    If ('$DATA(pCrud)){
		Write !,"# 1- Editar novamente este registro", ?79, "#"
    } Elseif (pCrud=1){
		Write !,"# 1- Cadastrar novo registro", ?79, "#"
	} Elseif (pCrud=2) {
		Write !,"# 1- Menu Anterior", ?79, "#"
		Write !,"# 2- Exibir detalhes do registro", ?79, "#"
	} Elseif (pCrud=3) {
        Write !,"# 1- Menu Anterior", ?79, "#"
		Write !,"# 2- Editar registro", ?79, "#"
		Write !,"# 3- Excluir registro", ?79, "#"
    } Else {
		Write !,"# 1- Menu Anterior", ?79, "#"
    }

	Write !,"# 0- Menu Principal", ?79, "#"
	Write !,"# ** Qualquer tecla para sair **", ?79, "#"
	Read !,"# Entre com a opção desejada: ", tOpcao#1, ?79, "#"
	
	Do ..Footer()
	Quit tOpcao
}

ClassMethod Header(pTitle As %String)
{
	Write #,"################################################################################"
	Write !,"#", ?79, "#"
	Write !,"#", $JUSTIFY(pTitle, ((78-$LENGTH(pTitle))/2) + $LENGTH(pTitle)), ?79, "#"
	Write !,"#", ?62,$ZDATETIME($HOROLOG,4,2)_" #"
	Write !,"################################################################################"
	Write !,"#", ?79, "#"
}

ClassMethod Footer()
{
	Write !,"#", ?79, "#"
	Write !,"################################################################################"
}

}

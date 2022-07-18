Class estagio.hospital.Endereco Extends %SerialObject
{

Property Cidade As %String;

Property Rua As %String;

Property Estado As %String;

Method SetarEndereco(pRua As %String = "", pCidade As %String = "", pEstado As %String = "") As Endereco
{
	Set ..Rua = pRua
	Set ..Cidade = pCidade
	Set ..Estado = pEstado
	
	Quit $THIS
}

Storage Default
{
<Data name="EnderecoState">
<Value name="1">
<Value>Cidade</Value>
</Value>
<Value name="2">
<Value>Rua</Value>
</Value>
<Value name="3">
<Value>Estado</Value>
</Value>
</Data>
<State>EnderecoState</State>
<StreamLocation>^estagio.hospital.EnderecoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

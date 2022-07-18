Class estagio.escola.Pessoa Extends %SerialObject
{

Property Nome As %String [ Required, SqlColumnNumber = 2 ];

Property Nascimento As %Date(FORMAT = 4) [ Required, SqlColumnNumber = 3 ];

Property Telefone As %Integer [ Required, SqlColumnNumber = 5 ];

Property Endereco As %String [ Required, SqlColumnNumber = 6 ];

Index CPFIndex On CPF [ Unique ];

Property CPF As %Integer [ Required, SqlColumnNumber = 4 ];

Property Idade As %Integer [ Calculated, SqlColumnNumber = 8, SqlComputeCode = { Set {Idade}=..CalcularIdade({Nascimento})
}, SqlComputed, SqlComputeOnChange = Nascimento ];

ClassMethod CalcularIdade(pNascimento As %Date = "") As %Integer [ CodeMode = expression ]
{
$Select(pNascimento="":"",1:($ZDATE($HOROLOG,8)-$ZDATE(pNascimento,8)\10000))
}

Storage Default
{
<Data name="PessoaState">
<Value name="1">
<Value>Nome</Value>
</Value>
<Value name="2">
<Value>Nascimento</Value>
</Value>
<Value name="3">
<Value>Telefone</Value>
</Value>
<Value name="4">
<Value>Endereco</Value>
</Value>
<Value name="5">
<Value>CPF</Value>
</Value>
</Data>
<State>PessoaState</State>
<StreamLocation>^estagio.escola.PessoaS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

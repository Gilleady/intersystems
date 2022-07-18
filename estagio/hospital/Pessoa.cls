Class estagio.hospital.Pessoa Extends %SerialObject
{

Property Nome As %String [ Required, SqlColumnNumber = 3 ];

Index CpfIndex On Cpf [ Unique ];

Property Cpf As %Integer(MAXVAL = 99999999999, MINVAL = 10000000000) [ Required, SqlColumnNumber = 4 ];

Property Telefone As %Integer [ SqlColumnNumber = 5 ];

Property Nascimento As %Date(FORMAT = 4) [ Required, SqlColumnNumber = 7 ];

Property Idade As %Integer [ Calculated, SqlColumnNumber = 8, SqlComputeCode = { Set {Idade}=..CalcularIdade({Nascimento})
}, SqlComputed, SqlComputeOnChange = Nascimento ];

Property Endereco As estagio.hospital.Endereco [ SqlColumnNumber = 9 ];

ClassMethod CalcularIdade(pNascimento As %Date = "") As %Integer [ CodeMode = expression ]
{
$Select(pNascimento="":"",1:($ZDATE($HOROLOG,8)-$ZDATE(pNascimento,8)\10000))
}

ClassMethod Cadastrar(pCpf As %Integer) As estagio.hospital.Pessoa
{
}

Method Atualizar()
{
}

Method Excluir()
{
}

Storage Default
{
<Data name="PessoaDefaultData">
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
</Data>
<DataLocation>^estagio.hospital.PessoaD</DataLocation>
<DefaultData>PessoaDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^estagio.hospital.PessoaD</IdLocation>
<IndexLocation>^estagio.hospital.PessoaI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>27</AverageFieldSize>
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
<AverageFieldSize>2,Cidade:2,Estado:2,Rua:2</AverageFieldSize>
<Selectivity>100.0000%,Cidade:100.0000%,Estado:100.0000%,Rua:100.0000%</Selectivity>
</Property>
<Property name="Idade">
<AverageFieldSize>1</AverageFieldSize>
</Property>
<Property name="Nascimento">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Nome">
<AverageFieldSize>13</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Telefone">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="CpfIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<State>PessoaState</State>
<StreamLocation>^estagio.hospital.PessoaS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

local re = require 'relabel'

-- Tabela contendo informações sobre cada tipo de erro
local errinfo = {
	TermErr		= 'Termo esperado após operador!',
	FactorErr	= 'Fator esperado após operador!',
	ExpErr		= 'Expressão esperada após abertura de parênteses!',
	ClBrackErr	= 'Fechamento de parênteses esperado após expressão!',
	NumErr		= 'Parte fracionária de número é esperada após ponto flutuante!',
	AttErr		= 'Falta expressão do lado direito da atribuição',
  	fail		= 'Não definido!'
}

-- Tabela contendo todos os erros correspondentes à uma entrada
local errors = {}

-- Salva os erros na tabela errors
local function save_err(subject, pos, label)
	local line, col = re.calcline(subject,pos)
	table.insert(errors, {line=line, col=col, msg=errinfo[label]})
	return true
end

-- Função que, dado um padrão p, retorna uma string contendo uma expressão de recuperação
local function rec(p)
	return '( !('..p..') .)*'
end

-- Definições usadas na gramática
local def = { save_err = save_err }

-- Gramática para reconhecer expressões
local g = re.compile([[
	lang	<- Sp ((att / exp) Sp)* !.
	att		<- id "=" Sp exp^AttErr
	exp 	<- term (op1 term^TermErr)* 
	term	<- factor (op2 factor^FactorErr)*
	factor	<- id / num / '(' exp^ExpErr ')'^ClBrackErr
	op1		<- ('+' / '-') Sp
	op2		<- ('*' / '/') Sp
	id 		<- [a-zA-Z_][a-zA-Z0-9_]* Sp
	num		<- [0-9][0-9]*('.'([0-9]^+1)^NumErr )^-1 Sp
	Sp      <- (%s / %nl)*
]]..
	"TermErr		<- ('' -> 'TermErr' => save_err) " .. rec('op1 / ")"') .. '\n' ..
	"FactorErr		<- ('' -> 'FactorErr' => save_err) " .. rec('op1 / op2 / ")"') .. '\n' ..
	"ExpErr			<- ('' -> 'ExpErr' => save_err) " .. rec('")"') .. '\n' ..
	"ClBrackErr		<- ('' -> 'ClBrackErr' => save_err) " .. rec('op1 / op2 / ")"') .. '\n' ..
	"NumErr			<- ('' -> 'NumErr' => save_err) " .. rec('op1 / op2 / ")"') .. '\n' ..
	"AttErr			<- ('' -> 'AttErr' => save_err) " .. rec('exp / att') .. '\n'
, def)

local Parser = {}

function Parser.parse(str)
	errors = {}
	local ast, err, pos = g:match(str)
	local row, col = re.calcline(str,pos)
	pos = {row=row, col=col}
	return ast, err, pos
end

return Parser
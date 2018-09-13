local re = require 'relabel'

-- Tabela contendo informações sobre cada tipo de erro
local errinfo = {
	TermErr		= 'Termo esperado após operador!',
	ExpErr		= 'Expressão esperada!',
	ClBrackErr	= 'Fechamento de parênteses esperado após expressão!',
	NumErr		= 'Parte fracionária de número é esperada após ponto flutuante!',
	AttErr		= 'Falta expressão do lado direito da atribuição',
	EndInput	= 'Fim da entrada esperado',
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
	lang	<- Sp {| {:tag: '' -> 'lang':} {:value: {| ((att / exp) Sp)* |} :} |} (!.)^EndInput
	att		<- {| {:tag: '' -> 'att' :} {:value: {| id eq exp^AttErr |} :} |}
	exp 	<- {| {:tag: '' -> 'exp' :} {:value: {| term (op1 exp^ExpErr)^-1|} :} |}
	term	<- {| {:tag: '' -> 'term' :} {:value: {| factor (op2 term^TermErr)^-1 |} :} |}
	factor	<- {| {:tag: '' -> 'factor':} {:value: {| (id / num / opBrack exp^ExpErr clBrack^ClBrackErr) |} :} |}
	op1		<- {| {:tag: '' -> 'op1':} {:value: ('+' / '-') :} |} Sp
	op2		<- {| {:tag: '' -> 'op2':} {:value: ('*' / '/') :} |} Sp
	eq		<- '=' Sp
	opBrack	<- '(' Sp
	clBrack <- ')' Sp
	id 		<- {| {:tag: '' -> 'id':}  {:value: [a-zA-Z_][a-zA-Z0-9_]*:} |} Sp
	num		<- {| {:tag: '' -> 'num':} {:value: [0-9][0-9]*('.'([0-9]^+1)^NumErr )^-1 :} |} Sp
	Sp		<- (%s / %nl)*
]]..
	"TermErr		<- ('' -> 'TermErr' => save_err) 	{| {:tag: '' -> 'term'  :} {:value: '' -> 'DEFAULT_NODE' :} |}" .. rec('op1 / clBrack') .. '\n' ..
	"ExpErr			<- ('' -> 'ExpErr' => save_err) 	{| {:tag: '' -> 'exp' 	:} {:value: '' -> 'DEFAULT_NODE' :} |}" .. rec('")"') .. '\n' ..
	"ClBrackErr		<- ('' -> 'ClBrackErr' => save_err) " .. rec('op1 / op2 / clBrack') .. '\n' ..
	"NumErr			<- ('' -> 'NumErr' => save_err) 	{| {:tag: '' -> 'num' 	:} {:value: '' -> 'DEFAULT_NODE' :} |}" .. rec('op1 / op2 / clBrack') .. '\n' ..
	"AttErr			<- ('' -> 'AttErr' => save_err) 	{| {:tag: '' -> 'att'	:} {:value: '' -> 'DEFAULT_NODE' :} |}" .. rec('id / num / opBrack') .. '\n' ..
	"EndInput		<- ('' -> 'EndInput' => save_err) " .. rec('!.')
, def)

-- Obs.: Na label TermErr, captura um nó do tipo expretion, pois mudei a gramática

local Parser = {}

function Parser.parse(str)
	errors = {}
	local ast, err, pos = g:match(str)
	if pos then
		local row, col = re.calcline(str,pos)
		pos = {row=row, col=col}
	end
	return ast, err, pos or errors
end

function Parser.printAST(node, spaces)
	if spaces == nil then
		spaces = 0
	end

	for i=1, spaces do
		io.write " "
	end

	if node.tag ~= nil then
		io.write(node.tag..': ')
		if type(node.value) == 'table' then
			print ""
			for k,v in pairs(node.value) do
				Parser.printAST(v, spaces+2)
			end
		else
			print('"'..node.value..'"')
		end
	else
		print "Inesperado"
	end
end

return Parser

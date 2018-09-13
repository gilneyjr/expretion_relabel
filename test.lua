local parser = require 'parser'

local str

function myAssert(str)
	local ast, err, pos = parser.parse(str)
	io.write 'Expressão:\n"'
	io.write(str)
	io.write '"\n'

	if ast then
		if ast then
			print '\n\n============================'
			print "AST:"
			print "----------------------------"
			parser.printAST(ast)
			print "============================"
		else
			print "Erro não capturado!"
			io.write "Tipo: " print(err)
			io.write "Posição: " print('(linha: '..pos.row..', coluna: '..pos.col..')')
		end
		io.write '\n'
	else
		error("Resultado inesperado!")
	end

	if err then
		print("Falha no parser! (linha: "..pos.line..', coluna: '..pos.col..')')
	else
		print(#pos .. " erro(s) encontrado(s):")
		for i, v in ipairs(pos) do
			print("\t(linha: " ..v.line..', coluna: '..v.col..'): '..v.msg)
		end
	end

	print ""

end

print "> Testando Labels..."

print ">> Iniciando teste da label AttErr..."

str = "a = "
myAssert(str, #str+1)	-- str:len()+1, significa que o parser analisou toda a entrada

str = [=[
oi =



ola / 5 * ( 7 + 2 ) 
]=]
myAssert(str, str:len()+1)

str = [=[
a+b*(25+30) a =
b
]=]
myAssert(str, str:len()+1)

str = "a = , a = 2 + 2)"
myAssert(str, #str+1)

str = "2 * "
myAssert(str, #str+1)

io.write "OK\n"


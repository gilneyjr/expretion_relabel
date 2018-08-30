local parser = require 'parser'

local str

function myAssert(str,expec)
	local ast, err, pos = parser.parse(str)

	if expec ~= ast then
		if ast then
			io.write "\n\nResultado: "
			print(ast)
			io.write "Esperado: "
			print(expec)
		else
			print "Erro não capturado!"
			io.write "Tipo: " print(err)
			io.write "Posição: " print('(linha: '..pos.row..', coluna: '..pos.col..')')
		end
		io.write '\n'

		error("Resultado inesperado!")
	end
end

print "> Testando Labels..."

io.write ">> Iniciando teste da label AttErr... "

str = "a = "
myAssert(str, str:len()+1)	-- str:len()+1, significa que o parser analisou toda a entrada

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

io.write "OK\n"


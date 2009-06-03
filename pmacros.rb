require 'pp'

class PyMacros
	def initialize
		@arith = {
				:+ => :Add, 
				:- => :Sub, 
				:* => :Mul, 
				:/ => :Div, 
				:% => :Mod, 
				:** => :Power, 
				:<< => :LeftShift, 
				:>> => :RightShift, 
				:& => :Bitand, 
				:| => :Bitor, 
				:^ => :Bitxor
			}
	end
	
	def transform(exp)
		toAst exp
	end

	def toAst(exp)
		return exp if not exp.kind_of? Array
		
		type, exp = exp[0], exp[1..-1]
		case type
			when :arith
				[
					@arith[exp[0]], 
					[:tuple] + mapToAst(exp[1..-1])
				]
			when :call    then [:CallFunc, toAst(exp[0]), [:tuple] + mapToAst(exp[1..-1]), :None, :None]
			when :class   then
				[:Class, 
					[:str, exp[0]], 
					[:list], 
					:None, 
					mapToAst(exp[1..-1])]
			when :def
				[:Function, 
					:None,
					[:str, exp[0]], 
					[:tuple] + exp[1][1..-1].map { |x| [:str, x]}, 
					[:tuple], 0, :None, 
					toAst(exp[2])]
			when :getattr then [:CallFunc, [:Name, :getattr], [:tuple] + mapToAst(exp), :None, :None]
			when :import  then [:Import, [:tuple] + exp.map { |x| [:tuple, x[1], :None] }]
			when :list    then [:List, [:tuple] + mapToAst(exp)]
			when :name    then [:Name, [:str, exp[0]]]
			when :print   then [:Printnl, [:tuple] + mapToAst(exp), :None]
			when :raw     then toRaw exp[0]
			when :return  then [:Return, toAst(exp[0])]
			when :scope   then [:Stmt, [:tuple] + mapToAst(exp)]
			when :trycall then [:CallFunc, [:Name, :trycall], [:tuple] + mapToAst(exp), :None, :None]
			when :top     then [:Module, :None, [:Stmt, [:tuple] + mapToAst(exp)]]
			else puts 'Unknown type in emit: ' + type.to_s
		end
	end
	
	def toRaw(raw)
		if raw.kind_of? String    then [:Const, [:str, raw]]
		elsif raw.kind_of? Symbol then [:Name, [:str, raw]]
		else [:Const, raw]
		end
	end
	
	def mapToAst(exp) exp.map { |x| toAst x } end
end

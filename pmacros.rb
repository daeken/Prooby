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
					[:tuple], 
					:None, 
					mapToAst(exp[1..-1])]
			when :def
				[:Function, 
					:None,
					[:str, exp[0]], 
					[:tuple] + exp[1][1..-1].map { |x| [:str, x]}, 
					[:tuple], 0, :None, 
					toAst(exp[2])]
			when :getattr then [:CallFunc, [:Name, [:str, :getattr]], [:tuple] + mapToAst(exp), :None, :None]
			when :if
				[:If, 
					[:tuple, 
						[:tuple, 
							toAst(exp[0]), 
							toAst(
									if exp[1][0] == :scope then exp[1]
									else [:scope, exp[1]]
									end
								)]], 
					if exp[2] == nil then :None
					elsif exp[2][0] == :scope then toAst(exp[2])
					else toAst([:scope, exp[2]])
					end]
			when :import  then [:Import, [:tuple] + exp.map { |x| [:tuple, x[1], :None] }]
			when :lasgn
				[:Assign, 
					[:tuple, 
						[:AssName, 
							[:str, exp[0]], 
							[:str, :OP_ASSIGN]]], 
					toAst(exp[1])]
			when :list    then [:List, [:tuple] + mapToAst(exp)]
			when :name    then [:Name, [:str, exp[0]]]
			when :print   then [:Printnl, [:tuple] + mapToAst(exp), :None]
			when :raw     then toRaw exp[0]
			when :return  then [:Return, toAst(exp[0])]
			when :scope   then [:Stmt, [:tuple] + mapToAst(exp)]
			when :trycall
				target = toAst exp[0]
				[:IfExp, 
					[:CallFunc, [:Name, [:str, 'callable']], [:tuple, target], :None, :None], 
					[:CallFunc, target, [:tuple], :None, :None], 
					target]
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

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
		
		@handlers = self.public_methods.reject { |x| !x.match '^handle_' }
		@handlers.map! { |x| x[7..-1] }
		
		@maps = self.public_methods.reject { |x| !x.match '^map_' }
		@maps.map! { |x| x[4..-1] }
	end
	
	def transform(exp)
		return exp if not exp.kind_of? Array
		
		type, rest = exp[0], exp[1..-1]
		if @handlers.include? type.to_s then
			self.send(('handle_' + type.to_s).to_s, rest)
		elsif @maps.include? type.to_s then
			self.send(('map_' + type.to_s).to_s, map(rest))
		else
			puts 'Unknown type ' + type.to_s + ' in PyMacro'
			exp
		end
	end
	
	def map(exp) exp.map { |x| transform x } end
	
	def handle_arith(exp)
		[@arith[exp[0]], 
			[:tuple] + map(exp[1..-1])]
	end
	
	def map_call(exp)
		[:CallFunc, 
			exp[0], 
			[:tuple] + exp[1..-1], 
			:None, :None]
	end
	
	def handle_class(exp)
		[:Class, 
			[:str, exp[0]], 
			[:tuple], 
			:None, 
			map(exp[1..-1])]
	end
	
	def handle_def(exp)
		[:Function, 
			:None,
			[:str, exp[0]], 
			[:tuple] + exp[1][1..-1].map { |x| [:str, x]}, 
			[:tuple], 0, :None, 
			transform(exp[2])]
	end
	
	def handle_getattr(exp)
		[:CallFunc, [:Name, [:str, :getattr]], [:tuple] + map(exp), :None, :None]
	end
	
	def map_iasgn(exp)
		[:Assign,
			[:tuple,
				[:AssAttr,
					[:Name, [:str, :self]],
					[:str, exp[0].to_s[1..-1]],
					[:str, :OP_ASSIGN]]],
			exp[1]]
	end

	def map_if(exp)
		[:If, 
			[:tuple, 
				[:tuple, 
					exp[0], 
					exp[1]]], 
			if exp[2] == nil then :None
			else exp[2]
			end]
	end
	
	def handle_import(exp)
		[:Import, [:tuple] + exp.map { |x| [:tuple, x[1], :None] }]
	end
	
	def handle_ivar(exp)
		[:Getattr, 
			[:Name, [:str, :self]], 
			[:str, exp[0].to_s[1..-1]]]
	end
	
	def map_lasgn(exp)
		[:Assign, 
			[:tuple, 
				[:AssName, 
					[:str, exp[0]], 
					[:str, :OP_ASSIGN]]], 
			exp[1]]
	end
	
	def map_list(exp)
		[:List, [:tuple] + exp]
	end
	
	def handle_name(exp)
		[:Name, [:str, exp[0]]]
	end
	
	def map_print(exp)
		[:Printnl, 
			[:tuple] + exp, 
			:None]
	end
	
	def handle_raw(exp)
		if exp[0].kind_of? String    then [:Const, [:str, exp[0]]]
		elsif exp[0].kind_of? Symbol then [:Name, [:str, exp[0]]]
		else [:Const, exp[0]]
		end
	end
	
	def map_return(exp)
		[:Return, exp[0]]
	end
	
	def map_scope(exp)
		[:Stmt, [:tuple] + exp]
	end
	
	def map_trycall(exp)
		[:IfExp, 
			[:CallFunc, [:Name, [:str, 'callable']], [:tuple, exp[0]], :None, :None], 
			[:CallFunc, exp[0], [:tuple], :None, :None], 
			exp[0]]
	end
	
	def map_top(exp)
		[:Module, 
			:None, 
			[:Stmt, [:tuple] + exp]]
	end
end

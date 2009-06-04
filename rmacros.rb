require 'pp'

class RubyMacros
	def transform(exp)
		if exp[0] != :block then exp = [:block, exp] end
		
		@arith = [:+, :-, :*, :/, :%, :**, :<<, :>>, :&, :|, :^]
		
		@ignore = [:args]
		@pass   = [:class, :if, :lasgn, :masgn]
		@raw    = [:lit, :lvar, :str]
		@rename = {
				:array => :list, 
				:block => :scope, 
				:defn  => :def, 
				:iter  => :block
			}
		@handlers = self.public_methods.reject { |x| !x.match '^handle_' }
		@handlers.map! { |x| x[7..-1] }
		
		convert exp
	end
	
	def convert(exp)
		return exp if not exp.kind_of? Array
		
		type, rest = exp[0], exp[1..-1]
		if @ignore.include? type then
			exp
		elsif @pass.include? type then
			[type] + rest.map { |x| convert x }
		elsif @raw.include? type then
			[:raw] + rest
		elsif @rename.key? type then
			[@rename[type]] + rest.map { |x| convert x }
		elsif @handlers.include? type.to_s then
			self.send(('handle_' + type.to_s).to_s, rest)
		else
			puts 'Unknown type ' + type.to_s
			exp
		end
	end
	
	def handle_arglist(exp)
		exp.map { |x| convert x }
	end
	
  def arith(exp) [:arith, exp[1], convert(exp[0]), convert(exp[2])[0]] end
	def handle_call(exp)
		if @arith.include? exp[1] then
			return arith(exp)
		elsif exp[0] == nil and exp[1] == :_ and exp[2].length == 1 then
			return [:raw, :_]
		end
		
		target = 
			if exp[0] == nil then
				[:raw, exp[1]]
			else
				[
					:getattr, 
					convert(exp[0]), 
					case exp[1]
						when :[] then [:raw, '__getitem__']
						else [:raw, exp[1].to_s]
					end
				]
			end
		
		args = convert exp[2]
		
		case target
			when [:raw, :import] then [:import] + args
			when [:raw, :print] then [:print] + args
			else
				if args.length == 0 then 
					[:trycall, target]
				else
					[:call, target] + args
				end
		end
	end
	
	def handle_const(exp)
		if exp[0] == :True then [:raw, :True]
		elsif exp[0] == :False then [:raw, :False]
		else [:call, [:raw, exp[0]]]
		end
	end
	
	def handle_gvar(exp)
		[:name, exp[0].to_s[1..-1]]
	end
	
	def handle_scope(exp)
		convert exp[0]
	end
	
	def handle_true(exp)
		[:raw, :True]
	end
	def handle_false(exp)
		[:raw, :False]
	end
end

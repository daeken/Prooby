require 'pp'

class Array
	def transformShallow(type, &block)
		if self[0] == type then
			return yield(self)
		else
			return self.map do |item|
				if item.kind_of? Array then
					item.transformShallow type, &block
				else
					item
				end
			end
		end
	end
	
	def transform(type, &block)
		exp = self.map do |item|
			if item.kind_of? Array then
				item.transform type, &block
			else
				item
			end
		end
		if exp[0] == type then
			return yield(self)
		else
			return exp
		end
	end
end

class AstMacros
	def initialize
		@blockId = 0
		@noReturn = [:print, :return]
	end
	
	def transform(exp)
		exp = [:def, :top, [:args], exp]
		exp = moveBlocks exp
		exp = [:top] + exp[3][1..-1]
		exp = addReturns exp
		addSelfArgs exp
	end
	
	def rewriteArgs(exp)
		type, exp = exp[0], exp[1..-1]
		case type
			when :lasgn then [:args] + exp
			when :masgn then [:args] + exp[0][1..-1].map { |x| x[1] }
		end
	end
	
	def moveBlocks(exp)
		exp = exp.map do |x|
			if x.kind_of? Array then
				x.transformShallow(:def) do |item| moveBlocks item end
			else x
			end
		end
		return exp if exp[0] != :def
		
		def subMove(sub)
			sub = sub.map do |x|
				if x.kind_of? Array then
					x.transformShallow(:block) do |item| subMove item end
				else x
				end
			end
			return sub if sub[0] != :block
			
			name = 'block_' + @blockId.to_s
			@blockId += 1
			@blocks.push [
					:def, name, rewriteArgs(sub[2]), 
					if sub[3][0] == :scope then sub[3]
					else [:scope, sub[3]]
					end
				]
			
			name = [:name, name]
			call = sub[1]
			[:call, call[1]] + call[2..-1].map { |x|
					if x == [:raw, :_] then
						name
					else
						x
					end
				}
		end
		@blocks = []
		exp = subMove exp
		exp[3] = [:scope] + @blocks + exp[3][1..-1]
		
		exp
	end
	
	def addReturns(exp)
		exp.transform(:def) do |item|
			node = item[3].pop
			if not @noReturn.include? node[0] then
				node = [:return, node]
			end
			item[3].push node
			item
		end
	end
	
	def addSelfArgs(exp)
		return exp if not exp.kind_of? Array
		exp.map do |x|
			if x.kind_of? Array then
				x.transformShallow(:class) do |item|
					item.transformShallow(:def) do |sub|
						sub[2] = [:args, :self] + sub[2][1..-1]
						sub
					end
					
					addSelfArgs(item)
					item
				end
			else
				x
			end
		end
	end
end

require 'pp'

class Emit
	def emit(exp)
		if exp.kind_of? Array then
			type, exp = exp[0], exp[1..-1]
			case type
				when :tuple then
					if exp.length == 0 then '()'
					else '(' + exp.map { |x| emit x }.join(', ') + ',)'
					end
				when :str then '"' + exp[0].to_s + '"'
				else type.to_s + '(' + exp.map { |x| emit x }.join(', ') + ')'
			end
		else exp.to_s
		end
	end
end

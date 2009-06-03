require 'ruby_parser'
require 'pp'

require 'rmacros'
require 'amacros'
require 'pmacros'
require 'emit'

class Prooby
	def initialize(source)
		exp = RubyParser.new.parse source
		
		puts '"""'
		pp exp
		pp 'Running Ruby macros'
		exp = RubyMacros.new.transform exp
		pp exp
		pp 'Running AST macros'
		exp = AstMacros.new.transform exp
		pp exp
		pp 'Running Py macros'
		exp = PyMacros.new.transform exp
		pp exp
		pp 'Emitting AST'
		code = Emit.new.emit exp
		puts code
		puts '"""'
		
		puts 'import compiler'
		puts 'from compiler.ast import *'
		puts 'code = ' + code.to_str
		puts 'compiler.misc.set_filename("<pybur>", code)'
		puts 'eval(compiler.pycodegen.ExpressionCodeGenerator(code).getCode())'
	end
end

Prooby.new File.new(ARGV[0]).read

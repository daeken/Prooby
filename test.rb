class Foo
	def __init__(x)
		print 'foo!', x
	end
end

print map(_, range(1, 11)) { |x| print x; [x, x ** 2] }

print Foo(5)
print $Foo

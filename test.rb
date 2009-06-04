class Foo
	def __init__(x)
		print 'foo!', x
	end
end

foo = map(_, range(1, 11)) { |x| print x; x ** 2 }
print 'Sum of 1-10**2:', reduce(_, foo) { |accum, x| accum+x }
print Foo 5

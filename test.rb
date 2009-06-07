class Foo
	
	def __init__(x)
		@foo = 5
		print 'foo!', x
	end
	
	def __str__
		'Some Foo instance'
	end
end

foo = map(_, range(1, 11)) { |x| print x; x ** 2 }
print 'Sum of 1-10**2:', reduce(_, foo) { |accum, x| accum+x }
print Foo 5

#def test
#	false
#end

#if test then
#	print 'wewt'
#else
#	print 'no match'
#end

class Foo
	def __init__(x)
		@foo = x
		print @foo
	end
	
	def __str__
		'Some foo instance'
	end
end

foo = map(_, range(1, 11)) { |x| print x; x ** 2 }
print 'Sum of 1-10**2:', reduce(_, foo) { |accum, x| accum+x }
print Foo 5
print Foo 10

def test
	false
end

if test then
	print 'wewt'
else
	print 'no match'
end

#i = 0
#while i < 10 do
#	print 'foo'
#	i += 1
#end
#
#print 'done'

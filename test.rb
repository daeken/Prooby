ret = map(_, range(1, 11)) { |x| puts x; [x, x ** 2] }
puts ret

map(_, ret) { |x| puts x }

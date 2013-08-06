#
# Total a +1/-1 clicker - jQuery version
#

# external state
total = 0

# event handler - runs whenever
$('#plusOne').click(() ->
  total += 1 # mutating shared state
  $('#score').text(total))

# event handler - runs whenever
$('#minusOne').click(() ->
  total -= 1 # mutating shared state
  $('#score').text(total))

#
# Add two cells - jQuery version
#

a = 0
b = 0

$('#a').keyup((ev) ->
  a = parseInt($(ev.currentTarget).val())
  $('#answer').val(a + b))

$('#b').keyup((ev) ->
  b = parseInt($(ev.currentTarget).val())
  $('#answer').val(a + b))

# Imagine trying to do this for a spreadsheet; imagine lots of state
# Implementation has a bug - put in letters
#  * Can add validation, but it's scattered

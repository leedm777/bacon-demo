#
# Add two cells - Bacon.js version
#

inputVal = (ev) -> $(ev.currentTarget).val()

isNumber = (n) -> !isNaN(n)

# Compose the event stream in a really obvious way
a = $('#a').asEventStream('keyup')
  .map(inputVal) # get the value off the input event
  .map(parseInt) # parse to an int
  .filter(isNumber) # discard non-numbers
  .debounce(300) # debounce events by 300 millis
  .toProperty(0) # convert to property to get current value
  .log('a')

b = $('#b').asEventStream('keyup')
  .map(inputVal)
  .map(parseInt)
  .filter(isNumber)
  .debounce(300)
  .toProperty(0) # convert to property to get current value
  .log('b')

# Combine the two properties, applying the given function
answer = a.combine(b, (a, b) -> a + b)
  .log('answer')

# Assign that result on the screen
answer.assign($('#answer'), 'val')

#a.onValue((a) -> console.log("a: #{a}"))
#b.onValue((b) -> console.log("b: #{b}"))
#answer.onValue((answer) -> console.log("answer: #{answer}"))

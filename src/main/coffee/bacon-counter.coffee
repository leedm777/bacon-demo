#
# Total a +1/-1 clicker - Bacon.js version
#

#
# Conceptually, change button clicks to an array of numbers, reduce, update
#
#     events = [ -1, +1, -1, +1, +1, +1 ] # ...
#     total = events.reduce((sum, n) -> sum + n)
#     $('#score').text(total)
#
# But imagine if whenever you clicked a button, the events array automagically
# updated and the total and score were updated.
#
# Functional reactive programming tries to let you program declaritively:
#     a = b + c # means `a` always equals `b + c`
#

# You can create event streams from DOM events
minusOne = $('#minusOne').asEventStream('click').map(-1)
plusOne = $('#plusOne').asEventStream('click').map(+1)

# The event streams can be merged together
merged = plusOne.merge(minusOne)

# A Property is like an EventStream, but has a current value
#  * scan() works a bit like foldLeft()
#  * toProperty() maintains the most recent value from the stream
score = merged.scan(0, (sum, n) -> sum + n)

# Calls the method of the given object with each value of a Property/EventStream
score.assign($('#score'), 'text')

#
# EventStream
#  * Stream of events
#  * Observable (.onValue with a callback)
#  * Transform, filter, combine
#    * Like the monadic functions#
#

#minusOne.onValue((n) -> console.log("minus:  #{n}"))
#plusOne.onValue((n) -> console.log( "plus:   #{n}"))
#merged.onValue((n) -> console.log(  "merged: #{n}"))
#score.onValue((n) -> console.log(   "score:  #{n}"))

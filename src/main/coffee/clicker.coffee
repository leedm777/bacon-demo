#
# Issue a regular beat, measuring user's accuracy
#

# Setup properties from the input form using Bacon.UI
bpm = Bacon.UI.textFieldValue($('#bpm'), 60).map(parseInt)
  .filter((n) ->
    40 <= n <= 208)

accuracyMillis = Bacon.UI.textFieldValue($('#windowMillis'), 100).map(parseInt)
  .filter((n) ->
    10 <= n <= 300)

# Process the inputs into what you really need
millisPerBeat = bpm.map((n) ->
  60000 / n)

# Create a 1ms timer event stream
# There are lots of different ways of creating your own event streams
#  * once(), fromArray(), interval(), sequentially(), repeatedly(), later()
millis = Bacon.fromPoll(1, () ->
  new Date())

# You can flatMap to flatten streams within streams
beat = millisPerBeat.flatMapLatest((mpb) ->
  Bacon.fromPoll(mpb, () ->
    new Date()))

# EventStreams and properties can be combined in any number of ways
beat.onValue(() ->
  $("#tone").trigger('play'))

# Now let's process the player's input
guesses =
  $('html').asEventStream('keypress')
    .filter((ev) ->
      ev.which == 13)# mark on the enter key
    .map(() ->
      new Date())

# compare the guess to the beat
guessAccuracy = Bacon.combineTemplate({
  guess: guesses.toProperty(),
  millisPerBeat: millisPerBeat,
  beat: beat,
  accuracy: accuracyMillis
})
  .skipDuplicates((a, b) ->
    a.guess == b.guess)
  .map((ev) ->
    offset = ev.guess.getTime() - ev.beat.getTime()
    # If it's more than half off, consider it early
    if (offset > ev.millisPerBeat / 2)
      offset -= ev.millisPerBeat
    {
    offset: offset,
    accuracy: ev.accuracy
    })

guessAccuracy.map((ev) ->
  ev.offset).assign($('#off'), 'val')

# score the guesses
accumulate = (acc, ev) ->
  accuracy = ev.accuracy
  offset = Math.abs(ev.offset)
  if offset < accuracy
    acc.green += 1
  else if offset < 2 * accuracy
    acc.yellow += 1
  else
    acc.red += 1
  acc

score = guessAccuracy
  .scan({ green: 0, yellow: 0, red: 0 }, accumulate)

score.map((s) -> s.green).assign($('#green'), 'val')
score.map((s) -> s.yellow).assign($('#yellow'), 'val')
score.map((s) -> s.red).assign($('#red'), 'val')

meterCanvas = document.getElementById('meter')
meterCtx = meterCanvas.getContext('2d')

#meterCtx.fillStyle = 'red'
#meterCtx.fillRect(0, 0, meterCanvas.width, meterCanvas.height)

Bacon.combineTemplate({
  now: millis,
  guess: guesses.toProperty(null),
  millisPerBeat: millisPerBeat,
  beat: beat.toProperty(),
  accuracy: accuracyMillis,
}).onValue((ev) ->
    canvasWidth = meterCanvas.width
    stripWidth = canvasWidth * (ev.accuracy / ev.millisPerBeat) / 2

    meterCtx.fillStyle = 'red'
    meterCtx.fillRect(0, 0, meterCanvas.width, meterCanvas.height)

    meterCtx.fillStyle = 'yellow'
    meterCtx.fillRect(canvasWidth / 2 - stripWidth * 3, 0, stripWidth * 6,
      meterCanvas.height)

    meterCtx.fillStyle = 'green'
    meterCtx.fillRect(canvasWidth / 2 - stripWidth, 0, stripWidth * 2,
      meterCanvas.height)

    mark = (tick) ->
      offset_ms = tick.getTime() - ev.beat.getTime()
      # shift to put the green bar in the middle
      offset_ms = (offset_ms + ev.millisPerBeat / 2) % ev.millisPerBeat
      x = offset_ms * canvasWidth / ev.millisPerBeat
      meterCtx.fillRect(x, 0, 3, meterCanvas.height)

    meterCtx.fillStyle = 'black'
    mark(ev.now)

    if (ev.guess != null)
      meterCtx.fillStyle = 'blue'
      mark(ev.guess)
    )

#millis.take(10).log('millis')
#player.take(10).log('player')
#guesses.map((t) ->t.getTime()).log('guess')
#beat.map((t) ->t.getTime()).log('beat')
#guessAccuracy.log('guessAccuracy')
#score.log('score')

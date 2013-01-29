# Copyright 2013, Carlos Cardona v0.1.1
# Released under the MIT License.
# http://www.opensource.org/licenses/mit-license.php

class AFGeneticsLab
  constructor : ->
    @currentGenerationCount = 1
    @validNotes = ['a', 'a#', 'b', 'c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#']
    @validOctave = [0, 1, 2, 3, 4, 5, 6, 7]

  generateCreatures : ->

window.onload = ->

  afGeneticsLab = new AFGeneticsLab()
  $('#gaSubmit').click((evnt) ->
    afGeneticsLab.setProperties({
      generationSize     : parseInt($('#generationSize').val(), 10),
      generationCount    : parseInt($('#generationCount').val(), 10),
      mutationPercentage : parseInt($('#mutationPercentage').val(), 10),
      dnaBitCount        : parseInt($('#dnaBitCount').val(), 10),
      dnaStepCount       : parseInt($('#dnaStepCount').val(), 10),
      scaleSteps         : $('input:radio[name=scales]').val().split(','),
      musicKey           : $('#keys').val(),
      octave             : $('#octave').val()
    })
  )

  # create a generation of creatures
  generationOfCreatures = afGeneticsLab.generateCreatures()

  # Because it's the first generation wrap their dna property in a span with a class
  _.each(generationOfCreatures, (value, key) ->
    value.dna = $('<span class="root">' + value.dna + '</span>')
    value.parent1 = $('<span class="root">' + value.parent1 + '</span>')
    value.parent2 = $('<span class="root">' + value.parent2 + '</span>')
  , this)

  # Evolve them and sort by fitness score
  evolvedGenerationOfCreatures = afGeneticsLab.evolveDNA(generationOfCreatures)
  sortedGenerationOfCreatures  = evolvedGenerationOfCreatures.sort((a,b) -> return a.fitness - b.fitness;).reverse()

  # Wrap each creature in some markup to display on the screen
  $(sortedGenerationOfCreatures).each((indx, elmnt) ->
    listItem = $('<li>')

    domEls = [
      $('<p>Name: ' + elmnt.name + '</p>'),
      $('<p>Generation: ' + elmnt.generation + '</p>'),
      $('<p>DNA: </p>').append(elmnt.dna),
      $('<p>Fitness: ' + elmnt.fitness + '</p>'),
      $('<p>Notes: ' + elmnt.notes + '</p>'),
      $('<p>Parent1: </p>').append($('<a class="parent1DNA showParent" id="' + elmnt.parent1.name + '" href="#">' + elmnt.parent1.name + '</a>')),
      $('<p>Parent2: </p>').append($('<a class="parent2DNA showParent" id="' + elmnt.parent2.name + '" href="#">' + elmnt.parent2.name + '</a>')),
      $('<p></p>').append($('<a class="play" href="#">Play</a>')),
    ]

    $(domEls).each((idx, elt) ->
      $(listItem).append(elt)
    )

    $('#gaDNAList').append(listItem)
  )

  $('.showParent').click((e) ->
    return false
  )

  foobar = {}
  $('.play').toggle((e) ->
    foobar.afAudioContext = Object.create(AFAudioContext)
    foobar.afAudioContext.init(440)
    return false
  , ->
    foobar.afAudioContext.source.noteOff(0)
    return false
  )

  return false

  elArr = [
    [
      'generationSize',
      'genSz'
    ],
    [
      'generationCount',
      'genCnt'
    ],
    [
      'mutationPercentage',
      'mutPct'
    ],
    [ 'dnaBitCount',
      'bitCnt'
    ],
    [
      'dnaStepCount',
      'stpCnt'
    ]
  ]

  $(elArr).each((indx, elmnt) ->
    $('#' + elmnt[0]).change((e) ->
      $('#' + elmnt[1]).text(e.srcElement.value)
    )
  )

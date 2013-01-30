# Copyright 2013, Carlos Cardona v0.1.1
# Released under the MIT License.
# http://www.opensource.org/licenses/mit-license.php
#
#      ___           ___           ___           ___                                     ___           ___     
#     /\__\         /\__\         /\  \         /\__\                                   /\__\         /\__\    
#    /:/ _/_       /:/ _/_        \:\  \       /:/ _/_         ___         ___         /:/  /        /:/ _/_   
#   /:/ /\  \     /:/ /\__\        \:\  \     /:/ /\__\       /\__\       /\__\       /:/  /        /:/ /\  \  
#  /:/ /::\  \   /:/ /:/ _/_   _____\:\  \   /:/ /:/ _/_     /:/  /      /:/__/      /:/  /  ___   /:/ /::\  \ 
# /:/__\/\:\__\ /:/_/:/ /\__\ /::::::::\__\ /:/_/:/ /\__\   /:/__/      /::\  \     /:/__/  /\__\ /:/_/:/\:\__\
# \:\  \ /:/  / \:\/:/ /:/  / \:\~~\~~\/__/ \:\/:/ /:/  /  /::\  \      \/\:\  \__  \:\  \ /:/  / \:\/:/ /:/  /
#  \:\  /:/  /   \::/_/:/  /   \:\  \        \::/_/:/  /  /:/\:\  \      ~~\:\/\__\  \:\  /:/  /   \::/ /:/  / 
#   \:\/:/  /     \:\/:/  /     \:\  \        \:\/:/  /   \/__\:\  \        \::/  /   \:\/:/  /     \/_/:/  /  
#    \::/  /       \::/  /       \:\__\        \::/  /         \:\__\       /:/  /     \::/  /        /:/  /   
#     \/__/         \/__/         \/__/         \/__/           \/__/       \/__/       \/__/         \/__/    
#                    ___                   
#                   /\  \         _____    
#                  /::\  \       /::\  \   
#                 /:/\:\  \     /:/\:\  \  
#  ___     ___   /:/ /::\  \   /:/ /::\__\ 
# /\  \   /\__\ /:/_/:/\:\__\ /:/_/:/\:|__|
# \:\  \ /:/  / \:\/:/  \/__/ \:\/:/ /:/  /
#  \:\  /:/  /   \::/__/       \::/_/:/  / 
#   \:\/:/  /     \:\  \        \:\/:/  /  
#    \::/  /       \:\__\        \::/  /   
#     \/__/         \/__/         \/__/    
# ASCII art by http://patorjk.com/software/taag/

class AFGeneticsLab
  constructor : ->
    @currentGenerationCount = 1
    @validNotes = ['a', 'a#', 'b', 'c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#']
    @validOctave = [0, 1, 2, 3, 4, 5, 6, 7]

  setProperties : (properties) ->
    _.each(properties, (value, key) ->
      @[key] = value
    , @)

  generateCreatures : ->
    generation = []

    for x in [0...@generationSize]
      dnaString = ''
      for i in [0...@dnaBitCount]
        dnaString += _.random(0, (@dnaStepCount - 1))

      tmpGradeArray = @gradeDNA(dnaString)

      generation.push(new AFDNACreature({
        'name'       : (x + 1),
        'dna'        : dnaString,
        'fitness'    : tmpGradeArray[0].toString(),
        'notes'      : tmpGradeArray[1],
        'generation' : @currentGenerationCount,
        'parent1'    : 'first generation',
        'parent2'    : 'first generation'
      }))

    return generation

  gradeDNA : (dnaStrand) ->
    # right now gradeDNA is hardcoded around the notion of a 3 state dna bit.
    # This needs to be far more generic to handle a far wider range of use cases.
    soundState    = true
    toneState     = 1
    dnaBits       = dnaStrand.split('')
    fitnessScore  = 0
    currentNote   = @validNotes[@musicKey]
    currentOctave = parseInt(@octave, 10)
    noteString    = '| '
    self          = @
    indexOfNote = _.indexOf(self.validNotes, currentNote)

    $(dnaBits).each((indx, elmnt) ->
      if elmnt is 1
        toneState += 1

        if indexOfNote is 11 and indx is 0
          currentOctave += 1

        if indexOfNote is 11
          indexOfNote = -1

        currentNote = self.incrementNote(indexOfNote)
      else if elmnt is 2
        toneState -= 1
        if indexOfNote is 0
          indexOfNote = 12

        currentNote = self.decrementNote(currentNote, indexOfNote)

      indexOfNote = _.indexOf(self.validNotes, currentNote)

      if toneState is 0
        toneState = 12
        currentOctave -= 1
      else if toneState is 13
        toneState = 1
        currentOctave += 1

      if currentOctave < 0
        currentOctave = 0

      if currentOctave > 8
        currentOctave = 8

      if elmnt is '0' and soundState is true
        soundState = false
      else if elmnt is '0' and soundState is false
        soundState = true

      if soundState is true
        noteString += currentNote + currentOctave + ' | '
      else
        noteString += '- | '

      if soundState is false
        fitnessScore -=5

      if _.contains(self.scaleSteps, toneState.toString()) and soundState is true
        fitnessScore += 10
      else
        fitnessScore -= 10
    )

    return [fitnessScore, noteString];

class AFDNACreature
  constructor : (settings) ->
    @name       = settings.name
    @dna        = settings.dna
    @fitness    = settings.fitness
    @notes      = settings.notes
    @generation = settings.generation
    @parent1    = settings.parent1
    @parent2    = settings.parent2

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

    # create a generation of creatures
    generationOfCreatures = afGeneticsLab.generateCreatures()

    console.log(generationOfCreatures)
    return false
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

    return false
  )

  $('.showParent').click((e) ->
    return false
  )

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
      $('#' + elmnt[1]).text(e.currentTarget.value)
    )
  )

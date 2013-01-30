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
      if elmnt is '1'
        toneState += 1

        if indexOfNote is 11 and indx is 0
          currentOctave += 1

        if indexOfNote is 11
          indexOfNote = -1

        currentNote = self.incrementNote(indexOfNote)
      else if elmnt is '2'
        toneState -= 1
        if indexOfNote is 0
          indexOfNote = 12

        currentNote = self.decrementNote(indexOfNote)

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

  incrementNote : (indexOfNote) ->
    return @validNotes[indexOfNote + 1]

  decrementNote : (indexOfNote) ->
    return @validNotes[indexOfNote - 1]

  evolveDNA : (generation) ->
    self = @

    for itr in [0...@generationCount]
      matedDNA = []
      @currentGenerationCount++

      for itertr in [0...(@generationSize / 2)]
        sortedGeneration = generation.sort((a,b) -> return a.fitness - b.fitness)
        probabilityRange = _.range(1, @generationSize + 1)

        total = 0
        _.map(probabilityRange, (elmnt) ->
          total += elmnt
        )

        mappedArray = _.map(probabilityRange, (num) ->
          tmp = num / total
          return parseFloat(tmp.toFixed(10))
        )

        cumulativeTotal = 0
        cumulativeArray = _.map(mappedArray, (num) ->
          return cumulativeTotal += num
        )

        closestValues1 = @getClosestValues(cumulativeArray, Math.random())
        closestValues2 = @getClosestValues(cumulativeArray, Math.random())

        matedDNA.push(@mateDNA(sortedGeneration[closestValues1[0]], sortedGeneration[closestValues2[0]], itertr))

      generation = []
      $(matedDNA).each((inxx, ell) ->
        $(ell).each((innx, elmm) ->
          generation.push(elmm)
        )
      )

    return generation

  getClosestValues : (a, x) ->
    lo = 0
    hi = a.length-1
    while hi - lo > 1 
      mid = Math.round((lo + hi)/2)
      if (a[mid] <= x)
        lo = mid
      else
        hi = mid
    
    if (a[lo] == x)
      hi = lo
    return [_.indexOf(a, a[hi]), a[hi]]

  mateDNA : (parent1, parent2, itertr) ->
    dnaBreakPoint  = _.random((@dnaBitCount - 2), 2)
    
    if parent1.dna[1]?
      tmpParent1 = parent1.dna[0].innerText + parent1.dna[1].innerText
      parent1SliceA = tmpParent1.slice(0, dnaBreakPoint)
      parent1SliceB = tmpParent1.slice(dnaBreakPoint)
    
      tmpParent2 = parent2.dna[0].innerText + parent2.dna[1].innerText
      parent2SliceA = tmpParent2.slice(0, dnaBreakPoint)
      parent2SliceB = tmpParent2.slice(dnaBreakPoint)
    else
      parent1SliceA = parent1.dna[0].innerText.slice(0, dnaBreakPoint)
      parent1SliceB = parent1.dna[0].innerText.slice(dnaBreakPoint)
  
      parent2SliceA = parent2.dna[0].innerText.slice(0, dnaBreakPoint)
      parent2SliceB = parent2.dna[0].innerText.slice(dnaBreakPoint)

    parents =
      parent1SliceA : [
        'parent1DNA',
        parent1SliceA
      ],
      parent1SliceB : [
        'parent1DNA',
        parent1SliceB
      ],
      parent2SliceA : [
        'parent2DNA',
        parent2SliceA
      ],
      parent2SliceB : [
        'parent2DNA',
        parent2SliceB
      ]

    parentKeys = Object.keys(parents)

    if @mutationPercentage > 0
      mutateDNA = _.random(0, (100 / @mutationPercentage) - 1)

    if mutateDNA is 0
      parentToMutate = _.random(0, 3)
      parents[parentKeys[parentToMutate]] = @mutateDNA(parents[parentKeys[parentToMutate]][1])

    if !parents.parent1SliceA[2]?
      tmpSpanEl1A = $('<span class="parent1DNA">').append(parents.parent1SliceA)
    else
      tmpSpanEl1A = $('<span class="parent1DNA">' + parents.parent1SliceA[1] + '</span>')

    if !parents.parent1SliceB[2]?
      tmpSpanEl1B = $('<span class="parent1DNA">').append(parents.parent1SliceB)
    else
      tmpSpanEl1B = $('<span class="parent1DNA">' + parents.parent1SliceB[1] + '</span>')

    if !parents.parent2SliceA[2]?
      tmpSpanEl2A = $('<span class="parent2DNA">').append(parents.parent2SliceA)
    else
      tmpSpanEl2A = $('<span class="parent2DNA">' + parents.parent2SliceA[1] + '</span>')

    if !parents.parent2SliceB[2]?
      tmpSpanEl2B = $('<span class="parent2DNA">').append(parents.parent2SliceB)
    else
      tmpSpanEl2B = $('<span class="parent2DNA">' + parents.parent2SliceB[1] + '</span>')

    if parents['parent1SliceA'][2]?
      parent1SliceA = $(parents['parent1SliceA']).text()

    if parents['parent1SliceB'][2]?
      parent1SliceB = $(parents['parent1SliceB']).text()

    if parents['parent2SliceA'][2]?
      parent2SliceA = $(parents['parent2SliceA']).text()

    if parents['parent2SliceB'][2]?
      parent2SliceB = $(parents['parent2SliceB']).text()

    concatDNAStrands = [[parent1SliceA + parent2SliceB, $(tmpSpanEl1A).after(tmpSpanEl2B[0])], [parent2SliceA + parent1SliceB, $(tmpSpanEl2A).after(tmpSpanEl1B[0])]]

    createNewCreaturesArray = []

    self = @
    name

    $(concatDNAStrands).each((indx, elment) ->
      if indx is 0
        name = ((itertr + 1) * 2) - 1
      else
        name = ((itertr + 1) * 2)

      tmpGrade = self.gradeDNA(elment[0])
      createNewCreaturesArray.push(new AFDNACreature({
        'name'       : name,
        'dna'        : elment[1],
        'fitness'    : tmpGrade[0].toString(),
        'notes'      : tmpGrade[1],
        'generation' : self.currentGenerationCount,
        'parent1'    : parent1,
        'parent2'    : parent2
      }))
    )

    return createNewCreaturesArray

  mutateDNA : (dnaStrand) ->
    mutatedGene = _.random(0, (@dnaStepCount - 1))
    if dnaStrand.length > 1
      counter = _.random(1, (dnaStrand.length - 1))
      parentSliceA = dnaStrand.slice(0, counter)
      parentSliceB = dnaStrand.slice(counter)
      childSliceA = parentSliceA.slice(0, parentSliceA.length - 1)
      spanElmnt1 = $('<span></span>')
      spanElmnt2 = $('<span class="mutatedDNA">' + mutatedGene + '</span>')
      $(spanElmnt1).append(childSliceA)
      return $(spanElmnt1).after(spanElmnt2).after(parentSliceB)
    else
      return $('<span class="mutatedDNA">' + mutatedGene + '</span>')

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

    # Because it's the first generation wrap their dna property in a span with a class
    _.each(generationOfCreatures, (value, key) ->
      value.dna = $('<span class="root">' + value.dna + '</span>')
      value.parent1 = $('<span class="root">' + value.parent1 + '</span>')
      value.parent2 = $('<span class="root">' + value.parent2 + '</span>')
    , @)

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

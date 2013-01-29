# Copyright 2013, Carlos Cardona v0.1.1
# Released under the MIT License.
# http://www.opensource.org/licenses/mit-license.php

class AFGeneticsLab
  constructor : ->
    @currentGenerationCount = 1
    @validNotes = ['a', 'a#', 'b', 'c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#']
    @validOctave = [0, 1, 2, 3, 4, 5, 6, 7]

  generateCreatures : ->

lab = new AFGeneticsLab()
console.log lab

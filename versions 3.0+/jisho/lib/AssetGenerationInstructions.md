WHATEVER STEP YOU NEED TO REBUILD FROM, YOU NEED TO DO THE FOLLOWING STEPS AS WELL

1: information being parsed incorrectly from triepy/edict:
    run triepy/triegen.py
2: Something needs to be added to the Answer class, somewhere in the generation:
    run lib/AnswerGen.dart
3: Something needs to be updated in one of the search Tries:
    run lib/TrieGen.dart
4: AnswerMap needs to be rechunked:
    run lib/AnswerMapChunker.dart
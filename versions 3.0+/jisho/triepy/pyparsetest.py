import pyparsing # make sure you have this installed

thecontent = pyparsing.Word(pyparsing.printables,excludeChars='()')
parens     = pyparsing.nestedExpr( '(', ')', content=thecontent)
print(parens.parseString('/()'))
#!/usr/bin/env python

import string

globalvars = {}       # We will store the calculator's variables here

def lookup(map, name):
    "get variable value. map:local variables; name: variable id"
    for x,v in map:
        if x==name: return v
    if name not in globalvars.keys():
        print 'Undefined:', name
    return globalvars.get(name, 0)

class Div:
  def __init__(self, hash):
    self.name = hash['name']
    self.size = hash['size']
    self.options = hash['opts']
    if hash['children']:
      self.childtype, self.children = hash['children']

%%
# Parser section after the '%%' separator
# (comments in this section are not copied to the .py file)

parser Ultra:
    # Without this option, Yapps produces a context-sensitive
    # scanner: the parser tells the scanner what tokens it
    # expects – so, e.g., a keyword could be read in as an
    # identifier where the keyword token wasn't expected.
    # However, if a context-sensitive scanner is not needed
    # then it's probably better for debugging to have the
    # simpler context-insensitive scanner.
    option:  "context-insensitive-scanner"
    # 'ignore' really means 'treat as token separators'
    # Note all these strings are regular expressions.
    ignore:    '[ \t]+'
    ignore:    '\/\/.*?\r?\n'    # line comment
    token NEWLINE: '\r?\n'
    token UNIT: '\d+(\.\d*)?(em|ex|px|%)'
    token IDENT: '#?[a-zA-Z_]\w*'
    token PARAM: '\w+:\w+'
    # Even if it doesn't appear in the rules,
    # an END token is usually needed: otherwise, with most
    # grammars, the scanner will keep trying to read beyond
    # the end of the string.
    token END: '$'

    rule goal: goal2 END  {{ return goal2 }}

    rule goal2: node                 {{ nodes = [node] }}
                (node                {{ nodes.append(node) }})*
                                     {{ return nodes }}

    rule node:  IDENT                {{ n = {'name': IDENT} }}
                                     {{ n['size'] = 'consume' }}
                                     {{ n['opts'] = None }}
                                     {{ n['children'] = [] }}
                [size                {{ n['size'] = size }}]
                [options             {{ n['opts'] = options }}]
                [children            {{ n['children'] = children }}]
                NEWLINE              {{ return Div(n) }}

    rule size:  (UNIT                {{ s = UNIT }}
                | 'consume'          {{ s = 'consume' }})
                                     {{ return s }}

    rule options: PARAM              {{ params = [PARAM] }}
                  (PARAM             {{ params.append(PARAM) }}
                  )*                 {{ return params }}

    rule children: ('horiz{'         {{ children = ('horiz', []) }}
                    | 'vert{'        {{ children = ('vert', []) }}
                    | 'stack{'       {{ children = ('stack', []) }})
                   NEWLINE
                   [goal2            {{ children[1].extend(goal2) }}]
                   '}'               {{ return children }}

%%
# If is second '%%' separator is present then the first one
# must be too, even if there's no code before the parser.
# Anything here is copied straight to the .py file after
# the generated code.
# If this section (and the '%%') is omitted, Yapps inserts
# test code.

if __name__=='__main__':
    print 'Welcome to the calculator sample for Yapps 2.0.'
    print '  Enter either "<expression>" or "set <var> <expression>",'
    print '  or just press return to exit.  An expression can have'
    print '  local variables:  let x = expr in expr'
    # We could have put this loop into the parser, by making the
    # `goal' rule use (expr | set var expr)*, but by putting the
    # loop into Python code, we can make it interactive (i.e., enter
    # one expression, get the result, enter another expression, etc.)
    while 1:
        try: s = raw_input('>>> ')
        except EOFError: break
        if not string.strip(s): break
        print s
        divs = parse('goal', s)
        print divs
    print 'Bye.'

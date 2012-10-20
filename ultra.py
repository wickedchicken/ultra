#!/usr/bin/env python

"""A CSS grid compiler."""

import argparse
import sys
import ultra_parser

def main():
  parser = argparse.ArgumentParser(description='A CSS grid compiler.')
  parser.add_argument('input_file', metavar='file',
      help='input file (can be \'-\' for stdin)')
  options = parser.parse_args()

  if options.input_file == '-':
    input_data = sys.stdin.read()
  else:
    with open(options.input_file, 'r') as f:
      input_data = f.read()

  parse_tree = ultra_parser.parse('goal', input_data)

  if not parse_tree:
    print 'parse failure'
    return 1
  for node in parse_tree:
    print node

  return 0

if __name__=="__main__":
  sys.exit(main())

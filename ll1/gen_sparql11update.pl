
top_symbol(updateUnit).
output_file('sparql11update_table.js').

js_vars([
  defaultQueryType='"update"',
  lexVersion='"sparql11"',
  startSymbol='"update"',
  acceptEmpty=true
]).

:-reconsult(gen_ll1).
:-reconsult('sparql11grammar.pl').

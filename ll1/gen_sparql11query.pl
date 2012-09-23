
top_symbol(queryUnit).
output_file('sparql11query_table.js').

js_vars([
  defaultQueryType=null,
  lexVersion='"sparql11"',
  startSymbol='"query"',
  acceptEmpty=false
]).

:-include(gen_ll1).
:-reconsult('sparql11grammar.pl').

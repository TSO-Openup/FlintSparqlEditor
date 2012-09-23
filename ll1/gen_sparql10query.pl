
top_symbol(s).
output_file('sparql10query_table.js').

js_vars([
  defaultQueryType=null,
  lexVersion='"sparql10"',
  startSymbol='"query"',
  acceptEmpty=false
]).

:-reconsult(gen_ll1).
:-reconsult('sparql10grammar.pl').



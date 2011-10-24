:-dynamic cf/2.
:-dynamic f/2.
:-dynamic change/0.
:-dynamic m/3.
:-dynamic tm/1.
:-dynamic '==>'/2.
:-dynamic '=>'/2.
:-op(550,xfy,===>).  % Rewrite rules on EBNF expressions
:-op(500,xfy,==>).   % EBNF-style grammar rules
:-op(500,xfy,=>).    % Primitive grammar rules
:-op(490,xfy,or).
:-op(480,fy,*).
:-op(470,xfy,\).


:-reconsult('rewrite.pl').
:-reconsult('ll1.pl').
:-reconsult('sparqlgrammar.pl').
:-reconsult('output_to_javascript.pl').

output_file('sparqltable.js').

go:-
	ebnf_to_bnf,
	ll1_tables,
	ll1_check,
	output_file(Out),
	write('Writing to '),write(Out),nl,
	tell(Out),
	output_table_js,
	output_terminals_js,
	told.
	

/* Convert computed LL(1) table into javascript source
*/

output_table_js:-
	write('var ll1_table='),nl,
	setof(LHS, RHS^(LHS=>RHS), NTs),
	form_table(NTs,'{'),
	nl,write('};').

output_terminals_js:-
	nl,nl,write('var terminal=['),nl,
	tm_regex(Ks),
	member(TM,Ks),
	format('   { name: "~w", regex:new RegExp("^"+~w) }, ~n',[TM,TM]),
	fail.
output_terminals_js:-
        write('];'),nl,
	fail.
output_terminals_js:-
	tm_punct(Ps),
	findall(Reg,member(_=Reg,Ps),Regs),
	nl,nl,write('var punct=/^('),
	output_as_regex_disj(Regs,''),
	write(')/ ;'),nl,
	fail.
output_terminals_js:-
	tm_keywords(Ps),
	findall(Reg,member(Reg,Ps),Regs),
	nl,nl,write('var keywords=/^('),
	output_as_regex_disj(Regs,''),
	write(')/i ;'),nl,
	fail.
output_terminals_js.

output_as_regex_disj([],_).
output_as_regex_disj([T|Ts],Prefix):-
    format('~w~w',[Prefix,T]),
    output_as_regex_disj(Ts,'|').

form_table([],_).
form_table([NT|NTs],Punc):-
	format('~w~n  "~w" : ',[Punc,NT]),
	findall(First-RHS,m(NT,First,_=>RHS),Pairs),
	output_pairs(Pairs,'{'),
	write('}'),
	form_table(NTs,', ').

output_pairs([],_).
output_pairs([First-RHS|Pairs],Punc):-
	format('~w~n     "~w": ',[Punc,First]),
	write_list_strings(RHS),
	output_pairs(Pairs, ', ').

write_list_strings(Xs):-
	write('['),
	write_list_strings1(Xs,''),
	write(']').

write_list_strings1([],_).
write_list_strings1([X|Xs],Punc):-
	format('~w"~w"',[Punc,X]),
	write_list_strings1(Xs,',').

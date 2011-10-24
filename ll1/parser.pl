%----------------------------------------------------------------------------
% Toy parser using m/3 facts
% Useful for testing only
%
% e.g. 
%  test1:-
%	pp(['SELECT','STAR','WHERE','{','}',$]).
%----------------------------------------------------------------------------

pp(Toks):-
	s => RHS,
	parse(Toks,RHS).

parse([],[]):-
	!,
	format("Tok=[], S=[], stopping").
parse([Tok|Toks],[Tok|Stack]):-
	!,
	format("Toks=~w,~nStack=~w, consuming ~w ~n~n",
	   [Toks,Stack,Tok]),
	parse(Toks,Stack).
parse([Tok|Toks],[Nt|Stack]):-
	m(Nt,Tok,Nt=>RHS),
	!,
	format("Toks=~w,~nStack=~w, applying ~w ~n~n",
	   [[Tok|Toks],[Nt|Stack],Nt=>RHS]),
	append(RHS,Stack,Stack1),
	parse([Tok|Toks],Stack1).
parse(Toks,Stack):-
	format("Fail:~nToks=~w,~nStack=~w~n",[Toks,Stack]),
	report_error(Toks,Stack).

report_error(Toks,[Top|_]):-
	findall(Tok,m(Top,Tok,_),Possibles),
	format('Expected one of ~w, found sequence ~w',[Possibles,Toks]).

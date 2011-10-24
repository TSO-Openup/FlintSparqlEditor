
/*

Compute LL1 parse tables.

fi(NT,T) means that T can be the first terminal in NT.  The special
         token epsilon means that NT may rewrite to nothing
         (NT is "nullable").

fo(NT,T, O) means that nonterminal NT can be followed by terminal T.
            - the final argument is for debugging only, and records
              the nonterminal from which the follower T was copied.


*/


ll1_tables:-
	retractall(cf(_,_)),
	retractall(nt(_)),
	retractall(fi(_,_)),
	retractall(fo(_,_,_)),
	retractall(m(_,_,_)),
	
	validate_rules,
	remember(change),
%	assert_terminals,
	iterate_first,

	remember(change),
	iterate_follow,

	iterate_matrix.

validate_rules:-
	NT=>_,
	\+ (_=>RHS, memberchk(NT,RHS) ),
	format("Warning: unused non-terminal: ~w~n",[NT]),
	fail.
validate_rules:-
	LHS => RHS,
	\+RHS=[],
	\+RHS=[_|_],
	format("Warning: atomic RHS: ~w~n",[LHS=>RHS]),
	fail.
validate_rules:-
	_ => RHS,
	member(T,RHS),
	\+ T => _,
	remember(tm(T)),
	fail.
validate_rules:-
	tm(T),
	\+declared_terminal(T),
	format("Warning: undeclared terminal: ~w~n",[T]),
	fail.
validate_rules:-
	declared_terminal(T),
	\+tm(T),
	format("Warning: declared terminal not found in grammar: ~w~n",[T]),
	fail.
validate_rules.

declared_terminal(T):-
	tm_keywords(Ts),
	member(T,Ts).
declared_terminal(T):-
	tm_regex(Ts),
	member(T,Ts).
declared_terminal(T):-
	tm_punct(Ts),
	member(T=_,Ts).

iterate_first:-
	change,
	!,
	retractall(change),
	iterate,
	iterate_first.
iterate_first.

iterate:-
	first(A,W),
	remember(fi(A,W)),
	fail.
iterate.

assert_terminals:-
	tm(Tm),
	assertz(fi(Tm,Tm)),
	fail.
assert_terminals.
        

first(Tm,Tm):-
	tm(Tm).
first(Nonterm,F):-
        Nonterm=>RHS,
	first_list(RHS,F).

first_list([],epsilon).
first_list([W|RHS],F):-
	fi(W,epsilon),
	first_list(RHS,F).
first_list([W|_],F):-
	fi(W,F),
	F \== epsilon.


iterate_follow:-
	change,
	!,
	retractall(change),
	iterate_f,
	iterate_follow.
iterate_follow.

iterate_f:-
	follow,
	fail.
iterate_f.

/*

*/

follow:-
	B => RHS,
	follow_list(RHS,B).

follow_list([X],B):-
	copy_follow(B,X).
follow_list([A,X2|RHS],B):-
	first_list([X2|RHS],F),
	(F=epsilon -> 
	    copy_follow(B,A)
        ;
	    remember(fo(A,F, B))
        ),
	follow_list([X2|RHS],B).	

% Whatever can follow B, can follow A
%  (applied when A can be final constituent of B)
copy_follow(B,A):-
	\+tm(A),
	remember(cf(B,A)),
	fo(B,Fo, Origin),
	remember(fo(A,Fo, Origin)),
	fail.
copy_follow.

iterate_matrix:-
	A => RHS,
	first_list(RHS,F),
	F \== epsilon,
	remember(m(A,F,A=>RHS)),
	fail.
iterate_matrix:-
	A => RHS,
	first_list(RHS,epsilon),
	fo(A,F,_),
	remember(m(A,F,A=>RHS)),
	fail.
iterate_matrix.

ll1_check:-
	m(NT,T,R1),
	m(NT,T,R2),
	R1@<R2,
	format('LL(1) clash - ~w, ~w~n',[NT,T]),
	fail.
ll1_check:-
	write('LL(1) check complete.'),nl.


/*
Debugging help - 
 cf(X,Y) fact means that follow set was copied from X to Y.
 cf_trans is transitive version.  
 Can be used for debugging follow sets like this:

   If a nonterminal P has suspect terminal T in its follow set,

   Firstly, fo(P,T, O), will give annotation O, - 
   which is the nonterminal from which the follower T was inherited.

   Secondly, call cf_trans(+O,+P, +[], -Path)
   will find a path between the O and P -
     then check that P really can be last thing in O via the path,
     - should lead to discovery of suspect rule.
*/

cf_trans(X,Y,V,V):-
	cf(X,Y).
cf_trans(X,Z,V0,V1):-
	cf(Y,Z),
	\+memberchk(Y,V0),
	cf_trans(X,Y,[Y|V0],V1).

tail(X,X).
tail([_|Xs0],Xs1):-
	tail(Xs0,Xs1).

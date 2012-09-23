
/*

SPARQL 1.0 grammar rules based on the ones here:
  http://www.w3.org/TR/rdf-sparql-query/

Be careful with grammar notation - it's EBNF in prolog syntax!

[...] lists always represent sequence.
or can be used as binary operator or nary prefix term - don't put [...] inside
   unless you want sequence as a single disjunct.

*, +, ? - generally used as 1-ary terms 

*/

s ==> [query,$].

query ==> 
	[prologue,or(selectQuery,constructQuery,describeQuery,askQuery)].

prologue ==> 
	[?(baseDecl),*(prefixDecl)].

baseDecl ==> 
	['BASE','IRI_REF'].

prefixDecl ==> 
	['PREFIX','PNAME_NS','IRI_REF'].

selectQuery ==> 
	['SELECT',
	?('DISTINCT' or 'REDUCED'),
	(+(var) or '*'),
	*(datasetClause),whereClause,solutionModifier].

constructQuery ==> 
	['CONSTRUCT',constructTemplate,
	*(datasetClause),whereClause,solutionModifier].

describeQuery ==> 
	['DESCRIBE',+(varOrIRIref) or '*',
	*(describeDatasetClause),?(whereClause),solutionModifier].

askQuery ==>
	['ASK',*(datasetClause),whereClause,solutionModifier].

datasetClause ==> 
	['FROM',defaultGraphClause or namedGraphClause]. 
describeDatasetClause ==> 
	['FROM',defaultGraphClause or namedGraphClause]. 


defaultGraphClause ==> 
	[sourceSelector].

namedGraphClause ==> 
	['NAMED',sourceSelector].

sourceSelector ==> 
	[iriRef].

whereClause ==> 
	[?('WHERE'),groupGraphPattern].

solutionModifier ==> 
	[?(orderClause),?(limitOffsetClauses)].

limitOffsetClauses ==> 
	[limitClause, ?(offsetClause)].
limitOffsetClauses ==> 
	[offsetClause, ?(limitClause)].

orderClause ==> 
	['ORDER','BY',+(orderCondition)].

orderCondition ==> 
	['ASC' or 'DESC',brackettedExpression].
orderCondition ==> 
	[constraint].
orderCondition ==> 
	[var].

limitClause ==> 
	['LIMIT','INTEGER'].

offsetClause ==> 
	['OFFSET','INTEGER'].

groupGraphPattern ==> [
        '{',
        ?(triplesBlock),
	*([graphPatternNotTriples or filter, ?('.'), ?(triplesBlock)]),
	'}'].

triplesBlock ==> 
	[triplesSameSubject,?(['.',?(triplesBlock)])].

graphPatternNotTriples ==> [optionalGraphPattern].
graphPatternNotTriples ==> [groupOrUnionGraphPattern].
graphPatternNotTriples ==> [graphGraphPattern].

optionalGraphPattern ==> 
	['OPTIONAL',groupGraphPattern].
graphGraphPattern ==> 
	['GRAPH',varOrIRIref,groupGraphPattern].
groupOrUnionGraphPattern ==> 
	[groupGraphPattern,*(['UNION',groupGraphPattern])].
filter ==> 
	['FILTER',constraint].
constraint ==> 
	[brackettedExpression].
constraint ==> 
	[builtInCall].
constraint ==> 
	[functionCall].
functionCall ==> 
	[iriRef,argList].
argList ==> 
	['NIL'].
argList ==> 
	['(',expression,*([',',expression]),')'].
constructTemplate ==>
	['{',?(constructTriples),'}'].
constructTriples ==>
	[triplesSameSubject,?(['.',?(constructTriples)])].

triplesSameSubject ==>
	[varOrTerm,propertyListNotEmpty].
triplesSameSubject ==>
	[triplesNode,propertyList].

propertyListNotEmpty ==> 
	[verb,objectList,*([';',?([verb,objectList])])].
propertyList ==> 
	[?(propertyListNotEmpty)].
objectList ==> 
	[object,*([',',object])].
object ==> 
	[graphNode].
verb ==> 
	[storeProperty,varOrIRIref].
verb ==> [storeProperty,'a'].
storeProperty ==> [].
triplesNode ==> [collection].
triplesNode ==> 
	[blankNodePropertyList].
blankNodePropertyList ==> 
	['[',propertyListNotEmpty,']'].
collection ==> 
	['(',+(graphNode),')'].
graphNode ==> [varOrTerm].
graphNode ==> [triplesNode].
varOrTerm ==> [var].
varOrTerm ==> [graphTerm].
varOrIRIref ==> [var].
varOrIRIref ==> [iriRef].
var ==> ['VAR1'].
var ==> ['VAR2'].
graphTerm ==> [iriRef].
graphTerm ==> [rdfLiteral].
graphTerm ==> [numericLiteral].
graphTerm ==> [booleanLiteral].
graphTerm ==> [blankNode].
graphTerm ==> ['NIL'].
expression ==> 
	[conditionalOrExpression].
conditionalOrExpression ==> 
	[conditionalAndExpression,*(['||',conditionalAndExpression])].
conditionalAndExpression ==>
	[valueLogical,*(['&&',valueLogical])].
valueLogical ==>
	[relationalExpression].
relationalExpression ==>
	[numericExpression,
	?(or( ['=',numericExpression], 
	      ['!=',numericExpression],
	      ['<',numericExpression],
	      ['>',numericExpression],
	      ['<=',numericExpression],
	      ['>=',numericExpression]
	    ))].
numericExpression ==>
	[additiveExpression].
additiveExpression ==>
	[multiplicativeExpression,
	*(or( ['+',multiplicativeExpression],
	      ['-',multiplicativeExpression],
	      numericLiteralPositive,
	      numericLiteralNegative ))
    ].
multiplicativeExpression ==>
	[unaryExpression,
	  *( ['*',unaryExpression] 
            or 
             ['/',unaryExpression] )].
unaryExpression ==>
	[or( ['!',primaryExpression],
	     ['+',primaryExpression],
	     ['-',primaryExpression],
	     primaryExpression ) ].

primaryExpression ==> [brackettedExpression].
primaryExpression ==> [builtInCall].
primaryExpression ==> [iriRefOrFunction].
primaryExpression ==> [rdfLiteral].
primaryExpression ==> [numericLiteral].
primaryExpression ==> [booleanLiteral].
primaryExpression ==> [var].

brackettedExpression ==> ['(',expression,')'].

builtInCall ==> ['STR','(',expression,')'].
builtInCall ==> ['LANG','(',expression,')'].
builtInCall ==> ['LANGMATCHES','(',expression,',',expression,')'].
builtInCall ==> ['DATATYPE','(',expression,')'].
builtInCall ==> ['BOUND','(',var,')'].
builtInCall ==> ['SAMETERM','(',expression,',',expression,')'].
builtInCall ==> ['ISIRI','(',expression,')'].
builtInCall ==> ['ISURI','(',expression,')'].
builtInCall ==> ['ISBLANK','(',expression,')'].
builtInCall ==> ['ISLITERAL','(',expression,')'].
builtInCall ==> [regexExpression].

regexExpression ==> 
	['REGEX','(',expression,',',expression,
	?([',',expression]),')'].
iriRefOrFunction ==> [iriRef,?(argList)].
rdfLiteral ==> [string,?('LANGTAG' or ['^^',iriRef])].

numericLiteral ==> [numericLiteralUnsigned].
numericLiteral ==> [numericLiteralPositive].
numericLiteral ==> [numericLiteralNegative].

numericLiteralUnsigned ==> ['INTEGER'].
numericLiteralUnsigned ==> ['DECIMAL'].
numericLiteralUnsigned ==> ['DOUBLE'].

numericLiteralPositive ==> ['INTEGER_POSITIVE'].
numericLiteralPositive ==> ['DECIMAL_POSITIVE'].
numericLiteralPositive ==> ['DOUBLE_POSITIVE'].

numericLiteralNegative ==> ['INTEGER_NEGATIVE'].
numericLiteralNegative ==> ['DECIMAL_NEGATIVE'].
numericLiteralNegative ==> ['DOUBLE_NEGATIVE'].

booleanLiteral ==> ['TRUE'].
booleanLiteral ==> ['FALSE'].
string ==> ['STRING_LITERAL1'].
string ==> ['STRING_LITERAL2'].
string ==> ['STRING_LITERAL_LONG1'].
string ==> ['STRING_LITERAL_LONG2'].
iriRef ==> ['IRI_REF'].
iriRef ==> [prefixedName].
prefixedName ==> ['PNAME_LN'].
prefixedName ==> ['PNAME_NS'].
blankNode ==> ['BLANK_NODE_LABEL'].
blankNode ==> ['ANON'].


% tokens defined by regular expressions elsewhere
tm_regex([

'IRI_REF',

'VAR1',
'VAR2',
'LANGTAG',

'DOUBLE',
'DECIMAL',
'INTEGER',
'DOUBLE_POSITIVE',
'DECIMAL_POSITIVE',
'INTEGER_POSITIVE',
'INTEGER_NEGATIVE',
'DECIMAL_NEGATIVE',
'DOUBLE_NEGATIVE',

'STRING_LITERAL_LONG1',
'STRING_LITERAL_LONG2',
'STRING_LITERAL1',
'STRING_LITERAL2',

'NIL',
'ANON',
'PNAME_LN',
'PNAME_NS',
'BLANK_NODE_LABEL'
]).

% Terminals where name of terminal is uppercased token content
tm_keywords([
'BASE',
'PREFIX',
'SELECT',
'CONSTRUCT',
'DESCRIBE',
'ASK',
'FROM',
'NAMED',
'ORDER',
'BY',
'LIMIT',
'ASC',
'DESC',
'OFFSET',
'DISTINCT',
'REDUCED',
'WHERE',
'GRAPH',
'OPTIONAL',
'UNION',
'FILTER',

'STR',
'LANGMATCHES',
'LANG',
'DATATYPE',
'BOUND',
'SAMETERM',
'ISIRI',
'ISURI',
'ISBLANK',
'ISLITERAL',
'REGEX',
'TRUE',
'FALSE'
]).

% Other tokens representing fixed, case sensitive, strings
% Care! order longer tokens first - e.g. IRI_REF, <=, <
% e.g. >=, >
% e.g. NIL, '('
% e.g. ANON, [
% e.g. DOUBLE, DECIMAL, INTEGER
% e.g. INTEGER_POSITIVE, PLUS
tm_punct([
'*'= '\\*',
'a'= 'a',
'.'= '\\.',
'{'= '\\{',
'}'= '\\}',
','= ',',
'('= '\\(',
')'= '\\)',
';'= ';',
'['= '\\[',
']'= '\\]',
'||'= '\\|\\|',
'&&'= '&&',
'='= '=',
'!='= '!=',
'!'= '!',
'<='= '<=',
'>='= '>=',
'<'= '<',
'>'= '>',
'+'= '\\+',
'-'= '-',
'/'= '\\/',
'^^'= '\\^\\^'
]).

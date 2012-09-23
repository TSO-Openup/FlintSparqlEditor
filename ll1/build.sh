#!/bin/bash
#pl=/usr/bin/pl
pl=/bin/swipl

$pl -s gen_sparql10query.pl -t go
sed < template.js 's/%%%modename%%%/sparql10/' | sed -e '/%%%table%%%/r sparql10query_table.js' > ../sparql/sparql10querymode_ll1.js

$pl -s gen_sparql11query.pl -t go
sed < template.js 's/%%%modename%%%/sparql11query/' | sed -e '/%%%table%%%/r sparql11query_table.js' > ../sparql/sparql11querymode_ll1.js

$pl -s gen_sparql11update.pl -t go
sed < template.js 's/%%%modename%%%/sparql11update/' | sed -e '/%%%table%%%/r sparql11update_table.js' > ../sparql/sparql11updatemode_ll1.js

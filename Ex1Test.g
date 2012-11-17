grammar Ex1Test;

options {
  language=JavaScript;
// removing k means k=*
}

prog: statement* EOF;

statement: ID '=' value ';' { 
             console.debug("Assign: "+$ID.text+" = "+$value.text); 
           }
         | ID 'function' '(' argumentList? ')' '{' '...' '}' ';' { 
             console.debug("Function: "+$ID.text); 
           }
         | ID 'function' '(' argumentList? ')' ';' {
             console.debug("ForwardDecl: "+$ID.text); 
           }
         ;


argumentList: ID (',' ID)*;
value: INTEGER|STRING;



ID: CHAR (CHAR|'0'..'9')*;
INTEGER: '0'..'9'+;
STRING: '"' (.)* '"';
WS: (' '|'\t'|'\r'|'\n') { this.skip(); };

fragment CHAR: 'a'..'z'|'A'..'Z';




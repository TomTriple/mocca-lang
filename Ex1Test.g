grammar Ex1Test;

options {
  language=JavaScript;
  k=4;
}

prog: statement* EOF;

statement: 'var' ID '=' value ';' { 
             console.debug("Assign: "+$ID.text+" = "+$value.text); 
           }
         | 'var' ID '=' 'function' '()' '{' '...' '}' ';' { 
             console.debug("Function: "+$ID.text); 
           }
         ;

value: INTEGER|STRING;



ID: CHAR (CHAR|'0'..'9')*;
INTEGER: '0'..'9'+;
STRING: '"' (.)* '"';
WS: (' '|'\t'|'\r'|'\n') { this.skip(); };

fragment CHAR: 'a'..'z'|'A'..'Z';




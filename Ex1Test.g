grammar Ex1Test;

options {
  language=JavaScript;
// removing k means k=*
}

@members {

  this.symtabVariables = {};
  this.symtabFunctions = {};

}

prog: statement* EOF;

statement: ID '=' value ';' { 
             this.symtabVariables[$ID.text] = $value.text;
             console.debug("AssignmentValue: "+$ID.text+" = "+$value.text); 
           }
         | ID 'function' '(' argumentList? ')' '{' '...' '}' ';' { 
             this.symtabFunctions[$ID.text] = "--- missing function body ---";
             console.debug("Function: "+$ID.text+" with args:"+$argumentList.text);
           }
         | ID 'function' '(' argumentList? ')' ';' {
             console.debug("ForwardDecl: "+$ID.text+" with args:"+$argumentList.text);
           }
         | {this.symtabVariables[this.input.LT(3).getText()] !== undefined}? lval=ID '=' rval=ID ';' {
             console.debug("AssignmentVar: "+$rval.text+" to "+$lval.text);
           }
         | {this.symtabVariables[this.input.LT(3).getText()] === undefined}? lval=ID '=' rval=ID ';' {
             console.debug("AssignmentFunction: "+$rval.text+" to "+$lval.text);
           }
         ;


argumentList: ID (',' ID)*;
value: INTEGER|STRING;



ID: CHAR (CHAR|'0'..'9')*;
INTEGER: '0'..'9'+;
STRING: '"' (.)* '"';
WS: (' '|'\t'|'\r'|'\n') { this.skip(); };

fragment CHAR: 'a'..'z'|'A'..'Z';




tree grammar ASTWalker;


options {
  language=JavaScript;
  tokenVocab=ASTBuildingTurtle;
  ASTLabelType=CommonTree;
}

@members {


  // symbol table mapping from prefix to iri
  this.symtabPrefixes = {};
  this.currentBase = undefined;
  this.subjectLists = [];
  this.anonLabelCounter = 1;


  this.each = function(fn) {
    for(var i = 0; i < this.subjectLists.length; i++) {
      var subject = this.subjectLists[i].subject;
      var plist = this.subjectLists[i].predicateList;
      for(var j = 0; j < plist.length; j++) {
        var predicate = plist[j].predicate;
        var olist = plist[j].objectList;
        for(var k = 0; k < olist.length; k++) {
          fn(subject, predicate, olist[k]);
        }
      }
    }
  }


  this.toString = function() {
    var str = "";
    this.each(function(s, p, o) {
      str += s+" "+p+" "+o;
    });
    return str;
  }

  this.generateID = function() {
    return this.anonLabelCounter++;
  }


}

turtleDoc
   : statement*
   ;

statement
   : directive
   | triples {
     this.subjectLists.push($triples.value);
   }
   ;

directive
   : prefixID
   | base
   ;

prefixID
   : ^(PREFIX PNAME_NS IRIREF) {
       var key = $PNAME_NS.text, value = $IRIREF.text;
       value = value.substr(1);
       value = value.substr(0, value.length - 1)
       this.symtabPrefixes[key] = value;
     }
   ;

base
   : ^(BASE IRIREF) {
       var base = $IRIREF.text;
       base = base.substr(1);
       base = base.substr(0, base.length - 1);
       this.currentBase = base;
     }
   ;

// erzeugung wird ueber value nach unten propagiert - kucken wie FJS das in seinem 
// beschrieben hat. dieses vorgehen ist typisch fuer syntaxgerichtete uebersetzung
triples returns [value]
@init { var predicateList = []; }
    : ^(DEF_TRIPLES subject plist=predicateObjectList[predicateList]+) {
        var val = {
          subject: $subject.value,
          predicateList: $plist.value
        };
        $value = val;
      }
    | ^(DEF_TRIPLES bnplList=blankNodePropertyList plist=predicateObjectList[predicateList]?) {
        var val = {
          subject: "_:genid"+this.generateID(),
          predicateList: $bnplList.value
        };
        val.predicateList = val.predicateList.concat($plist.value);
        $value = val;
      }
    ;

subject returns [value]
   : iri {
       $value = $iri.value;
     }
   | blank {
       $value = $blank.value;
     }
   ;


// checken - vgl mit parser grammar
predicateObjectList[predicateList] returns [value]
@init { var objectList = []; }
   : ^(verb  olist=objectList[objectList]+) {
       var val = {
         predicate: $verb.value,
         objectList: $olist.value
       }
       predicateList.push(val);
       $value = predicateList;
     }
   ;

verb returns [value]
  : predicate {
    $value = $predicate.value;
  }
  | A {
    $value = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";
  }
  ;

predicate returns [value]
 : iri { $value = $iri.value; }
 ;

// checken - vgl mit parser grammar
objectList[objectList] returns [value]
 : object {
     objectList.push($object.value);
     $value = objectList;
   }
 ;

object returns [value]
 : iri { $value = $iri.value; }
 | literal { $value = $literal.value; }
 | plist=blankNodePropertyList {
     var triple = {
       subject: "_:genid"+this.generateID(), 
       predicateList: $plist.value
     };
     this.subjectLists.push(triple);
     $value = triple.subject;
   }
 | blank { $value = $blank.value; }
 ;

blank returns [value]
 : blankNode { $value = $blankNode.value; }
 | collection
 ;

// checken - DEF_COLLECITON eingefuehrt, um linksrekursion in {object,blank,collection} 
// zu entfernen - das leuchtet ein
collection
   : ^(DEF_COLLECTION object+)
   ;


blankNode returns [value]
   : BLANK_NODE_LABEL { $value = $BLANK_NODE_LABEL.text; }
   | DEF_EMPTY_BLANK {
       $value = "_:genid"+this.generateID();
     }
   ;

// checken - DEF_BNPL eingefuert, um mehrdeutigkeit zu entfernen 
// beim testen gibts diesen AST - 
// (DEF_TRIPLES <#spidy> (foaf:knows <#goblin> (DEF_BNPL (foaf:name 'uncle bob' 'bobby'))) (rel:name 'peter parker' 'spidey')) 

// wieso wuerde das nicht gehen ohne DEF_BNPL?
blankNodePropertyList returns [value]
@init { var predicateList = []; }
   : ^(DEF_BNPL plist=predicateObjectList[predicateList]+) { $value = $plist.value; }
   ;

literal returns [value]
   : rdfLiteral { $value = $rdfLiteral.value; }
   | numericLiteral { $value = $numericLiteral.text; }
   | booleanLiteral { $value = $booleanLiteral.text; }
   ;

booleanLiteral
   : TRUE
   | FALSE
   ;

numericLiteral
   : INTEGER
   | DECIMAL
   | DOUBLE
   ;

rdfLiteral returns [value]
   : ^(string { $value = $string.value; } (LANGTAG { $value += $LANGTAG.text; } |EYES iri { $value += $iri.value; } )?)
   ;

string returns [value]
   : s=STRING_LITERAL_QUOTE { $value = $s.text; }
   | s=STRING_LITERAL_SINGLE_QUOTE { $value = $s.text; }
   | s=STRING_LITERAL_LONG_SINGLE_QUOTE { $value = $s.text }
   | s=STRING_LITERAL_LONG_QUOTE { $value = $s.text }
   ;

iri returns [value]
   : IRIREF { $value = $IRIREF.text; }
   | prefixedName { $value = $prefixedName.value; }
   ;

prefixedName returns [value]
   : PNAME_LN {
       var pref = $PNAME_LN.text, first = pref.charAt(0), result = "";
       if(first === ':') {
         result = this.symtabPrefixes[first] + pref.substr(1);
       } else {
         var ix = pref.indexOf(':'), prefix = pref.substring(0, ix+1), local = pref.substr(ix + 1);
         result = this.symtabPrefixes[prefix] + local;
       }
       $value = "<" + result + ">";
     }
   | PNAME_NS {
       $value = $PNAME_NS.text;
     }
   ;



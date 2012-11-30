tree grammar Ex1Walker;

options {
  language=JavaScript;
  tokenVocab=Ex1Test;
  ASTLabelType=CommonTree;
}

@members {

  this.Scope = function(name, enclosingScope) {
    this.name = name;
    this.enclosingScope = enclosingScope;
    this.symbols = {};
  };
  this.Scope.prototype.getScopeName = function() {
    return this.name;
  };
  this.Scope.prototype.getEnclosingScope = function() {
    return this.enclosingScope;
  };
  this.Scope.prototype.define = function(symbol) {
    this.symbols[symbol.id] = symbol;
  };
  this.Scope.prototype.resolve = function(id) {
    var lookup = this.symbols[id];
    if(lookup !== undefined)
      return lookup;
    else if(this.getEnclosingScope() !== undefined)
      return this.getEnclosingScope().resolve(id);
    else
      return undefined;
  };


  this.NodeRoot = function() {
    this.nodes = [];
    this.interpret = function() {
      this.nodes.forEach(function(node) {
          node.interpret();
      });
    }
  };
  this.NodeDefVar = function(scope, id, value) {
    this.id = id;
    this.value = value;
    this.scope = scope;
    this.interpret = function() {
      this.scope.define({id: id, value: value, category: "literal"});
    };
  };
  this.NodePuts = function(scope, id) {
    this.interpret = function() {
      var ix = id.indexOf(".");
      if(ix !== -1) {
        var structName = id.substr(0, ix);
        var struct = scope.resolve(structName);
        var accessName = id.substr(ix+1);
        console.debug(struct.access(accessName));
      } else {
        console.debug(scope.resolve(id).value);
      }
    };
  };
  this.NodeFnDef = function(fnScope, id) {
    this.id = id;
    this.fnScope = fnScope;
    this.code = [];
    this.interpret = function() {
      this.fnScope.getEnclosingScope().define({
        id: this.id, 
        category: "fn",
        code: this.code
      });
    };
  };

  this.NodeCall = function(scope, id) {
    this.scope = scope;
    this.id = id;
    this.interpret = function() {
      var code = this.scope.resolve(id).code;
      code.forEach(function(stmt) {
        stmt.interpret();
      });
    };
  };

  this.NodeIf = function(expr) {
    this.expr = expr;
    this.body = [];
    this.interpret = function(){
      if(this.expr.interpret()) {
        this.body.forEach(function(stmt) {
          stmt.interpret();
        });
      }
    };
  };

  this.NodeExpr = function(e1, e2) {
    this.e1 = e1;
    this.e2 = e2;
    this.interpret = function() {
      return e1 === e2;
    };
  };

var that = this;
  this.NodeStruct = function(scope, id) {
    this.id = id;
    this.fields = {};
    this.structScope = new that.Scope("struct", undefined);
    this.scope = scope;
    this.interpret = function() {
      var that = this;
      this.scope.define({
        id: that.id,
        category: "struct",
        access: function(fieldName) {
          return that.fields[fieldName].value;
        }
      });
      for(var prop in this.fields) {
        this.fields[prop].interpret();
      }
    };
    this.addField = function(varDefNode) {
      this.fields[varDefNode.id] = varDefNode;
    };
  };

  this.pushScope = function() {
    var scope = new this.Scope("function", this.currentScope);
    this.currentScope = scope;
  };

  this.popScope = function(){
    this.currentScope = this.currentScope.getEnclosingScope();
  };

  this.currentScope = new this.Scope("global", undefined);
}




prog returns [node]
@init { this.root = new this.NodeRoot(); }
     : (s=statement { this.root.nodes.push($s.node); })* {
         $node = this.root;
       }
     ;

statement returns [node]
         : ^(DEF_VAR ID atom) {
             $node = new this.NodeDefVar(this.currentScope, $ID.text, $atom.text);
           }
         | ^(DEF_FUNC ID { this.pushScope(); var fn = new this.NodeFnDef(this.currentScope, $ID.text); }  (s=statement { fn.code.push($s.node); })+) {
             $node = fn;
             this.popScope();
           }
         | ^(PUTS val=(INTEGER|STRING)) {
             
           }
         | ^(PUTS ID) {
             $node = new this.NodePuts(this.currentScope, $ID.text);
           }
         | ^(DEF_CALL ID) {
             $node = new this.NodeCall(this.currentScope, $ID.text);
           }
         | ^(IF e=expression { this.pushScope(); var ifNode = new this.NodeIf($e.node); } (s=statement { ifNode.body.push($s.node); })+) {
             $node = ifNode;
             this.popScope();
           }
         | ^(DEF_STRUCT ID { var struct = new this.NodeStruct(this.currentScope, $ID.text); var oldScope = this.currentScope; this.currentScope = struct.structScope; } (f=field { struct.addField($f.node); })+) {
             $node = struct;
             this.currentScope = oldScope;
           }
         ;

field returns [node]
     : ^(DEF_VAR ID atom) {
         $node = new this.NodeDefVar(this.currentScope, $ID.text, $atom.text);
       }
     ;

atom: (INTEGER|STRING|BOOLEAN) ;

expression returns [node]
       : ^('==' e1=INTEGER e2=INTEGER) {
           $node = new this.NodeExpr($e1.text, $e2.text);
         }
       ;



tree grammar Ex1Walker;

options {
  language=JavaScript;
  tokenVocab=Ex1Test;
  ASTLabelType=CommonTree;
}

@members {

  L = {};

  L.Scope = function(name, enclosingScope) {
    this.name = name;
    this.enclosingScope = enclosingScope;
    this.symbols = {};
  };

  L.Scope.prototype.getScopeName = function() {
    return this.name;
  };
  L.Scope.prototype.getEnclosingScope = function() {
    return this.enclosingScope;
  };
  L.Scope.prototype.define = function(symbol) {
    this.symbols[symbol.id] = symbol;
  };
  L.Scope.prototype.resolve = function(id) {
    var lookup = this.symbols[id];
    if(lookup !== undefined)
      return lookup;
    else if(this.getEnclosingScope() !== undefined)
      return this.getEnclosingScope().resolve(id);
    else
      return undefined;
  };



  L.Root = function() {
    this.nodes = [];
    this.interpret = function() {
      this.nodes.forEach(function(node) {
          node.interpret();
      });
    }
  };

  L.Assignment = function(scope, id, node) {
    this.scope = scope;
    this.id = id;
    this.node = node;
    this.interpret = function() {
      var value = this.node.interpret();
      var sym = new L.SymVar(this.id, value);
      this.scope.define(sym);
      return value;
    };
  };

  L.Add = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() + b.toInt(), L.T.INT);
        return result;
      }
      throw new Error("<Add: Numeric operands expected. State: a="+a+", b="+b+">");
    };
  };

  L.Mult = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() * b.toInt(), L.T.INT);
        return result;
      }
      throw new Error("<Mult: Numeric operands expected. State: a="+a+", b="+b+">");
    };
  };

  L.Literal = function(value) {
    this.value = value;
    this.interpret = function() {
        return this.value;
    };
  };

  L.Lookup = function(scope, id) {
    this.scope = scope;
    this.id = id;
    this.interpret = function() {
      var symbol = this.scope.resolve(this.id);
      if(symbol !== undefined) {
        return symbol.value;
      }
      throw new Error("<Lookup: invalid ID, "+this.id+">");
    };
  };

  L.T = { INT: 1, FN: 2, BOOLEAN: 3 };
  L.Value = function(data, type) {
    this.data = data;
    this.type = type;
    this.toInt = function() {
      if(this.type === L.T.INT)
        return parseInt(this.data);
      throw new Error("Value: INT expected");
    };
    this.isInt = function() {
      return this.type === L.T.INT;
    };
    this.toBoolean = function() {
      if(this.type === L.T.BOOLEAN) {
        return this.data === "T" ? true : false;
      }
    };
    this.isBoolean = function() {
      return this.type === L.T.BOOLEAN;
    };
    this.toString = function() {
      return "<type: "+this.typeString()+", data: "+this.data+">"
    };
    this.typeString = function() {
      for(var prop in L.T) {
        if(L.T[prop] === this.type)
          return prop;
      }
    };
  };

  L.SymVar = function(id, value) {
    this.id = id;
    this.value = value;
  };

  this.currentScope = new L.Scope("global", undefined);

}


prog returns [node]
@init { var root = new L.Root(); }
@after { $node = root; }
    : (e=exprStmt {root.nodes.push($e.node);})*
    ;

exprStmt returns [node]
        : ^(':' ID expr) {
            $node = new L.Assignment(this.currentScope, $ID.text, $expr.node);
          }
        | ^(':' ID BOOLEAN) {
            var node = new L.Literal(new L.Value($BOOLEAN.text, L.T.BOOLEAN));
            $node = new L.Assignment(this.currentScope, $ID.text, node);
          }
        ;

expr returns [node]
    : ^('+' a=expr b=expr) { $node = new L.Add($a.node, $b.node); }
    | ^('*' a=expr b=expr) { $node = new L.Mult($a.node, $b.node); }
    | i=INTEGER { 
        var valueInt = new L.Value($i.text, L.T.INT);
        $node = new L.Literal(valueInt);
      }
    | i=ID {
        var node = new L.Lookup(this.currentScope, $i.text);
        $node = node;
      }
    ;






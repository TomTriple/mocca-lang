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

  L.Sub = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() - b.toInt(), L.T.INT);
        return result;
      }
      throw new Error("<Sub: Numeric operands expected. State: a="+a+", b="+b+">");
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

  L.Divide = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() / b.toInt(), L.T.INT);
        return result;
      }
      throw new Error("<Divide: Numeric operands expected. State: a="+a+", b="+b+">");
    };
  };

  L.Eq = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() === b.toInt(), L.T.BOOLEAN);
        return result;
      } else if(a.isBoolean() && b.isBoolean()) {
        var result = new L.Value(a.toBoolean() === b.toBoolean(), L.T.BOOLEAN);
        return result;
      }
      throw new Error("<Eq: State: a="+a+", b="+b+">");
    };
  };

  L.Neq = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() !== b.toInt(), L.T.BOOLEAN);
        return result;
      } else if(a.isBoolean() && b.isBoolean()) {
        var result = new L.Value(a.toBoolean() !== b.toBoolean(), L.T.BOOLEAN);
        return result;
      }
      throw new Error("<Neq: State: a="+a+", b="+b+">");
    };
  };

  L.Gt = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() > b.toInt(), L.T.BOOLEAN);
        return result;
      } 
      throw new Error("<Gt: State: a="+a+", b="+b+">");
    };
  };

  L.Lt = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() < b.toInt(), L.T.BOOLEAN);
        return result;
      } 
      throw new Error("<Lt: State: a="+a+", b="+b+">");
    };
  };

  L.Gte = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() >= b.toInt(), L.T.BOOLEAN);
        return result;
      } 
      throw new Error("<Gte: State: a="+a+", b="+b+">");
    };
  };

  L.Lte = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isInt() && b.isInt()) {
        var result = new L.Value(a.toInt() <= b.toInt(), L.T.BOOLEAN);
        return result;
      } 
      throw new Error("<Lte: State: a="+a+", b="+b+">");
    };
  };

  L.And = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isBoolean() && b.isBoolean()) {
        var result = new L.Value(a.toBoolean() && b.toBoolean(), L.T.BOOLEAN);
        return result;
      } 
      throw new Error("<And: State: a="+a+", b="+b+">");
    };
  };

  L.Or = function(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
    this.interpret = function() {
      var a = node1.interpret();
      var b = node2.interpret();
      if(a.isBoolean() && b.isBoolean()) {
        var result = new L.Value(a.toBoolean() || b.toBoolean(), L.T.BOOLEAN);
        return result;
      } 
      throw new Error("<Or: State: a="+a+", b="+b+">");
    };
  };

  L.Negate = function(node1) {
    this.node1 = node1;
    this.interpret = function() {
      var a = node1.interpret();
      if(a.isBoolean()) {
        var result = new L.Value(!(a.toBoolean()), L.T.BOOLEAN);
        return result;
      } 
      throw new Error("<Negate: State: a="+a+">");
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

  L.FunctionDef = function(scope, id, localScope) {
    this.scope = scope;
    this.id = id;
    this.args = [];
    this.body = [];
    this.localScope = localScope;
    this.interpret = function() {
      var that = this;
      var sym = new L.SymVar(this.id, new L.Value({
        args: this.args,
        invoke: function(actualArgs) {
          for(var i = 0; i < actualArgs.length; i++) {
            that.localScope.define(new L.SymVar(that.args[i], actualArgs[i]));
          }
          var last;
          for(i = 0; i < that.body.length; i++) {
            var stmt = that.body[i];
            last = stmt.interpret();
          }
          return last;
        }
      }, L.T.FN));
      this.scope.define(sym);
      return sym.value;
    };
  };

  L.FunctionCall = function(scope, id) {
    this.scope = scope;
    this.id = id;
    this.args = [];
    this.addArgument = function(arg) {
      this.args.push(arg);
    };
    this.interpret = function(){
      var argumentsValues = [];
      this.args.forEach(function(arg) {
        argumentsValues.push(arg.interpret());
      });
      var sym = this.scope.resolve(id);
      if(sym !== undefined && sym.value.isFunction()) {
        var fn = sym.value.toFunction();
        if(this.args.length === fn.args.length) {
          return fn.invoke(argumentsValues);
        } else {
          throw new Error("<FunctionCall: length of formal arguments != actual arguments>");
        }
      } else {
        throw new Error("<FunctionCall: fn "+this.id+" is undefined or not a function>");
      }
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
        return this.data;
      }
    };
    this.isBoolean = function() {
      return this.type === L.T.BOOLEAN;
    };
    this.toString = function() {
      if(this.isBoolean())
        return (this.toBoolean() ? "T" : "F") + " ("+this.typeString()+")";
      return this.data+ " ("+this.typeString()+")";
    };
    this.isFunction = function() {
      return this.type === L.T.FN;
    };
    this.toFunction = function(){
      if(this.type === L.T.FN)
        return this.data;
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

  L.GlobalScope = function(){

    L.Scope.call(this, "global", undefined);
    this.define(new L.SymVar("puts", new L.Value({
        args: [1],
        invoke: function(args) {
          var arg = args[0];
          console.debug(arg.toString());
        }
      }, L.T.FN)
    ));
    this.define(new L.SymVar("assert", new L.Value({
        args: [1],
        invoke: function(args) {
          var arg = args[0];
          if(!arg.toBoolean() === true)
            throw new Error("AssertionError");
        }
      }, L.T.FN)
    ));

  };
  L.GlobalScope.prototype = L.Scope.prototype;
  this.currentScope = new L.GlobalScope();
  this.oldScope;
  this.pushScope = function() {
    this.oldScope = this.currentScope;
    this.currentScope = new L.Scope("block", this.oldScope);
    return this.currentScope;
  };
  this.popScope = function() {
    this.currentScope = this.currentScope.getEnclosingScope();
  };
}


prog returns [node]
@init { var root = new L.Root(); }
@after { $node = root; }
    : (e=exprStmt {root.nodes.push($e.node);})*
    ;

exprStmt returns [node]
        : ^(':' ID expr) { $node = new L.Assignment(this.currentScope, $ID.text, $expr.node); }
        | ^(FN_DEF name=ID {var node = new L.FunctionDef(this.currentScope, $name.text, this.pushScope()); } (arg=ID {node.args.push($arg.text);} )* (e=exprStmt { node.body.push($e.node); })* ) {
          $node = node;
          this.popScope();
        }
        | ^(EX expr) { $node = $expr.node; }
        ;

expr returns [node]
    : ^('+' a=expr b=expr) { $node = new L.Add($a.node, $b.node); }
    | ^('-' a=expr b=expr) { $node = new L.Sub($a.node, $b.node); }
    | ^('*' a=expr b=expr) { $node = new L.Mult($a.node, $b.node); }
    | ^('/' a=expr b=expr) { $node = new L.Divide($a.node, $b.node); }
    | ^('==' a=expr b=expr) { $node = new L.Eq($a.node, $b.node); }
    | ^('!=' a=expr b=expr) { $node = new L.Neq($a.node, $b.node); }
    | ^('>' a=expr b=expr) { $node = new L.Gt($a.node, $b.node); }
    | ^('<' a=expr b=expr) { $node = new L.Lt($a.node, $b.node); }
    | ^('&&' a=expr b=expr) { $node = new L.And($a.node, $b.node); }
    | ^('||' a=expr b=expr) { $node = new L.Or($a.node, $b.node); }
    | ^('>=' a=expr b=expr) { $node = new L.Gte($a.node, $b.node); }
    | ^('<=' a=expr b=expr) { $node = new L.Lte($a.node, $b.node); }
    | ^('!' a=expr) { $node = new L.Negate($a.node); }
    | ^(FN_CALL ID {var node = new L.FunctionCall(this.currentScope, $ID.text);} (e=expr {node.addArgument($e.node);})*) { $node = node; }
    | i=INTEGER { 
        var valueInt = new L.Value($i.text, L.T.INT);
        $node = new L.Literal(valueInt);
      }
    | i=ID {
        var node = new L.Lookup(this.currentScope, $i.text);
        $node = node;
      }
    | i=BOOLEAN {
        var node = new L.Literal(new L.Value($i.text === "T", L.T.BOOLEAN));
        $node = node;
      }
    ;






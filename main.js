(function() {

  $(document).ready(function() {
    var input = $("script[type='text/mocca']").text();
    var cstream = new org.antlr.runtime.ANTLRStringStream(input);
    var lexer = new Ex1TestLexer(cstream);
    var tstream = new org.antlr.runtime.CommonTokenStream(lexer);
    var parser = new Ex1TestParser(tstream);
    var r = parser.prog();
    // console.debug(r.getTree().toStringTree());

    var nodes = new org.antlr.runtime.tree.CommonTreeNodeStream(r.getTree());
    nodes.setTokenStream(tstream);
    var walker = new Ex1Walker(nodes);
    walker.prog().interpret();
  });

}());


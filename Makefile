parser:
	export CLASSPATH=/Users/tom/tom/FHR/MA/code/bin/antlr-3.3-complete.jar:$$CLASSPATH && java org.antlr.Tool Ex1Test.g Ex1Walker.g && clear

minify:
	java -jar tools/compiler-latest/compiler.jar \
		--js=`pwd`/antlr3-all.js \
		--js=`pwd`/Ex1TestLexer.js \
		--js=`pwd`/Ex1TestParser.js\
		--js=`pwd`/Ex1Walker.js\
		--js=`pwd`/jquery-1.8.3.min.js\
		--js=`pwd`/main.js \
		--js_output_file=`pwd`/mocca-lang.js

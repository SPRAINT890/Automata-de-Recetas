import java_cup.runtime.*;
      
%%
   
%class Lexer

%line
%column
    
%cup
   
%{   
    
    private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }
    
    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}
   
LineTerminator = \r|\n|\r\n
   
WhiteSpace     = {LineTerminator} | [ \t\f]
   
cantidad = [1-9][0-9]*

pan = "pan_blanco" | "pan_integral"

ingredientes = "tomate" | "lechuga" 


%%
/* ------------------------Lexical Rules Section---------------------- */
   
   
<YYINITIAL> {
   
	";"			{ System.out.print(yytext()+" "); return symbol(sym.SEMI); }

        {cantidad}	       { System.out.print(yytext()+" "); return symbol(sym.QUANTITY, Integer.parseInt(yytext()));} 
	{pan}	{ System.out.print(yytext()+" "); return symbol(sym.PAN);}
	{ingredientes}	{ System.out.print(yytext()+" "); return symbol(sym.ING);}

	{WhiteSpace}       { /* just skip what was found, do nothing */ }   
}


/* No token was found for the input so through an error.  Print out an
   Illegal character message with the illegal character that was found. */
[^]                    { throw new Error("Illegal character"+ yytext()); }

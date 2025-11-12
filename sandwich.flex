/* ---- Lexer.flex ---- */
import java_cup.runtime.Symbol;

%%

%class Lexer
%unicode
%cup
%line
%column

%state S_VAL

%{
  private Symbol symbol(int type) { return new Symbol(type, yyline, yycolumn); }
  private Symbol symbol(int type, Object val) { return new Symbol(type, yyline, yycolumn, val); }

  private void debugToken(int type, Object val) {
    System.err.println("TOKEN: " + sym.terminalNames[type] +
      (val != null ? (" -> " + val) : ""));
  }
%}

/* --------- macros ---------- */
LineTerminator = \r\n | \r | \n
WS             = [ \t\f]+
DIGITS         = [0-9]+
DECIMAL        = {DIGITS}([.,]{DIGITS})?
FRACTION       = {DIGITS}"/"{DIGITS}
/* letras (incluye acentos y ñ), guión y apóstrofo sencillo para nombres */
WORD           = [\p{L}][\p{L}'-]*
TEXTRESTO      = [^\r\n]+

%%

/* Ignorar BOM UTF-8 */
\uFEFF                           { /* skip */ }

/* ===================== YYINITIAL ===================== */
<YYINITIAL>{

  /* --------- palabras clave ---------- */
  "RECETA"{WS}+                   { debugToken(sym.RECETA, null); return symbol(sym.RECETA); }
  "INGREDIENTES"                  { debugToken(sym.INGREDIENTES, null); return symbol(sym.INGREDIENTES); }
  "PASOS"                         { debugToken(sym.PASOS, null); return symbol(sym.PASOS); }

  /* Claves con “:”; tras ellas leemos valor libre hasta NL en S_VAL */
  "Tiempo"{WS}*":"                { debugToken(sym.TIEMPO, null); yybegin(S_VAL); return symbol(sym.TIEMPO); }
  "Porciones"{WS}*":"             { debugToken(sym.PORCIONES, null); yybegin(S_VAL); return symbol(sym.PORCIONES); }
  "Calorías"{WS}*":"              { debugToken(sym.CALORIAS, null); yybegin(S_VAL); return symbol(sym.CALORIAS); }
  "Categorías"{WS}*":"            { debugToken(sym.CATEGORIAS, null); return symbol(sym.CATEGORIAS); } /* luego lista o [] */
  "Origen"{WS}*":"                { debugToken(sym.ORIGEN, null); yybegin(S_VAL); return symbol(sym.ORIGEN); }
  "Dificultad"{WS}*":"            { debugToken(sym.DIFICULTAD, null); yybegin(S_VAL); return symbol(sym.DIFICULTAD); }
  "Tipo"{WS}*":"                  { debugToken(sym.TIPO, null); yybegin(S_VAL); return symbol(sym.TIPO); }
  "Recetas relacionadas"{WS}*":"  { debugToken(sym.RELACIONADAS, null); return symbol(sym.RELACIONADAS); }
  /* (opcional) tolerar sin ':' */
  "Recetas relacionadas"          { debugToken(sym.RELACIONADAS, null); return symbol(sym.RELACIONADAS); }

  /* --------- signos ---------- */
  ","                             { return symbol(sym.COMA); }
  "["                             { return symbol(sym.LBRACK); }
  "]"                             { return symbol(sym.RBRACK); }
  ":"                             { return symbol(sym.DOSP); }

  /* paso numerado: 1. 2. 3.  → luego texto del paso hasta NL en S_VAL */
  {DIGITS}"."                     { debugToken(sym.STEPNUM, yytext());
                                    yybegin(S_VAL);
                                    return symbol(sym.STEPNUM, yytext().substring(0, yytext().length()-1)); }

  /* --------- literales ---------- */
  \"([^\"\\]|\\.)*\"              { debugToken(sym.STRING, yytext());
                                    return symbol(sym.STRING, yytext().substring(1, yytext().length()-1)); }

  /* cantidades: entero / decimal / fracción */
  {FRACTION}                      { debugToken(sym.CANTIDAD, yytext()); return symbol(sym.CANTIDAD, yytext()); }
  {DECIMAL}                       { debugToken(sym.CANTIDAD, yytext()); return symbol(sym.CANTIDAD, yytext()); }

  /* unidades comunes */
  ("g"|"kg"|"l"|"taza"|"cucharita"|"cucharas"|"u"|"min"|"h")
                                  { debugToken(sym.UNIDAD, yytext()); return symbol(sym.UNIDAD, yytext()); }

  /* “a gusto” como token especial */
  "a"{WS}"gusto"                  { debugToken(sym.AGUSTO, "a gusto"); return symbol(sym.AGUSTO, "a gusto"); }

  /* nombres (para ingredientes, categorías sin corchetes, etc.) */
  {WORD}                          { debugToken(sym.WORD, yytext()); return symbol(sym.WORD, yytext()); }

  /* espacios y saltos de línea */
  {WS}                            { /* skip */ }
  {LineTerminator}                { debugToken(sym.NL, null); return symbol(sym.NL); }

  /* Nota: en YYINITIAL NO hay regla TEXT: evita que “RECETA "X"” se coma la línea completa */
}

/* ===================== S_VAL ===================== */
/* En este estado aceptamos texto libre hasta fin de línea, luego volvemos a YYINITIAL */
<S_VAL>{

  {TEXTRESTO}                     { String t = yytext().trim();
                                    debugToken(sym.TEXT, t);
                                    return symbol(sym.TEXT, t); }

  {WS}                            { /* permitir espacios dentro del valor */ }

  {LineTerminator}                { debugToken(sym.NL, null);
                                    yybegin(YYINITIAL);
                                    return symbol(sym.NL); }
}

/* ===== EOF handling ===== */
/* Si termina el archivo dentro de S_VAL, emitimos un NL sintético y luego volveremos a YYINITIAL */
<S_VAL><<EOF>> {
  debugToken(sym.NL, null);
  yybegin(YYINITIAL);
  return symbol(sym.NL);
}

/* EOF real (fuera de S_VAL) */
<<EOF>> {
  return symbol(sym.EOF);
}

/* cualquier otro caracter es error */
.                                  { throw new Error("Carácter ilegal: " + yytext()); }
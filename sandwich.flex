/* ---- sandwich.flex ---- */
import java_cup.runtime.Symbol;

%%

%class Lexer
%unicode
%ignorecase
%cup
%line
%column

%state S_VAL

%{
  private Symbol symbol(int type) { return new Symbol(type, yyline, yycolumn); }
  private Symbol symbol(int type, Object val) { return new Symbol(type, yyline, yycolumn, val); }

  // debug (puedes comentar el println cuando no lo necesites)
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
  "RECETA" {WS}+                  { debugToken(sym.RECETA, null); return symbol(sym.RECETA); }
  "INGREDIENTES"                  { debugToken(sym.INGREDIENTES, null); return symbol(sym.INGREDIENTES); }
  "PASOS"                         { debugToken(sym.PASOS, null); return symbol(sym.PASOS); }

  /* Claves con “:”; tras ellas leemos valor libre hasta NL en S_VAL */
  "Tiempo"        {WS}* ":"       { debugToken(sym.TIEMPO, null); yybegin(S_VAL); return symbol(sym.TIEMPO); }
  "Porciones"     {WS}* ":"       { debugToken(sym.PORCIONES, null); yybegin(S_VAL); return symbol(sym.PORCIONES); }
  "Calorías"      {WS}* ":"       { debugToken(sym.CALORIAS, null); yybegin(S_VAL); return symbol(sym.CALORIAS); }
  "Categorías"    {WS}* ":"       { debugToken(sym.CATEGORIAS, null); return symbol(sym.CATEGORIAS); }
  "Origen"        {WS}* ":"       { debugToken(sym.ORIGEN, null); yybegin(S_VAL); return symbol(sym.ORIGEN); }
  "Dificultad"    {WS}* ":"       { debugToken(sym.DIFICULTAD, null); yybegin(S_VAL); return symbol(sym.DIFICULTAD); }
  "Tipo"          {WS}* ":"       { debugToken(sym.TIPO, null); yybegin(S_VAL); return symbol(sym.TIPO); }

  /* “Recetas relacionadas” (con o sin ‘:’) */
  "Recetas" {WS}+ "relacionadas" {WS}* ":" { debugToken(sym.RELACIONADAS, null); return symbol(sym.RELACIONADAS); }
  "Recetas" {WS}+ "relacionadas"            { debugToken(sym.RELACIONADAS, null); return symbol(sym.RELACIONADAS); }

  /* OBS: texto libre → entrar a S_VAL (con o sin ‘:’) */
  "Obs" {WS}* ":"                 { debugToken(sym.OBS, null); yybegin(S_VAL); return symbol(sym.OBS); }
  "Obs"                           { debugToken(sym.OBS, null); yybegin(S_VAL); return symbol(sym.OBS); }

  /* --------- signos ---------- */
  ","                             { return symbol(sym.COMA); }
  "["                             { return symbol(sym.LBRACK); }
  "]"                             { return symbol(sym.RBRACK); }
  ":"                             { return symbol(sym.DOSP); }

  /* paso numerado: 1. 2. 3.  → luego texto del paso hasta NL en S_VAL */
  {DIGITS} "."                    { debugToken(sym.STEPNUM, yytext());
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
  "a" {WS} "gusto"                { debugToken(sym.AGUSTO, "a gusto"); return symbol(sym.AGUSTO, "a gusto"); }

  /* nombres (para ingredientes, categorías sin corchetes, etc.) */
  {WORD}                          { debugToken(sym.WORD, yytext()); return symbol(sym.WORD, yytext()); }

  /* espacios y saltos de línea */
  {WS}                            { /* skip */ }
  {LineTerminator}                { debugToken(sym.NL, null); return symbol(sym.NL); }
}

/* ===================== S_VAL ===================== */
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
<S_VAL><<EOF>> {
  debugToken(sym.NL, null);
  yybegin(YYINITIAL);
  return symbol(sym.NL);
}

<<EOF>> { return symbol(sym.EOF); }

. { throw new Error("Carácter ilegal: " + yytext()); }

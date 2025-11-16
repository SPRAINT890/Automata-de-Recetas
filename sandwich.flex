/* ---- sandwich.flex ---- */
import java_cup.runtime.Symbol;

%%

%class Lexer
%unicode
%ignorecase
%cup
%line
%column

%state S_VAL, S_METADATA

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
/* Tiempo flexible: 1h 15min, 1h 15m, 1,25h, 75min, etc. */
TIEMPO_PATTERN = ({DIGITS}[hH]({WS}*{DIGITS}[mM]([iI][nN])?)?)|({DECIMAL}[hH])|({DIGITS}[mM]([iI][nN])?)|({DIGITS}['\u2019])
/* Estrellas para dificultad */
ESTRELLAS      = \*+
/* Metadata pattern: ETIQUETA=VALOR */
METADATA_KEY   = [A-Za-z_][\w]*
METADATA_VALUE = [^\r\n,=]+

%%

/* Ignorar BOM UTF-8 */
\uFEFF                           { /* skip */ }

/* ===================== YYINITIAL ===================== */
<YYINITIAL>{

  /* --------- palabras clave ---------- */
  "RECETA" {WS}+                  { debugToken(sym.RECETA, null); yybegin(S_VAL); return symbol(sym.RECETA); }
  "INGREDIENTES" {WS}* ":"?       { debugToken(sym.INGREDIENTES, null); return symbol(sym.INGREDIENTES); }
  "PASOS" {WS}* ":"?              { debugToken(sym.PASOS, null); return symbol(sym.PASOS); }

  /* Claves con ":"; tras ellas leemos valor libre hasta NL en S_VAL */
  "Tiempo"        {WS}* ":"       { debugToken(sym.TIEMPO, null); yybegin(S_VAL); return symbol(sym.TIEMPO); }
  "Porciones"     {WS}* ":"       { debugToken(sym.PORCIONES, null); yybegin(S_VAL); return symbol(sym.PORCIONES); }
  ("Calorías"|"Calorias"|"calorias"|"calorías")      {WS}* ":"       { debugToken(sym.CALORIAS, null); yybegin(S_VAL); return symbol(sym.CALORIAS); }
  ("Categorías"|"Categorias"|"categorias"|"categorías")    {WS}* ":"       { debugToken(sym.CATEGORIAS, null); return symbol(sym.CATEGORIAS); }
  "Origen"        {WS}* ":"       { debugToken(sym.ORIGEN, null); yybegin(S_VAL); return symbol(sym.ORIGEN); }
  "Dificultad"    {WS}* ":"       { debugToken(sym.DIFICULTAD, null); yybegin(S_VAL); return symbol(sym.DIFICULTAD); }
  "Tipo"          {WS}* ":"       { debugToken(sym.TIPO, null); yybegin(S_VAL); return symbol(sym.TIPO); }

  "Recetas" {WS}+ "relacionadas" {WS}* ":" { debugToken(sym.RELACIONADAS, null); return symbol(sym.RELACIONADAS); }

  /* OBS: texto libre → entrar a S_VAL (con o sin ':') */
  "Obs" {WS}* ":"                 { debugToken(sym.OBS, null); yybegin(S_VAL); return symbol(sym.OBS); }



  /* --------- signos ---------- */
  ","                             { return symbol(sym.COMA); }
  "["                             { return symbol(sym.LBRACK); }
  "]"                             { return symbol(sym.RBRACK); }


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

  /* tiempo flexible */
  {TIEMPO_PATTERN}                { debugToken(sym.TIEMPO_VAL, yytext()); return symbol(sym.TIEMPO_VAL, yytext()); }

  /* estrellas para dificultad */
  {ESTRELLAS}                     { debugToken(sym.ESTRELLAS, yytext()); return symbol(sym.ESTRELLAS, yytext()); }

  /* unidades comunes - expandidas */
  ("g"|"kg"|"gr"|"gramos"|"kilogramos"|"l"|"litros"|"ml"|"mililitros"|"cm3"|"taza"|"tazas"|"cucharita"|"cucharitas"|"cucharada"|"cucharadas"|"cucharas"|"u"|"unidad"|"unidades"|"min"|"minutos"|"h"|"hora"|"horas"|"Kcal"|"kcal"|"cal")
                                  { debugToken(sym.UNIDAD, yytext()); return symbol(sym.UNIDAD, yytext()); }

  /* "a gusto" como token especial */
  "a" {WS} "gusto"                { debugToken(sym.AGUSTO, "a gusto"); return symbol(sym.AGUSTO, "a gusto"); }

  /* nombres (para ingredientes, categorías sin corchetes, etc.) */
  {WORD}                          { debugToken(sym.WORD, yytext()); return symbol(sym.WORD, yytext()); }

  /* espacios y saltos de línea */
  {WS}                            { /* skip */ }
  {LineTerminator}                { debugToken(sym.NL, null); return symbol(sym.NL); }
}

/* ===================== S_VAL ===================== */
<S_VAL>{
  /* quoted strings should be recognized as STRING tokens */
  \"([^\"\\]|\\.)*\"              { debugToken(sym.STRING, yytext());
                                    return symbol(sym.STRING, yytext().substring(1, yytext().length()-1)); }

  {TEXTRESTO}                     { String t = yytext().trim();
                                    debugToken(sym.TEXT, t);
                                    return symbol(sym.TEXT, t); }

  {WS}                            { /* permitir espacios dentro del valor */ }

  {LineTerminator}                { debugToken(sym.NL, null);
                                    yybegin(YYINITIAL);
                                    return symbol(sym.NL); }
}

/* ===================== S_METADATA ===================== */
<S_METADATA>{
  {METADATA_VALUE}                { String val = yytext().trim();
                                    debugToken(sym.METADATA_VALUE, val);
                                    return symbol(sym.METADATA_VALUE, val); }

  {WS}                            { /* skip */ }

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

<S_METADATA><<EOF>> {
  debugToken(sym.NL, null);
  yybegin(YYINITIAL);
  return symbol(sym.NL);
}

<<EOF>> { return symbol(sym.EOF); }

. { throw new Error("Carácter ilegal: " + yytext()); }
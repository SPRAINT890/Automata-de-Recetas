import java_cup.runtime.*;
      
%%
   
%class Lexer
%unicode
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
    
    // debug (puedes comentar el println cuando no lo necesites)
    private void debugToken(int type, Object val) {
        System.err.println("TOKEN: " + sym.terminalNames[type] +
        (val != null ? (" -> " + val) : ""));
    }
%}
   
LineTerminator = \r|\n|\r\n
WhiteSpace     = [ \t\f]+
   
/* Números y medidas */
Entero = [0-9]+
Decimal = [0-9]+"."[0-9]+
DecimalComa = [0-9]+","[0-9]+
Fraccion = [0-9]+"/"[0-9]+

/* Unidades de medida */
UnidadPeso = "g" | "kg" | "gramos" | "kilogramos"
UnidadVolumen = "l" | "ml" | "litros" | "mililitros" | "cm3" | "taza" | "tazas"
UnidadCantidad = "u" | "unidad" | "unidades" | "cuchara" | "cucharas" | "cucharita" | "cucharitas"
UnidadTemperatura = "C" | "°C" | "F" | "°F"

/* Identificadores y textos */
Palabra = [\p{L}]+
TextoEntreComillas = \"[^\"]*\"

/* Tiempo - patrones más específicos */
TiempoHoras = {Entero}[ ]?"h"([ ]?{Entero}[ ]?("m"|"min"|"'"))?
TiempoMinutos = {Entero}[ ]?("min"|"m"[^l])
TiempoDecimal = {Decimal}[ ]?"h"
TiempoFraccion = {Fraccion}[ ]?"h"
TiempoMixto = {Entero}[ ]{Entero}"'"

/* Dificultad */
Estrellas = "*"+
Precio = "$"+

%%
/* ------------------------Lexical Rules Section---------------------- */
   
<YYINITIAL> {
   
    /* Palabras clave - deben ir ANTES de identificadores */
    "RECETA"           { debugToken(sym.RECETA, null); return symbol(sym.RECETA); }
    "INGREDIENTES"     { debugToken(sym.INGREDIENTES, null); return symbol(sym.INGREDIENTES); }
    "PASOS"            { debugToken(sym.PASOS, null); return symbol(sym.PASOS); }
    "Tiempo"           { debugToken(sym.TIEMPO_KW, null); return symbol(sym.TIEMPO_KW); }
    "Porciones"        { debugToken(sym.PORCIONES, null); return symbol(sym.PORCIONES); }
    "Calorías"    { debugToken(sym.CALORIAS, null); return symbol(sym.CALORIAS); }
    "Calorias"         { debugToken(sym.CALORIAS, null); return symbol(sym.CALORIAS); }
    "Categorías"       { debugToken(sym.CATEGORIAS, null); return symbol(sym.CATEGORIAS); }
    "Categorias"       { debugToken(sym.CATEGORIAS, null); return symbol(sym.CATEGORIAS); }
    "Origen"           { debugToken(sym.ORIGEN, null); return symbol(sym.ORIGEN); }
    "Dificultad"       { debugToken(sym.DIFICULTAD, null); return symbol(sym.DIFICULTAD); }
    "Tipo"             { debugToken(sym.TIPO, null); return symbol(sym.TIPO); }
    "Obs"              { debugToken(sym.OBS, null); return symbol(sym.OBS); }
    "Recetas relacionadas" { debugToken(sym.RECETAS_RELACIONADAS, null); return symbol(sym.RECETAS_RELACIONADAS); }
    "Kcal"             { debugToken(sym.KCAL, null); return symbol(sym.KCAL); }
    
    /* Niveles de dificultad específicos */
    "FACIL"            { debugToken(sym.NIVEL_TEXTO, null); return symbol(sym.NIVEL_TEXTO, yytext()); }
    "MEDIA"            { debugToken(sym.NIVEL_TEXTO, null); return symbol(sym.NIVEL_TEXTO, yytext()); }
    "DIFICIL"          { debugToken(sym.NIVEL_TEXTO, null); return symbol(sym.NIVEL_TEXTO, yytext()); }
    "MUY_FACIL"        { debugToken(sym.NIVEL_TEXTO, null); return symbol(sym.NIVEL_TEXTO, yytext()); }
    "MUY_DIFICIL"      { debugToken(sym.NIVEL_TEXTO, null); return symbol(sym.NIVEL_TEXTO, yytext()); }
    "EXPERTO"          { debugToken(sym.NIVEL_TEXTO, null); return symbol(sym.NIVEL_TEXTO, yytext()); }
    
    /* Categorías de recetas */
    "desayuno"         { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "Desayuno"         { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "merienda"         { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "Merienda"         { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "principal"        { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "Principal"        { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "entrada"          { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "Entrada"          { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "colación"         { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "Colacion"         { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "colación"         { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "postre"           { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    "Postre"           { debugToken(sym.CATEGORIA, null); return symbol(sym.CATEGORIA, yytext()); }
    
    /* Símbolos */
    ":"                { debugToken(sym.COLON, null); return symbol(sym.COLON); }
    ","                { debugToken(sym.COMA, null); return symbol(sym.COMA); }
    "."                { debugToken(sym.PUNTO, null); return symbol(sym.PUNTO); }
    "["                { debugToken(sym.LBRACKET, null); return symbol(sym.LBRACKET); }
    "]"                { debugToken(sym.RBRACKET, null); return symbol(sym.RBRACKET); }
    "="                { debugToken(sym.EQUALS, null); return symbol(sym.EQUALS); }
    
    /* Unidad especial */
    "a gusto"          { debugToken(sym.UNIDAD_LIBRE, null); return symbol(sym.UNIDAD_LIBRE, yytext()); }
    
    /* Tiempo - debe ir ANTES de números y letras sueltas */
    {TiempoHoras}      {  debugToken(sym.TIEMPO_VAL, null); return symbol(sym.TIEMPO_VAL, yytext()); }
    {TiempoMinutos}    {  debugToken(sym.TIEMPO_VAL, null); return symbol(sym.TIEMPO_VAL, yytext()); }
    {TiempoDecimal}    {  debugToken(sym.TIEMPO_VAL, null); return symbol(sym.TIEMPO_VAL, yytext()); }
    {TiempoFraccion}   {  debugToken(sym.TIEMPO_VAL, null); return symbol(sym.TIEMPO_VAL, yytext()); }
    {TiempoMixto}      {  debugToken(sym.TIEMPO_VAL, null); return symbol(sym.TIEMPO_VAL, yytext()); }
    
    /* Estrellas para dificultad */
    {Estrellas}        { debugToken(sym.ESTRELLAS, null); return symbol(sym.ESTRELLAS, yytext()); }

    {Precio}        { debugToken(sym.PRECIO, null); return symbol(sym.PRECIO, yytext()); }
    
    /* Números - fracciones ANTES que enteros */
    {Fraccion}         { debugToken(sym.FRACCION, null); return symbol(sym.FRACCION, yytext()); }
    {DecimalComa}      { debugToken(sym.DECIMAL, null); return symbol(sym.DECIMAL, yytext()); }
    {Decimal}          { debugToken(sym.DECIMAL, null); return symbol(sym.DECIMAL, yytext()); }
    {Entero}           { debugToken(sym.ENTERO, null); return symbol(sym.ENTERO, Integer.parseInt(yytext())); }
    
    /* Unidades de medida - deben ir ANTES de identificadores */
    {UnidadPeso}       { debugToken(sym.UNIDAD, null); return symbol(sym.UNIDAD, yytext()); }
    {UnidadVolumen}    { debugToken(sym.UNIDAD, null); return symbol(sym.UNIDAD, yytext()); }
    {UnidadCantidad}   { debugToken(sym.UNIDAD, null); return symbol(sym.UNIDAD, yytext()); }
    {UnidadTemperatura} { debugToken(sym.UNIDAD, null); return symbol(sym.UNIDAD, yytext()); }
    
    /* Texto entre comillas */
    {TextoEntreComillas} { 
        String txt = yytext();
        return symbol(sym.TEXTO_COMILLAS, txt.substring(1, txt.length()-1)); 
    }
    
    /* Identificadores - debe ir al FINAL */
    {Palabra}          { debugToken(sym.PALABRA, yytext()); return symbol(sym.PALABRA, yytext()); }
    
    /* Espacios en blanco */
    {WhiteSpace}       { /* ignorar */ }
    {LineTerminator}      { debugToken(sym.NUEVA_LINEA, null); return symbol(sym.NUEVA_LINEA); }
}

/* Error para caracteres no reconocidos */
[^]                    { throw new Error("Caracter ilegal <" + yytext() + "> en línea " + (yyline+1) + ", columna " + (yycolumn+1)); }
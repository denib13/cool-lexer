/* 
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

 
/*
 *  Add Your own definitions here
 */

%}

%x STRING
%x ERROR_STRING
%x EOF_STRING

/*
 * Define names for regular expressions here.
 */





WS              [ \t]+
CLASS           [Cc][Ll][Aa][Ss][Ss]             
FI              [Ff][Ii]$
IF              [Ii][Ff]$
IN              [Ii][Nn]
INHERITS        [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss]
ISVOID          [Ii][Ss][Vv][Oo][Ii][Dd]
LET             [Ll][Ee][Tt]
LOOP            [Ll][Oo][Oo][Pp]    
POOL            [Pp][Oo][Oo][Ll]        
THEN            [Tt][Hh][Ee][Nn]                            
WHILE           [Ww][Hh][Ii][Ll][Ee]
CASE            [Cc][Aa][Ss][Ee]  
ESAC            [Ee][Ss][Aa][Cc]
NEW             [Nn][Ee][Ww]         
OF              [Oo][Ff]   
NOT             [Nn][Oo][Tt]          
ELSE            [Ee][Ll][Ss][Ee]
TRUE            t[Rr][Uu][Ee]$
FALSE           f[Aa][Ll][Ss][Ee]
TYPEID          [A-Z][a-zA-Z0-9_]*
DIGIT           [0-9]  
INTEGER         {DIGIT}+
OBJECTID        [a-z][a-zA-Z0-9_]*
OPERATORS       [-+*/@,~:=<]
DOT             \.
SEMICOLON       \;
LBRACKET        \(
RBRACKET        \)
LCBRACKET       \{
RCBRACKET       \}
LE              <=
DARROW          =>
ASSIGN          <-
ERROR           _

WS_STRING_SYMBOL \/[btnf]
STRING_CHARS ([a-zA-Z0-9 :!@#$%^&*()_+-=\t]+|{WS_STRING_SYMBOL}+)
STRING_ESCAPED_CHAR {SLASH}[^btnf]
NULL         \0
QUOTE \"

NEW_LINE \n
SLASH \\

%%

{QUOTE} {
      
          BEGIN(STRING);
        }
<STRING>{QUOTE} { 
        {
          yytext[yyleng-1] = '\0';
          --yyleng;
          cool_yylval.symbol = inttable.add_string(yytext);
          BEGIN(INITIAL);
          return (STR_CONST);
        }}
<STRING>{STRING_CHARS} { 
        {
          yymore();
        }}
<STRING>{STRING_ESCAPED_CHAR} { 
        {
          if (yyleng < 2)
          {
            return 'E';
          }

          if(yytext[yyleng-1] == '\0')
          {
            cool_yylval.error_msg = "String contains escaped null character.";
            BEGIN(ERROR_STRING);
            return (ERROR);
          }

          yytext[yyleng-2] = yytext[yyleng-1];
          yytext[yyleng-1] = '\0';
          --yyleng;
          yymore();
        }}
<STRING><<EOF>> { 
        {
          yyrestart(yyin);
          cool_yylval.error_msg = "EOF in string constant";
          BEGIN(EOF_STRING);
          return (ERROR);
        }}
<ERROR_STRING>{QUOTE} { 
        { 
          BEGIN(INITIAL);
        }}
<ERROR_STRING>\n { 
        { 
          BEGIN(INITIAL);
        }}
<ERROR_STRING><<EOF>> { 
        {
          yyterminate();
        }}
<EOF_STRING>\n|. { 
        {
          yyterminate();
        }}

{WS}
{NEW_LINE}         
{CLASS}      { return (CLASS); }
{FI}      { return (FI); }
{IF}      { return (IF); }
{IN}      { return (IN); }
{INHERITS}      { return (INHERITS); }
{ISVOID}      { return (ISVOID); }
{LET}      { return (LET); }
{LOOP}      { return (LOOP); }
{POOL}      { return (POOL); }
{THEN}      { return (THEN); }
{WHILE}      { return (WHILE); }
{CASE}      { return (CASE); }
{ESAC}      { return (ESAC); }
{NEW}      { return (NEW); }
{OF}      { return (OF); }
{NOT}      { return (NOT); }
{ELSE}      { return (ELSE); }
{TRUE}      { cool_yylval.boolean = true;
              return (BOOL_CONST); 
}
{FALSE}      { cool_yylval.boolean = false;
               return (BOOL_CONST); 
}
{TYPEID}     { cool_yylval.symbol = inttable.add_string(yytext);
                return (TYPEID); 
}
{LE}        { return (LE);}
{DARROW}		{ return (DARROW); }
{INTEGER}   { 
              cool_yylval.symbol = inttable.add_string(yytext);
              return (INT_CONST); 
}
{OBJECTID}  { 
              cool_yylval.symbol = inttable.add_string(yytext);
              return (OBJECTID); 
}
{OPERATORS} { return yytext[0]; }
{DOT}       { return yytext[0]; }
{SEMICOLON} { return yytext[0]; }
{LBRACKET}  { return yytext[0]; }
{RBRACKET}  { return yytext[0]; }
{LCBRACKET} { return yytext[0]; }
{RCBRACKET} { return yytext[0]; }
{ASSIGN}    { return (ASSIGN);}
{ERROR}     {
              cool_yylval.symbol = inttable.add_string(yytext);
              return (ERROR);
}
<<EOF>> {yyterminate();}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%

// Rudimentary Grammar file
grammar Tiger;

options {
    k = 1;
    output = AST;
    backtrack = no;
}

tokens {
    COMMA       = ',';
    COLON       = ':';
    SEMI        = ';';
    LPAREN      = '(';
    RPAREN      = ')';
    MULT        = '*';
    DIV         = '/';
    PLUS        = '+';
    MINUS       = '-';
    EQ          = '=';
    NEQ         = '<>';
    GREATER     = '>';
    LESSER      = '<';
    GREATEREQ   = '>=';
    LESSEREQ    = '<=';
    AND         = '&';
    OR          = '|';
    LBRACK      = '[';
    RBRACK      = ']';
    ASSIGN      = ':=';
   
}

// Parser custom code

@parser::members {
    public void displayRecognitionError(String[] tokens, RecognitionException re) {
        // First, split the program into lines and identify the offending line
        String program = re.input.toString();
        int lineNo = re.line - 1;
        int charNo = re.charPositionInLine;
        String[] lines = program.split("\\n");
        String badLine = lines[lineNo];

        // Craft a potentially helpful message
        String helpMessage = "";
        if (re.token.getType() == INVALID_INTLIT) {
            helpMessage = "Integers cannot have leading zeros";
        } else if (re.token.getType() == INVALID_FIXEDPTLIT) {
            helpMessage = "Invalid fixed point literal";
        } else if (re.token.getType() == INVALID_ID) {
            helpMessage = "Invalid identifier";
        }

        // Craft the error message
        String errorMessage = getErrorMessage(re, tokens);
        // Which bad token did they provide?
        String badToken = (re.token.getType() >= 0) ? tokenNames[re.token.getType()] : "EOF";

        // If multiple things can be matched
        if (re instanceof MismatchedSetException) {
            MismatchedSetException mse = (MismatchedSetException) re;
            errorMessage = "You provided a " + 
                            badToken + 
                            ", but something else was expected";

        // If only one thing could have been matched
        } else if (re instanceof MismatchedTokenException) {
            MismatchedTokenException mte = (MismatchedTokenException) re;
            String expected = (mte.expecting >= 0) ? tokenNames[mte.expecting] : "EOF";
            errorMessage = "You provided a " +
                            badToken +
                            ", but this was expected instead: " +
                            expected;
        }

        // Wrap quotes around the incorrect token
        int begin = re.token.getCharPositionInLine();
        int end = begin + re.token.getText().length();
        String errorLine = badLine.substring(0, begin) +
                            "\"" +
                            re.token.getText() + 
                            "\"" + 
                            badLine.substring(end, badLine.length());

        // Print out the error message
        System.out.print("Line " + lineNo + ":" + charNo + ": ");
        System.out.print(errorMessage);
        if (helpMessage.length() > 0) {
            System.out.print(" (" + helpMessage + ")");
        }
        System.out.println();
        System.out.println("\t" + errorLine);
        System.out.print("\t");
        for (int i = 0; i < re.charPositionInLine + 1; i++) {
            System.out.print(" ");
        }
        System.out.println("^");
        System.out.println();
    }
}

// Lexer custom code 
@lexer::members {

    /* Override specifically to be able to provide INVALID_TYPE
     * tokens, makes parsing easier.
     */
    @Override
    public Token nextToken() {
        while (true) {
            state.token = null;
            state.channel = Token.DEFAULT_CHANNEL;
            state.tokenStartCharIndex = input.index();
            state.tokenStartCharPositionInLine = input.getCharPositionInLine();
            state.tokenStartLine = input.getLine();
            state.text = null;
            if ( input.LA(1) == CharStream.EOF) {
                return getEOFToken();
            }
            try {
                mTokens();
                if (state.token == null) {
                    emit();
                } else if (state.token == Token.SKIP_TOKEN) {
                    continue;
                }
                return state.token;
            } catch(RecognitionException re) {
                reportError(re);
                if (re instanceof NoViableAltException) {
                    recover(re);
                }
                /* Create a custom token specifically tailored for the 
                    given input. Do NOT use Token.INVALID_TOKEN, as it
                    does not contain the information we want. To add
                    the information to it that we want, it would be
                    equivalent to doing the below anyway.
                 */
                Token t = new CommonToken(input, Token.INVALID_TOKEN_TYPE,
                                            Token.DEFAULT_CHANNEL,
                                            state.tokenStartCharIndex,
                                            getCharIndex() - 1);
                t.setLine(state.tokenStartLine);
                t.setCharPositionInLine(state.tokenStartCharPositionInLine);
                emit(t);
                return state.token;
            }
        }
    }

    /* Override to be able to count the number of syntax errors. 
     * Lexer's reportError does not count the number of errors.
     */
    @Override
    public void reportError(RecognitionException re) {
        state.syntaxErrors++;
        displayRecognitionError(this.getTokenNames(), re);
    }

    /*  This method is overrided so that we can print out helpful
     *  error messages for during scanning.
     */
    public void displayRecognitionError(String[] tokens, RecognitionException re) {

        // First, split the program into lines and identify the offending line
        String program = re.input.toString();
        int lineNo = re.line - 1;
        int charNo = re.charPositionInLine;
        String[] lines = program.split("\\n");
        String badLine = lines[lineNo];

        // Insert quotes around the malformed token
        String errorLine = badLine.substring(0, charNo) + 
                            "\"" +
                            badLine.charAt(charNo) +
                            "\"" +
                            badLine.substring(charNo + 1, badLine.length());

        // Report the syntactic mistake
        System.out.println("Line " + lineNo + ":" + charNo + ": " + "invalid start of token");
        System.out.println("\t" + errorLine);
        System.out.print("\t");
        for (int i = 0; i < re.charPositionInLine + 1; i++) {
            System.out.print(" ");
        }
        System.out.println("^");
        System.out.println();
    }
}

// Keywords and other lexer rules

FUNCTION
    : 'function';

BEGIN
    : 'begin';

END 
    : 'end';

VOID
    : 'void';

VOID_FUNCTION
    : 'void function';

MAIN
    : 'main';

VOID_MAIN
    : 'void main';

TYPE
    : 'type';

ARRAY
    : 'array';

OF
    : 'of';

INT
    : 'int';

FIXEDPT
    : 'fixedpt';

VAR
    : 'var';

IF
    : 'if';

THEN
    : 'then';

ENDIF
    : 'endif';

ELSE
    : 'else';

WHILE
    : 'while';

DO
    : 'do';

ENDDO
    : 'enddo';

FOR
    : 'for';

TO
    : 'to';

BREAK
    : 'break';

RETURN
    : 'return';

WHITESPACE
    : ( '\t' | ' ' | '\r' | '\n' | '\u000C' )+ {$channel = HIDDEN;};

INVALID_INTLIT
    : '0'('0'..'9')+;

INTLIT
    : ((DIGIT)('0' | DIGIT)*) | '0';


// First, match the case where there are more than 3 decimals
// Second, match the case where the decimals are fine but has leading zeros
// Third, match the case where there are no decimals
INVALID_FIXEDPTLIT
    : (INTLIT | INVALID_INTLIT)?'.'('0' | DIGIT)('0' | DIGIT)('0' | DIGIT)('0' | DIGIT)+
    | (INVALID_INTLIT)?'.'('0'|DIGIT)(('0'|DIGIT)('0' | DIGIT)?)?
    | (INTLIT | INVALID_INTLIT)?'.'
    ;

FIXEDPTLIT
    : (INTLIT)'.'('0' | DIGIT)(('0' | DIGIT) ('0' | DIGIT)?)?;

// Invalid IDs start with either a digit or an underscore
INVALID_ID
    : ( '0'..'9' | '_' ) (UPPERCASE | LOWERCASE | '0'..'9' | '_')*;

ID  
    : ( UPPERCASE | LOWERCASE) ( UPPERCASE | LOWERCASE | '0'..'9' | '_')*;

COMMENT
    : '/*' ( options {greedy=false;} : . )* '*/' {$channel = HIDDEN;};


fragment DIGIT
    : '1'..'9';

fragment LOWERCASE
    : 'a'..'z';

fragment UPPERCASE
    : 'A'..'Z';

 
// Parser rules
// These are for a test only. Everything will change later

tigerprogram    : typedecllist functdecllist mainfunction EOF!;

// typedecllist stuff
typedecllist    : (typedecl)*;
typedecl        : TYPE^ ID EQ type SEMI!;
type            : basetype | ARRAY LBRACK! INTLIT RBRACK! (LBRACK! INTLIT RBRACK!)? OF! basetype;
basetype        : INT | FIXEDPT;

//Function declaration list stuff
functdecllist   : (functdecl)*;
functdecl       : (VOID_FUNCTION^ | typeid FUNCTION^) ID LPAREN! paramlist RPAREN! blocklist ;
typeid          : basetype | ID;

// Paramater list stuff
paramlist       : (param (COMMA! param)*)?;
param           : ID COLON! typeid^;

// Block list stuff

// Function Declaration list and main
mainfunction    : VOID_MAIN^ LPAREN! RPAREN! BEGIN! blocklist END! SEMI!;

// Block list
blocklist       : (block)+;
block           : BEGIN! declsegment statseq END! SEMI!;

// Declaration statements
declsegment     : typedecllist vardecllist;
vardecllist     : (vardecl)*;
vardecl         : VAR! idlist COLON! typeid^ optionalinit SEMI!;

// idlist and optionalinit and optprefix
idlist          : ID (COMMA! ID)*;
optionalinit    : (ASSIGN tiger_const)?;

// Statseq and Stat and optprefix

/*  ID initial situations:
    It either is an assign expression, or it's a function call.

    (*) When it's an assign expression, it must be followed by
        a valuetail, an ASSIGN, and an expression 
        (which could be a function call).

    (*) When it's a function call, it is just followed by
        a function tail.

 */
idstatrule      : ID^ (valuetail ASSIGN^ expr | funccalltail) SEMI!;

funccalltail    : LPAREN! exprlist RPAREN!;

statseq         : (stat)+;
ifthen          : IF^ expr THEN statseq (ELSE statseq)? ENDIF! SEMI!;
whileloop       : WHILE^ expr DO statseq ENDDO! SEMI!;
forloop         : FOR^ ID ASSIGN indexexpr TO indexexpr DO statseq ENDDO! SEMI!;
returnstatrule  : RETURN^ expr SEMI!;
breakstatrule   : BREAK^ SEMI!;
stat            : idstatrule | ifthen | whileloop | forloop | returnstatrule | breakstatrule | block;

// Expressions

expr            : logicexpr (logicop^ logicexpr)*;
logicexpr       : compareexpr (compareop^ compareexpr)*;
compareexpr     : addsubexpr (addsubop^ addsubexpr)*;
addsubexpr      : exprlit (multdivop^ exprlit)*;
exprlit         : tiger_const | ID^ (valuetail | funccalltail) | LPAREN! expr RPAREN!;

// Constant/Value
tiger_const     : INTLIT | FIXEDPTLIT;
value           : ID valuetail;
valuetail       : (LBRACK! indexexpr RBRACK! (LBRACK! indexexpr RBRACK!)?)?;

// Expression list
exprlist        : (expr (COMMA! expr)*)?;

// Index expression
indexexpr       : indexmultexpr (addsubop^ indexmultexpr)*;
indexmultexpr   : indexlit (multdivop^ indexlit)*; 
indexlit        : INTLIT | ID | FIXEDPTLIT | LPAREN! indexexpr RPAREN!;

// Binary Operators
multdivop       : MULT | DIV;
addsubop        : PLUS | MINUS;
compareop       : EQ | NEQ | LESSER | LESSEREQ | GREATER | GREATEREQ;
logicop         : AND | OR;

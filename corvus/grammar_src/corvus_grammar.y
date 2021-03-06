/* ***** BEGIN LICENSE BLOCK *****
;;
;; Copyright (c) 2008-2010 Shannon Weyrick <weyrick@mozek.us>
;;
;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.
   ***** END LICENSE BLOCK *****
*/

%include {   

#include "corvus/pAST.h"
#include "corvus/pSourceModule.h"

#include <iostream>
#include <string>
#include <cctype> // for toupper
#include <algorithm>

using namespace corvus;

#define CTXT               pMod->context()
#define TOKEN_RANGE(T)     CTXT.getRange(T)
#define CURRENT_LINE       CTXT.currentLineNum()

AST::literalExpr* extractLiteralString(pSourceRef* B, pSourceModule* pMod, bool isSimple) {
  // substring out the quotes, special case for empty string
  AST::literalString* A;
  if ((*B).size() <= 2) {
    A = new (CTXT) AST::literalString();
  }
  else {
    A = new (CTXT) AST::literalString((*B).slice(1, (*B).size()-1));
  }
  A->setIsSimple(isSimple);
  return A;
}

}  

%name corvusParse
%token_type {pSourceRef*}
%default_type {pSourceRef*}
%extra_argument {pSourceModule* pMod}


// tokens that don't need parse info or AST nodes
%type T_WHITESPACE {int}
%type T_OPEN_TAG {int}
%type T_CLOSE_TAG {int}
%type T_LEFTPAREN {int}
%type T_RIGHTPAREN {int}
%type T_LEFTCURLY {int}
%type T_RIGHTCURLY {int}
%type T_LEFTSQUARE {int}
%type T_RIGHTSQUARE {int}
%type T_COMMA {int}
%type T_NS_SEPARATOR {int}
%type T_SINGLELINE_COMMENT {int}
%type T_MULTILINE_COMMENT {int}
%type T_DOC_COMMENT {int}
%type T_INLINE_HTML {int}
%type T_WHILE {int}
%type T_ENDWHILE {int}
%type T_ELSE {int}
%type T_ELSEIF {int}
%type T_ARRAY {int}
%type T_ARROWKEY {int}
%type T_AND {int}
%type T_ASSIGN {int}
%type T_DQ_STRING {int}
//We need _LIT versions here for 'and', 'or' and 'xor' because these have another precedence than '&&' and  '||'
//but finally we want them to look like the normal ast nodes.
%type T_BOOLEAN_AND {int}
%type T_BOOLEAN_AND_LIT {int}
%type T_BOOLEAN_OR {int}
%type T_BOOLEAN_OR_LIT {int}
%type T_BOOLEAN_XOR_LIT {int}
%type T_BOOLEAN_NOT {int}
%type T_IDENTIFIER {int}
%type T_GLOBAL {int}
%type T_FUNCTION {int}
%type T_EMPTY {int}
%type T_EQUAL {int}
%type T_NOT_EQUAL {int}
%type T_ISSET {int}
%type T_UNSET {int}
%type T_VAR {int}
%type T_CLASS {int}
%type T_CLASSDEREF {int}
%type T_FOREACH {int}
%type T_ENDFOREACH {int}
%type T_FOR {int}
%type T_ENDFOR {int}
%type T_AS {int}
%type T_RETURN {int}
%type T_DOT {int}
%type T_GREATER_THAN {int}
%type T_LESS_THAN {int}
%type T_GREATER_OR_EQUAL {int}
%type T_LESS_OR_EQUAL {int}
%type T_LIST {int}
%type T_EXTENDS {int}
%type T_PUBLIC {int}
%type T_PRIVATE {int}
%type T_PROTECTED {int}
%type T_INCLUDE {int}
%type T_INCLUDE_ONCE {int}
%type T_REQUIRE {int}
%type T_REQUIRE_ONCE {int}
%type T_IDENTICAL {int}
%type T_NOT_IDENTICAL {int}
%type T_QUESTION {int}
%type T_COLON {int}
%type T_DBL_COLON {int}
%type T_INC {int}
%type T_DEC {int}
%type T_EXIT {int}
%type T_MINUS {int}
%type T_PLUS {int}
%type T_DIV {int}
%type T_MOD {int}
%type T_MULT {int}
%type T_SWITCH {int}
%type T_ENDSWITCH {int}
%type T_CASE {int}
%type T_BREAK {int}
%type T_CONTINUE {int}
%type T_DEFAULT {int}
%type T_CLONE {int}
%type T_TRY {int}
%type T_CATCH {int}
%type T_THROW {int}
%type T_STATIC {int}
%type T_CONST {int}
%type T_AT {int}
%type T_INSTANCEOF {int}
%type T_PLUS_EQUAL {int}
%type T_MINUS_EQUAL {int}
%type T_EVAL {int}
%type T_SR_EQUAL {int}
%type T_SL_EQUAL {int}
%type T_XOR_EQUAL {int}
%type T_OR_EQUAL {int}
%type T_AND_EQUAL {int}
%type T_MOD_EQUAL {int}
%type T_CONCAT_EQUAL {int}
%type T_DIV_EQUAL {int}
%type T_MUL_EQUAL {int}
%type T_SR {int}
%type T_SL {int}
%type T_NAMESPACE {int}
%type T_INT_CAST {int}
%type T_FLOAT_CAST {int}
%type T_STRING_CAST {int}
%type T_UNICODE_CAST {int}
%type T_BINARY_CAST {int}
%type T_ARRAY_CAST {int}
%type T_OBJECT_CAST {int}
%type T_UNSET_CAST {int}
%type T_BOOL_CAST {int}
%type T_GOTO {int}
%type T_MAGIC_FILE {int}
%type T_MAGIC_LINE {int}
%type T_MAGIC_NS {int}
%type T_MAGIC_CLASS {int}
%type T_MAGIC_FUNCTION {int}
%type T_MAGIC_METHOD {int}
%type T_TICK {int}
%type T_TILDE {int}
%type T_PIPE {int}
%type T_CARET {int}
%type T_PRINT {int}
%type T_INTERFACE {int}

// double quote parsing
%type T_DQ_DONE {int}
%type T_DQ_DQ  {int}
%type T_DQ_NEWLINE  {int}
%type T_DQ_VARIABLE  {int}
%type T_DQ_ESCAPE  {int}

%syntax_error {  
  CTXT.parseError(TOKEN, TOKEN_RANGE(TOKEN));
}
%stack_size 500
%stack_overflow {  
  std::cerr << "Parser stack overflow" << std::endl;
}   

/** ASSOCIATIVITY AND PRECEDENCE (low to high) **/
%left T_INCLUDE T_INCLUDE_ONCE T_REQUIRE T_REQUIRE_ONCE T_EVAL.
%left T_COMMA.
%left T_BOOLEAN_OR_LIT.
%left T_BOOLEAN_XOR_LIT.
%left T_BOOLEAN_AND_LIT.
%right T_PRINT.
%left T_ASSIGN T_CONCAT_EQUAL T_AND_EQUAL T_OR_EQUAL T_XOR_EQUAL T_PLUS_EQUAL T_MINUS_EQUAL T_MOD_EQUAL T_DIV_EQUAL T_MUL_EQUAL T_SL_EQUAL T_SR_EQUAL.
%left T_QUESTION T_COLON.
%left T_BOOLEAN_AND T_BOOLEAN_OR.
%left T_PIPE.
%left T_CARET.
%left T_AND.
%nonassoc T_EQUAL T_NOT_EQUAL T_IDENTICAL T_NOT_IDENTICAL.
%nonassoc T_GREATER_THAN T_LESS_THAN T_GREATER_OR_EQUAL T_LESS_OR_EQUAL.
%left T_SL T_SR.
%left T_PLUS T_MINUS T_DOT.
%left T_DIV T_MOD T_MULT.
%right T_BOOLEAN_NOT.
%nonassoc T_INSTANCEOF.
%right T_TILDE T_INC T_DEC T_FLOAT_CAST T_STRING_CAST T_BINARY_CAST T_UNICODE_CAST T_ARRAY_CAST T_OBJECT_CAST T_INT_CAST T_BOOL_CAST T_UNSET_CAST T_AT.
%right T_LEFTSQUARE.
%nonassoc T_NEW T_CLONE.
%left T_ELSE T_ELSEIF.
%right T_STATIC T_PROTECTED T_PRIVATE T_ABSTRACT T_FINAL T_PUBLIC.


/** GOAL **/
%type module {int}
module ::= statement_list(LIST). { pMod->setAST(LIST); delete LIST; }

%type statement_list {AST::statementList*}
statement_list(A) ::= . { A = new AST::statementList(); }
statement_list(A) ::= statement_list(B) statement(C). { B->push_back(C); A = B; }

/******** STATEMENTS ********/
%type statement {AST::stmt*}
statement(A) ::= statementBlock(B). { A = B; }
statement(A) ::= inlineHTML(B). { A = B; }
statement(A) ::= namespaceDecl(B). { A = B; }
statement(A) ::= useDecl(B). { A = B; }
statement(A) ::= functionDecl(B). { A = B; }
statement(A) ::= classDecl(B). { A = B; }
statement(A) ::= ifBlock(B). { A = B; }
statement(A) ::= forEach(B). { A = B; }
statement(A) ::= forStmt(B). { A = B; }
statement(A) ::= doStmt(B). { A = B; }
statement(A) ::= whileStmt(B). { A = B; }
statement(A) ::= switchStmt(B). { A = B; }
statement(A) ::= tryCatch(B). { A = B; }
statement(A) ::= staticDecl(B) T_SEMI. { A = B; }
statement(A) ::= echo(B) T_SEMI. { A = B; }
statement(A) ::= throw(B) T_SEMI. { A = B; }
statement(A) ::= expr(B) T_SEMI. { A = B; }
statement(A) ::= return(B) T_SEMI. { A = B; }
statement(A) ::= break(B) T_SEMI. { A = B; }
statement(A) ::= continue(B) T_SEMI. { A = B; }
statement(A) ::= global(B) T_SEMI. { A = B; }
statement(A) ::= constDecl(B) T_SEMI. { A = B; }
statement(A) ::= T_SEMI.
{
    A = new (CTXT) AST::emptyStmt();
}

// statement block
%type statementBlock{AST::block*}
statementBlock(A) ::= T_LEFTCURLY(LC) statement_list(B) T_RIGHTCURLY(RC).
{
    A = new (CTXT) AST::block(CTXT, B);
    A->setRange(TOKEN_RANGE(LC));
    A->setEndCol(TOKEN_RANGE(RC));
    delete B;
}

// namespace
%type namespaceName {AST::namespaceName*}
namespaceName(A) ::= T_IDENTIFIER(PART).
{
    A = new AST::namespaceName(TOKEN_RANGE(PART));
    A->push_back(*PART);
}
namespaceName(A) ::= namespaceName(PARTS) T_NS_SEPARATOR T_IDENTIFIER(PART).
{
    PARTS->push_back(*PART);
    PARTS->setEndCol(TOKEN_RANGE(PART).endCol);
    A = PARTS;
}

%type namespaceDecl{AST::namespaceDecl*}
namespaceDecl(A) ::= T_NAMESPACE(NS) namespaceName(NSNAME) T_SEMI.
{
    NSNAME->setAbsolute();
    A = new (CTXT) AST::namespaceDecl(NSNAME, CTXT);
    // namespace decls are always absolute?
    A->setRange(TOKEN_RANGE(NS));
    A->setEndRange(NSNAME->range());
    delete NSNAME;
}
namespaceDecl(A) ::= T_NAMESPACE(NS) namespaceName(NSNAME) statementBlock(BODY).
{
    NSNAME->setAbsolute();
    A = new (CTXT) AST::namespaceDecl(NSNAME, BODY, CTXT);
    // namespace decls are always absolute?
    A->setRange(TOKEN_RANGE(NS));
    A->setEndRange(NSNAME->range());
    delete NSNAME;
}

%type useDecl{AST::useDecl*}
useDecl(A) ::= T_USE(U) useIdentList(L) T_SEMI(S).
{
    A = new (CTXT) AST::useDecl(L, CTXT);
    A->setRange(TOKEN_RANGE(U));
    A->setEndRange(TOKEN_RANGE(S));
    // note this deletes the vector, not the pointers is contains,
    // which are now owned by the useDecl as children
    delete L;
}

%type useIdentList{AST::useIdentList*}
useIdentList(A) ::= useIdent(USE).
{
    A = new AST::useIdentList();
    A->push_back(USE);
}
useIdentList(A) ::= useIdent(USE) T_COMMA useIdentList(C).
{
    C->push_back(USE);
    A = C;
}
useIdentList(A) ::= .
{
    A = new AST::useIdentList();
}

%type useIdent{AST::useIdent*}
useIdent(A) ::= namespaceName(NSNAME).
{
    A = new (CTXT) AST::useIdent(NSNAME, CTXT);
    delete NSNAME;
}
useIdent(A) ::= namespaceName(NSNAME) T_AS T_IDENTIFIER(ID).
{
    A = new (CTXT) AST::useIdent(NSNAME, *ID, CTXT);
    delete NSNAME;
}
useIdent(A) ::= T_NS_SEPARATOR namespaceName(NSNAME).
{
    NSNAME->setAbsolute();
    A = new (CTXT) AST::useIdent(NSNAME, CTXT);
    delete NSNAME;
}
useIdent(A) ::= T_NS_SEPARATOR namespaceName(NSNAME) T_AS T_IDENTIFIER(ID).
{
    NSNAME->setAbsolute();
    A = new (CTXT) AST::useIdent(NSNAME, *ID, CTXT);
    delete NSNAME;
}

// top level/namespace constant
%type constDecl {AST::constDecl*}
constDecl(A) ::= T_CONST constVarList(LIST).
{
    A = new (CTXT) AST::constDecl(LIST, CTXT);
    A->setRange(CURRENT_LINE);
    // free the LIST, but the expr pairs in it are owned by constDecl
    delete LIST;
}

%type constVarList {AST::exprPairList*}
constVarList(A) ::= T_IDENTIFIER(ID) T_ASSIGN staticScalar(DEFAULT).
{
    A = new AST::exprPairList();
    AST::literalID* cid = new (CTXT) AST::literalID(*ID, CTXT);
    cid->setRange(CURRENT_LINE);
    DEFAULT->setRange(CURRENT_LINE);
    A->push_back(AST::exprPair(cid, DEFAULT));
}
constVarList(A) ::= constVarList(LIST) T_COMMA T_IDENTIFIER(ID) T_ASSIGN staticScalar(DEFAULT).
{
    AST::literalID* cid = new (CTXT) AST::literalID(*ID, CTXT);
    cid->setRange(CURRENT_LINE);
    DEFAULT->setRange(CURRENT_LINE);
    LIST->push_back(AST::exprPair(cid, DEFAULT));
    A = LIST;
}


// echo
%type echo {AST::builtin*}
echo(A) ::= T_ECHO commaExprList(EXPRS).
{
   A = new (CTXT) AST::builtin(CTXT, AST::builtin::ECHO, EXPRS);
   A->setRange(CURRENT_LINE);
   delete EXPRS;
}

// throw
%type throw {AST::builtin*}
throw(A) ::= T_THROW expr(RVAL).
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::THROW, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}

// return
%type return {AST::returnStmt*}
return(A) ::= T_RETURN.
{
    A = new (CTXT) AST::returnStmt(NULL);
    A->setRange(CURRENT_LINE);
}
return(A) ::= T_RETURN expr(B).
{
    A = new (CTXT) AST::returnStmt(B);
    A->setRange(CURRENT_LINE);
}
// break
%type break {AST::breakStmt*}
break(A) ::= T_BREAK.
{
    A = new (CTXT) AST::breakStmt(NULL);
    A->setRange(CURRENT_LINE);
}
break(A) ::= T_BREAK expr(B).
{
    A = new (CTXT) AST::breakStmt(B);
    A->setRange(CURRENT_LINE);
}
// continue
%type continue {AST::continueStmt*}
continue(A) ::= T_CONTINUE.
{
    A = new (CTXT) AST::continueStmt(NULL);
    A->setRange(CURRENT_LINE);
}
continue(A) ::= T_CONTINUE expr(B).
{
    A = new (CTXT) AST::continueStmt(B);
    A->setRange(CURRENT_LINE);
}

// global
%type global {AST::globalDecl*}
global(A) ::= T_GLOBAL globalVarList(B).
{
    A = new (CTXT) AST::globalDecl(B, CTXT);
    A->setRange(CURRENT_LINE);
    delete B;
}

// inline html
%type inlineHTML {AST::inlineHtml*}
inlineHTML(A) ::= T_INLINE_HTML(B).
{
    A = new (CTXT) AST::inlineHtml(*B);
    A->setRange(CURRENT_LINE);
}

// try/catch
%type tryCatch {AST::tryStmt*}
tryCatch(A) ::= T_TRY statementBlock(BODY)
                catch(COMP) moreCatches(MORECATCHES).
{

    AST::statementList catchList;
    catchList.push_back(COMP); // compulsory

    // copy in additional catches, if any
    if (MORECATCHES != NULL) {
      for(AST::statementList::iterator i = MORECATCHES->begin();
          i != MORECATCHES->end();
          ++i) {
            catchList.push_back(*i);
      }
      delete MORECATCHES;
    }

    A = new (CTXT) AST::tryStmt(CTXT, new (CTXT) AST::block(CTXT, BODY), &catchList);
    A->setRange(CURRENT_LINE);
    // catchList goes out of scope and frees

}

%type moreCatches {AST::statementList*}
moreCatches(A) ::= . { A = NULL; }
moreCatches(A) ::= nonEmptyCatches(B). { A = B; }

%type nonEmptyCatches {AST::statementList*}
nonEmptyCatches(A) ::= catch(C).
{
    A = new AST::statementList();
    A->push_back(C);
}
nonEmptyCatches(A) ::= nonEmptyCatches(LIST) catch(C).
{
    LIST->push_back(C);
    A = LIST;
}

%type catch {AST::catchStmt*}
catch(A) ::= T_CATCH(CT) T_LEFTPAREN namespaceName(CLASSNAME) T_VARIABLE(VAR) T_RIGHTPAREN
             statementBlock(CATCHBODY).
{
    AST::var *v = new (CTXT) AST::var((*VAR).substr(1), CTXT);
    v->setRange(TOKEN_RANGE(VAR));
    AST::literalID *id = new (CTXT) AST::literalID(CLASSNAME, CTXT);
    id->setRange(CLASSNAME->range());
    A = new (CTXT) AST::catchStmt(CTXT,
                                  id,
                                  v,
                                  new (CTXT) AST::block(CTXT, CATCHBODY));
    A->setRange(TOKEN_RANGE(CT));
    A->setEndRange(CATCHBODY->range());
    delete CLASSNAME;
}
catch(A) ::= T_CATCH(CT) T_LEFTPAREN T_NS_SEPARATOR namespaceName(CLASSNAME) T_VARIABLE(VAR) T_RIGHTPAREN
             statementBlock(CATCHBODY).
{
    CLASSNAME->setAbsolute();
    AST::var *v = new (CTXT) AST::var((*VAR).substr(1), CTXT);
    v->setRange(TOKEN_RANGE(VAR));
    AST::literalID *id = new (CTXT) AST::literalID(CLASSNAME, CTXT);
    id->setRange(CLASSNAME->range());
    A = new (CTXT) AST::catchStmt(CTXT,
                                  id,
                                  v,
                                  new (CTXT) AST::block(CTXT, CATCHBODY));
    A->setRange(TOKEN_RANGE(CT));
    A->setEndRange(CATCHBODY->range());
    delete CLASSNAME;
}

// conditionals
%type elseSingle {AST::stmt*}
// empty else
elseSingle(A) ::= . { A = NULL; }
// simple else
elseSingle(A) ::= T_ELSE statement(BODY).
{
    A = BODY;
}

// else series
%type elseSeries{AST::stmt*}
// elseif with (potential) single statement
elseSeries(A) ::=  T_ELSEIF(EIF) T_LEFTPAREN expr(COND) T_RIGHTPAREN statement(TRUE) elseSingle(ELSE).
{
    A = new (CTXT) AST::ifStmt(CTXT, COND, TRUE, ELSE);
    A->setRange(TOKEN_RANGE(EIF));
}
// elseif series
elseSeries(A) ::=  T_ELSEIF(EIF) T_LEFTPAREN expr(COND) T_RIGHTPAREN statement(TRUE) elseSeries(ELSE).
{
    A = new (CTXT) AST::ifStmt(CTXT, COND, TRUE, ELSE);
    A->setRange(TOKEN_RANGE(EIF));
}

// if
%type ifBlock {AST::ifStmt*}
ifBlock(A) ::= T_IF(IF) T_LEFTPAREN expr(COND) T_RIGHTPAREN statement(TRUE) elseSeries(ELSE).
{
    A = new (CTXT) AST::ifStmt(CTXT, COND, TRUE, ELSE);
    A->setRange(TOKEN_RANGE(IF));
}
ifBlock(A) ::= T_IF(IF) T_LEFTPAREN expr(COND) T_RIGHTPAREN statement(TRUE) elseSingle(ELSE).
{
    A = new (CTXT) AST::ifStmt(CTXT, COND, TRUE, ELSE);
    A->setRange(TOKEN_RANGE(IF));
}

// foreach
%type forEach {AST::forEach*}
// foreach($expr as $val)
forEach(A) ::= T_FOREACH(F) T_LEFTPAREN expr(RVAL) T_AS var(VAL) T_RIGHTPAREN statement(BODY).
{
    A = new (CTXT) AST::forEach(RVAL, BODY, CTXT, VAL, false /*by ref*/ );
    A->setRange(TOKEN_RANGE(F));
}
// foreach($expr as $key => $val)
forEach(A) ::= T_FOREACH(F) T_LEFTPAREN expr(RVAL) T_AS var(KEY) T_ARROWKEY var(VAL) T_RIGHTPAREN statement(BODY).
{
    A = new (CTXT) AST::forEach(RVAL, BODY, CTXT, VAL, false /*by ref*/, KEY);
    A->setRange(TOKEN_RANGE(F));
}
// foreach($expr as &$val)
forEach(A) ::= T_FOREACH(F) T_LEFTPAREN expr(RVAL) T_AS T_AND var(VAL) T_RIGHTPAREN statement(BODY).
{
    A = new (CTXT) AST::forEach(RVAL, BODY, CTXT, VAL, true /*by ref*/);
    A->setRange(TOKEN_RANGE(F));
}
// foreach($expr as $key => &$val)
forEach(A) ::= T_FOREACH(F) T_LEFTPAREN expr(RVAL) T_AS var(KEY) T_ARROWKEY T_AND var(VAL) T_RIGHTPAREN statement(BODY).
{
    A = new (CTXT) AST::forEach(RVAL, BODY, CTXT, VAL, true /*by ref*/, KEY);
    A->setRange(TOKEN_RANGE(F));
}

// for
%type forStmt {AST::forStmt*}
forStmt(A) ::= T_FOR(F) T_LEFTPAREN forExpr(INIT) T_SEMI forExpr(COND) T_SEMI forExpr(INC) T_RIGHTPAREN statement(BODY).
{
    A = new (CTXT) AST::forStmt(CTXT, INIT, COND, INC, BODY);
    A->setRange(TOKEN_RANGE(F));
}

%type forExpr {AST::stmt*}
forExpr(A) ::= .
{
    A = NULL;
}
forExpr(A) ::= commaExprList(B).
{
    assert(B->size());
    if (B->size() == 1) {
        A = static_cast<AST::stmt*>( B->at(0) );
    }
    else {
        A = new (CTXT) AST::block(CTXT, B);
    }
    delete B;
}

// do
%type doStmt {AST::doStmt*}
doStmt(A) ::= T_DO statement(BODY) T_WHILE T_LEFTPAREN expr(COND) T_RIGHTPAREN.
{
    A = new (CTXT) AST::doStmt(CTXT, COND, BODY);
    A->setRange(CURRENT_LINE);
}

// while
%type whileStmt {AST::whileStmt*}
whileStmt(A) ::= T_WHILE T_LEFTPAREN expr(COND) T_RIGHTPAREN statement(BODY).
{
    A = new (CTXT) AST::whileStmt(CTXT, COND, BODY);
    A->setRange(CURRENT_LINE);
}

// switch
%type switchStmt {AST::switchStmt*}
switchStmt(A) ::= T_SWITCH T_LEFTPAREN expr(RVAL) T_RIGHTPAREN switchCaseList(CASES).
{
    A = new (CTXT) AST::switchStmt(RVAL, CASES);
    A->setRange(CURRENT_LINE);
}

%type switchCaseList {AST::block*}
switchCaseList(A) ::= T_LEFTCURLY(LC) caseList(CASES) T_RIGHTCURLY(RC).
{
    A = new (CTXT) AST::block(CTXT, CASES);
    A->setRange(TOKEN_RANGE(LC));
    A->setEndRange(TOKEN_RANGE(RC));
    delete CASES;
}
switchCaseList(A) ::= T_LEFTCURLY(LC) T_SEMI caseList(CASES) T_RIGHTCURLY(RC).
{
    A = new (CTXT) AST::block(CTXT, CASES);
    A->setRange(TOKEN_RANGE(LC));
    A->setEndRange(TOKEN_RANGE(RC));
    delete CASES;
}
switchCaseList(A) ::= T_COLON(LC) caseList(CASES) T_ENDSWITCH(RC).
{
    A = new (CTXT) AST::block(CTXT, CASES);
    A->setRange(TOKEN_RANGE(LC));
    A->setEndRange(TOKEN_RANGE(RC));
    delete CASES;
}
switchCaseList(A) ::= T_COLON(LC) T_SEMI caseList(CASES) T_ENDSWITCH(RC).
{
    A = new (CTXT) AST::block(CTXT, CASES);
    A->setRange(TOKEN_RANGE(LC));
    A->setEndRange(TOKEN_RANGE(RC));
    delete CASES;
}

%type caseList {AST::statementList*} //  root nodes here must be switchCase* casted to stmt*
caseList(A) ::= .
{
    A = new AST::statementList();
}
caseList(A) ::= caseList(LIST) T_CASE expr(COND) caseSeparator statement_list(STMTS).
{
    AST::switchCase* c = new (CTXT) AST::switchCase(COND,
                                                    new (CTXT) AST::block(CTXT, STMTS));
    c->setRange(CURRENT_LINE);
    LIST->push_back(static_cast<AST::stmt*>(c));
    delete STMTS;
    A = LIST;
}
caseList(A) ::= caseList(LIST) T_DEFAULT caseSeparator statement_list(STMTS).
{
    AST::switchCase* c = new (CTXT) AST::switchCase(NULL,
                                                     new (CTXT) AST::block(CTXT, STMTS));
    c->setRange(CURRENT_LINE);
    LIST->push_back(static_cast<AST::stmt*>(c));
    delete STMTS;
    A = LIST;
}

caseSeparator ::= T_COLON.
caseSeparator ::= T_SEMI.

/** DECLARATIONS **/

/** STATIC **/
%type staticDecl {AST::staticDecl*}
staticDecl(A) ::= T_STATIC staticVarList(VARLIST).
{
    A = new (CTXT) AST::staticDecl(VARLIST, CTXT);
    A->setRange(CURRENT_LINE);
    delete VARLIST;
}

staticDecl(A) ::= T_STATIC staticVarList(VARLIST) T_ASSIGN staticScalar(DEF).
{
    A = new (CTXT) AST::staticDecl(VARLIST, CTXT, DEF);
    A->setRange(CURRENT_LINE);
    delete VARLIST;
}


/** FUNCTION FORMAL PARAMS **/
%type formalParam {AST::formalParam*}
formalParam(A) ::= maybeHint(HINT) T_VARIABLE(PARAM).
{
    A = new (CTXT) AST::formalParam((*PARAM).substr(1),
                              CTXT, false/*ref*/);
    if (HINT) {
        A->setHint(*HINT);
        delete HINT;
    }
    A->setRange(TOKEN_RANGE(PARAM));
}
formalParam(A) ::= maybeHint(HINT) T_AND T_VARIABLE(PARAM).
{
    A = new (CTXT) AST::formalParam((*PARAM).substr(1),
                              CTXT, true/*ref*/);
    if (HINT) {
        A->setHint(*HINT);
        delete HINT;
    }
    A->setRange(TOKEN_RANGE(PARAM));
}
formalParam(A) ::= maybeHint(HINT) T_VARIABLE(PARAM) T_ASSIGN staticScalar(DEF).
{
    A = new (CTXT) AST::formalParam((*PARAM).substr(1),
                              CTXT, false/*ref*/, DEF);
    if (HINT) {
        A->setHint(*HINT);
        delete HINT;
    }
    A->setRange(TOKEN_RANGE(PARAM));
}
formalParam(A) ::= maybeHint(HINT) T_AND T_VARIABLE(PARAM) T_ASSIGN staticScalar(DEF).
{
    A = new (CTXT) AST::formalParam((*PARAM).substr(1),
                              CTXT, true/*ref*/, DEF);
    if (HINT) {
        A->setHint(*HINT);
        delete HINT;
    }
    A->setRange(TOKEN_RANGE(PARAM));
}

// this will be NULL (no hint) or a string rep of the hint
%type maybeHint {std::string*}
maybeHint(A) ::= . { A = NULL; }
maybeHint(A) ::= T_ARRAY. { A = new std::string("array"); }
maybeHint(A) ::= namespaceName(B). {
    A = new std::string(B->getFullName());
    delete B;
}
maybeHint(A) ::= T_NS_SEPARATOR namespaceName(B). {
    B->setAbsolute();
    A = new std::string(B->getFullName());
    delete B;
}

%type formalParamList {AST::formalParamList*}
formalParamList(A) ::= formalParam(PARAM).
{
    A = new AST::formalParamList();
    A->push_back(PARAM);
}
formalParamList(A) ::= formalParam(PARAM) T_COMMA formalParamList(C).
{
    C->push_back(PARAM);
    A = C;
}
formalParamList(A) ::= .
{
    A = new AST::formalParamList();
}

/** FUNCTION DECL **/
%type signature {AST::signature*}
signature(A) ::= T_IDENTIFIER(NAME) T_LEFTPAREN formalParamList(PARAMS) T_RIGHTPAREN.
{
    A = new (CTXT) AST::signature(*NAME, CTXT, PARAMS, false/*ref*/);
    A->setRange(TOKEN_RANGE(NAME));
    delete PARAMS;
}
signature(A) ::= T_AND T_IDENTIFIER(NAME) T_LEFTPAREN formalParamList(PARAMS) T_RIGHTPAREN.
{
    A = new (CTXT) AST::signature(*NAME, CTXT, PARAMS, true/*ref*/);
    A->setRange(TOKEN_RANGE(NAME));
    delete PARAMS;
}

%type lambdaSignature {AST::signature*}
lambdaSignature(A) ::= T_LEFTPAREN(LP) formalParamList(PARAMS) T_RIGHTPAREN.
{
    A = new (CTXT) AST::signature(CTXT, PARAMS);
    A->setRange(TOKEN_RANGE(LP));
    delete PARAMS;
}
// XXX we cheat here and use formalParamList. that wouldn't be acceptable
// php for real, since you can't e.g. have a default value in a use list
// but it gets us started
lambdaSignature(A) ::= T_LEFTPAREN(LP) formalParamList(PARAMS) T_RIGHTPAREN T_USE T_LEFTPAREN formalParamList(USE_PARAMS) T_RIGHTPAREN.
{
    A = new (CTXT) AST::signature(CTXT, PARAMS, USE_PARAMS);
    A->setRange(TOKEN_RANGE(LP));
    delete PARAMS;
    delete USE_PARAMS;
}

%type functionDecl {AST::functionDecl*}
functionDecl(A) ::= T_FUNCTION signature(SIG) statementBlock(BODY).
{
    A = new (CTXT) AST::functionDecl(SIG, BODY);
}                    

/** CLASSES **/
%type classDecl {AST::classDecl*}
classDecl(A) ::= T_CLASS(C) T_IDENTIFIER(NAME) classExtends(EXTENDS) classImplements(IMPLEMENTS)
                 T_LEFTCURLY classStatements(MEMBERS) T_RIGHTCURLY(RC).
{
    A = new (CTXT) AST::classDecl(CTXT,
                                  *NAME,
                                  AST::classDecl::NORMAL,
                                  EXTENDS,
                                  IMPLEMENTS,
                                  new (CTXT) AST::block(CTXT, MEMBERS));
    A->setRange(TOKEN_RANGE(C));
    A->setEndCol(TOKEN_RANGE(RC));
    // EXTENDS and IMPLEMENTS memory managed in classDecl constructor
    delete MEMBERS;
}
classDecl(A) ::= T_FINAL T_CLASS(C) T_IDENTIFIER(NAME) classExtends(EXTENDS) classImplements(IMPLEMENTS)
                 T_LEFTCURLY classStatements(MEMBERS) T_RIGHTCURLY(RC).
{
    A = new (CTXT) AST::classDecl(CTXT,
                                  *NAME,
                                  AST::classDecl::FINAL,
                                  EXTENDS,
                                  IMPLEMENTS,
                                  new (CTXT) AST::block(CTXT, MEMBERS));
    A->setRange(TOKEN_RANGE(C));
    A->setEndCol(TOKEN_RANGE(RC));
    // EXTENDS and IMPLEMENTS memory managed in classDecl constructor
    delete MEMBERS;
}
classDecl(A) ::= T_ABSTRACT T_CLASS(C) T_IDENTIFIER(NAME) classExtends(EXTENDS) classImplements(IMPLEMENTS)
                 T_LEFTCURLY classStatements(MEMBERS) T_RIGHTCURLY(RC).
{
    A = new (CTXT) AST::classDecl(CTXT,
                                  *NAME,
                                  AST::classDecl::ABSTRACT,
                                  EXTENDS,
                                  IMPLEMENTS,
                                  new (CTXT) AST::block(CTXT, MEMBERS));
    A->setRange(TOKEN_RANGE(C));
    A->setEndCol(TOKEN_RANGE(RC));
    // EXTENDS and IMPLEMENTS memory managed in classDecl constructor
    delete MEMBERS;
}
classDecl(A) ::= T_INTERFACE(C) T_IDENTIFIER(NAME) interfaceExtends(EXTENDS)
                 T_LEFTCURLY classStatements(MEMBERS) T_RIGHTCURLY(RC).
{
    A = new (CTXT) AST::classDecl(CTXT,
                                  *NAME,
                                  AST::classDecl::IFACE,
                                  EXTENDS,
                                  NULL, /* interfaces can't implement */
                                  new (CTXT) AST::block(CTXT, MEMBERS));
    A->setRange(TOKEN_RANGE(C));
    A->setEndCol(TOKEN_RANGE(RC));
    // XXX this is double freeing??
    //if (EXTENDS)
        //delete EXTENDS;
    delete MEMBERS;
}

%type classStatements {AST::statementList*}
classStatements(A) ::= .
{
    A = new AST::statementList();

}
classStatements(A) ::= classStatements(LIST) classStatement(STMT).
{
    LIST->push_back(STMT);
    A = LIST;
}

// things that can go inside of a class declaration
%type classStatement {AST::stmt*}
classStatement(A) ::= classVarFlags(FLAGS) classVar(VARS) T_SEMI.
{
    pUInt flags(0);
    if (FLAGS) {
        flags = *FLAGS;
    }
    // set flags on each var decl
    for (AST::statementList::iterator i = VARS->begin();
         i != VARS->end();
         ++i)
    {
        static_cast<AST::propertyDecl*>((*i))->setFlags(flags);
    }
    if (VARS->size() == 1) {
        // one var decl
        A = VARS->at(0);
    }
    else {
        // list, make a block
        A = new (CTXT) AST::block(CTXT, VARS);
    }
    // all done with vector
    delete VARS;
}
classStatement(A) ::= classConstantDecl(VARS) T_SEMI.
{
    if (VARS->size() == 1) {
        // one var decl
        A = VARS->at(0);
    }
    else {
        // list, make a block
        A = new (CTXT) AST::block(CTXT, VARS);
    }
    // all done with vector
    delete VARS;
}
classStatement(A) ::= methodFlags(FLAGS) T_FUNCTION signature(SIG) methodBody(BODY).
{
    pUInt flags(0);
    if (FLAGS) {
        flags = *FLAGS;
    }
    A = new (CTXT) AST::methodDecl(SIG, flags, BODY);
}
classStatement(A) ::= methodFlags(FLAGS) T_AND T_FUNCTION signature(SIG) methodBody(BODY).
{
    pUInt flags(0);
    if (FLAGS) {
        flags = *FLAGS;
    }
    A = new (CTXT) AST::methodDecl(SIG, flags, BODY);
}

%type classVar {AST::statementList*}
classVar(A) ::= classVar(LIST) T_COMMA T_VARIABLE(VAR).
{
    // strip $
    LIST->push_back(new (CTXT) AST::propertyDecl(CTXT, (*VAR).substr(1), NULL));
    A = LIST;
}
classVar(A) ::= classVar(LIST) T_COMMA T_VARIABLE(VAR) T_ASSIGN staticScalar(DEFAULT).
{
    // strip $
    LIST->push_back(new (CTXT) AST::propertyDecl(CTXT, (*VAR).substr(1), DEFAULT));
    A = LIST;
}
classVar(A) ::= T_VARIABLE(VAR).
{
    A = new AST::statementList();
    // strip $
    A->push_back(new (CTXT) AST::propertyDecl(CTXT, (*VAR).substr(1), NULL));
}
classVar(A) ::= T_VARIABLE(VAR) T_ASSIGN staticScalar(DEFAULT).
{
    A = new AST::statementList();
    // strip $
    A->push_back(new (CTXT) AST::propertyDecl(CTXT, (*VAR).substr(1), DEFAULT));
}
%type classConstantDecl {AST::statementList*}
classConstantDecl(A) ::= classConstantDecl(LIST) T_COMMA T_IDENTIFIER(ID) T_ASSIGN staticScalar(DEFAULT).
{
    AST::propertyDecl* prop = new (CTXT) AST::propertyDecl(CTXT, *ID, DEFAULT);
    prop->setFlags(AST::memberFlags::CONST);
    LIST->push_back(prop);
    A = LIST;
}
classConstantDecl(A) ::= T_CONST T_IDENTIFIER(ID) T_ASSIGN staticScalar(DEFAULT).
{
    A = new AST::statementList();
    AST::propertyDecl* prop = new (CTXT) AST::propertyDecl(CTXT, *ID, DEFAULT);
    prop->setFlags(AST::memberFlags::CONST);
    A->push_back(prop);
}

%type methodFlags {pUInt*}
methodFlags(A) ::= .
{
    // empty
    A = NULL;
}
methodFlags(A) ::= nonEmptyMemberFlags(F). { A = F; }

%type classVarFlags {const pUInt*}
classVarFlags(A) ::= T_VAR.
{
    A = &AST::memberFlags::PUBLIC;
}
classVarFlags(A) ::= nonEmptyMemberFlags(F).
{
/*
    if (*F & AST::memberFlags::ABSTRACT) {
        CTXT.parseError("Cannot declare class variables abstract");
    }
*/
    A = F;
}

%type nonEmptyMemberFlags {pUInt*}
nonEmptyMemberFlags(A) ::= memberFlag(F).
{
    A = new (CTXT) pUInt(*F); // freed by context
}
nonEmptyMemberFlags(A) ::= nonEmptyMemberFlags(L) memberFlag(R).
{
    *L |= *R;
    A = L;
}

%type memberFlag {const pUInt*}
memberFlag(A) ::= T_PUBLIC. { A = &AST::memberFlags::PUBLIC; }
memberFlag(A) ::= T_PROTECTED. { A = &AST::memberFlags::PROTECTED; }
memberFlag(A) ::= T_PRIVATE. { A = &AST::memberFlags::PRIVATE; }
memberFlag(A) ::= T_STATIC. { A = &AST::memberFlags::STATIC; }
memberFlag(A) ::= T_ABSTRACT. { A = &AST::memberFlags::ABSTRACT; }
memberFlag(A) ::= T_FINAL. { A = &AST::memberFlags::FINAL; }

// if a method body is null, it's abstract
%type methodBody {AST::block*}
methodBody(A) ::= T_SEMI. { A = NULL; }
methodBody(A) ::= statementBlock(B). { A = B; }

// class extends at most one id
%type classExtends {AST::namespaceList*}
classExtends(A) ::= . { A = NULL; }
classExtends(A) ::= T_EXTENDS namespaceName(NAME).
{
    A = new AST::namespaceList();
    A->push_back(NAME);
}
classExtends(A) ::= T_EXTENDS T_NS_SEPARATOR namespaceName(NAME).
{
    NAME->setAbsolute();
    A = new AST::namespaceList();
    A->push_back(NAME);
}

// interface extends 0-n ids
%type interfaceExtends {AST::namespaceList*}
interfaceExtends(A) ::= . { A = NULL; }
interfaceExtends(A) ::= T_EXTENDS idList(LIST).
{
    A = LIST;
}

// class implements 0-n ids
%type classImplements {AST::namespaceList*}
classImplements(A) ::= . { A = NULL; }
classImplements(A) ::= T_IMPLEMENTS idList(LIST).
{
    A = LIST;
}

// 1-n identifiers, comma separated
%type idList {AST::namespaceList*}
idList(A) ::= namespaceName(NAME).
{
    A = new AST::namespaceList();
    A->push_back(NAME);
}
idList(A) ::= T_NS_SEPARATOR namespaceName(NAME).
{
    NAME->setAbsolute();
    A = new AST::namespaceList();
    A->push_back(NAME);
}
idList(A) ::= idList(LIST) T_COMMA namespaceName(NAME).
{
    LIST->push_back(NAME);
    A = LIST;
}
idList(A) ::= idList(LIST) T_COMMA T_NS_SEPARATOR namespaceName(NAME).
{
    NAME->setAbsolute();
    LIST->push_back(NAME);
    A = LIST;
}


/****** EXPRESSIONS *********/
%type baseExpr {AST::expr*} // expr_without_variable
baseExpr(A) ::= assignment(B). { A = B; }
baseExpr(A) ::= opAssignment(B). { A = B; }
baseExpr(A) ::= listAssignment(B). { A = B; }
baseExpr(A) ::= functionInvoke(B). { A = B; }
baseExpr(A) ::= constructorInvoke(B). { A = B; }
baseExpr(A) ::= unaryOp(B). { A = B; }
baseExpr(A) ::= binaryOp(B). { A = B; }
baseExpr(A) ::= builtin(B). { A = B; }
baseExpr(A) ::= typeCast(B). { A = B; }
baseExpr(A) ::= preOp(B). { A = B; }
baseExpr(A) ::= postOp(B). { A = B; }
baseExpr(A) ::= conditionalExpr(B). { A = B; }
baseExpr(A) ::= scalar(B). { A = B; }
baseExpr(A) ::= literalArray(B). { A = B; }
baseExpr(A) ::= T_LEFTPAREN expr(B) T_RIGHTPAREN. { A = B; }
baseExpr(A) ::= lambda(B). { A = B; }

%type lambda {AST::lambda*}
lambda(A) ::= T_FUNCTION lambdaSignature(SIG) statementBlock(BODY).
{
    A = new (CTXT) AST::lambda(SIG, BODY);
}


%type expr {AST::expr*} // expr
expr(A) ::= baseExpr(B). { A = B; }
expr(A) ::= rVar(B). { A = B; }

/** BUILTINS **/
%type builtin {AST::builtin*}
// exit
builtin(A) ::= T_EXIT.
{
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::EXIT);
    A->setRange(CURRENT_LINE);
}
builtin(A) ::= T_EXIT T_LEFTPAREN T_RIGHTPAREN.
{
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::EXIT);
    A->setRange(CURRENT_LINE);
}
builtin(A) ::= T_EXIT T_LEFTPAREN expr(RVAL) T_RIGHTPAREN.
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::EXIT, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}
// empty
builtin(A) ::= T_EMPTY T_LEFTPAREN var(RVAL) T_RIGHTPAREN.
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::EMPTY, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}
// isset
 builtin(A) ::= T_ISSET T_LEFTPAREN commaVarList(VARS) T_RIGHTPAREN.
{
   A = new (CTXT) AST::builtin(CTXT, AST::builtin::ISSET, VARS);
   A->setRange(CURRENT_LINE);
   delete VARS;
}
// unset
builtin(A) ::= T_UNSET T_LEFTPAREN commaVarList(VARS) T_RIGHTPAREN.
{
   A = new (CTXT) AST::builtin(CTXT, AST::builtin::UNSET, VARS);
   A->setRange(CURRENT_LINE);
   delete VARS;
}
// print
builtin(A) ::= T_PRINT expr(RVAL).
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::PRINT, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}
// clone
builtin(A) ::= T_CLONE expr(RVAL).
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::CLONE, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}
// include/require
builtin(A) ::= T_REQUIRE expr(RVAL).
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::REQUIRE, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}
builtin(A) ::= T_REQUIRE_ONCE expr(RVAL).
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::REQUIRE_ONCE, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}
builtin(A) ::= T_INCLUDE expr(RVAL).
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::INCLUDE, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}
builtin(A) ::= T_INCLUDE_ONCE expr(RVAL).
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::INCLUDE_ONCE, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}
builtin(A) ::= T_AT expr(RVAL).
{
    AST::expressionList* rVal = new AST::expressionList();
    rVal->push_back(RVAL);
    A = new (CTXT) AST::builtin(CTXT, AST::builtin::IGNORE_WARNING, rVal);
    delete rVal;
    A->setRange(CURRENT_LINE);
}

%type commaVarList {AST::expressionList*}
commaVarList(A) ::= var(VAR).
{
    A = new AST::expressionList();
    A->push_back(VAR);
}
commaVarList(A) ::= commaVarList(LIST) T_COMMA var(VAR).
{
    LIST->push_back(VAR);
    A = LIST;
}

%type globalVarList {AST::expressionList*}
globalVarList(A) ::= globalVar(B).
{
    A = new AST::expressionList();
    A->push_back(B);
}
globalVarList(A) ::= globalVarList(LIST) T_COMMA globalVar(B).
{
    LIST->push_back(B);
    A = LIST;
}
%type globalVar {AST::expr*}
globalVar(A) ::= T_VARIABLE(B).
{
    // strip $
    A = new (CTXT) AST::var((*B).substr(1), CTXT);
    A->setRange(CURRENT_LINE);
}
globalVar(A) ::= T_DOLLAR rVar(B).
{
    AST::dynamicID* r = new (CTXT) AST::dynamicID(B);
    r->setRange(CURRENT_LINE);
    A = r;
}
// XXX support ${expr} format for globals here?

%type staticVarList {AST::expressionList*}
staticVarList(A) ::= T_VARIABLE(B).
{
    A = new AST::expressionList();
    AST::var* V= new (CTXT) AST::var((*B).substr(1), CTXT);
    V->setRange(CURRENT_LINE);
    A->push_back(V);
}
staticVarList(A) ::= staticVarList(LIST) T_COMMA T_VARIABLE(B).
{
    // strip $
    AST::var* V= new (CTXT) AST::var((*B).substr(1), CTXT);
    V->setRange(CURRENT_LINE);
    LIST->push_back(V);
    A = LIST;
}

%type commaExprList {AST::expressionList*}
commaExprList(A) ::= expr(E).
{
    A = new AST::expressionList();
    A->push_back(E);
}
commaExprList(A) ::= commaExprList(LIST) T_COMMA expr(E).
{
    LIST->push_back(E);
    A = LIST;
}

// ternary operator
%type conditionalExpr {AST::conditionalExpr*}
conditionalExpr(A) ::= expr(COND) T_QUESTION expr(TRUE) T_COLON expr(FALSE).
{
    A = new (CTXT) AST::conditionalExpr(COND, TRUE, FALSE);
    A->setRange(CURRENT_LINE);
}
// 5.3 ternary with implicit true condition
conditionalExpr(A) ::= expr(COND) T_QUESTION T_COLON expr(FALSE).
{
    A = new (CTXT) AST::conditionalExpr(COND, COND->clone(CTXT), FALSE);
    A->setRange(CURRENT_LINE);
}

/** TYPECASTS **/
%type typeCast {AST::typeCast*}
typeCast(A) ::= T_FLOAT_CAST expr(rVal).
{
    A = new (CTXT) AST::typeCast(AST::typeCast::REAL, rVal);
    A->setRange(CURRENT_LINE);
}
typeCast(A) ::= T_INT_CAST expr(rVal).
{
    A = new (CTXT) AST::typeCast(AST::typeCast::INT, rVal);
    A->setRange(CURRENT_LINE);
}
typeCast(A) ::= T_STRING_CAST expr(rVal).
{
    A = new (CTXT) AST::typeCast(AST::typeCast::STRING, rVal);
    A->setRange(CURRENT_LINE);
}
typeCast(A) ::= T_BINARY_CAST expr(rVal).
{
    A = new (CTXT) AST::typeCast(AST::typeCast::BINARY, rVal);
    A->setRange(CURRENT_LINE);
}
typeCast(A) ::= T_UNICODE_CAST expr(rVal).
{
    A = new (CTXT) AST::typeCast(AST::typeCast::UNICODE, rVal);
    A->setRange(CURRENT_LINE);
}
typeCast(A) ::= T_ARRAY_CAST expr(rVal).
{
    A = new (CTXT) AST::typeCast(AST::typeCast::ARRAY, rVal);
    A->setRange(CURRENT_LINE);
}
typeCast(A) ::= T_OBJECT_CAST expr(rVal).
{
    A = new (CTXT) AST::typeCast(AST::typeCast::OBJECT, rVal);
    A->setRange(CURRENT_LINE);
}
typeCast(A) ::= T_UNSET_CAST expr(rVal).
{
    A = new (CTXT) AST::typeCast(AST::typeCast::UNSET, rVal);
    A->setRange(CURRENT_LINE);
}
typeCast(A) ::= T_BOOL_CAST expr(rVal).
{
    A = new (CTXT) AST::typeCast(AST::typeCast::BOOL, rVal);
    A->setRange(CURRENT_LINE);
}


/** SCALAR **/
%type scalar {AST::expr*}
scalar(A) ::= literal(B). { A = B; }
scalar(A) ::= literalMagic(B). { A = B; }
scalar(A) ::= classConstant(B). { A = B; }
// static constant
// namespace constant, i.e. foo\bar\some_const
scalar(A) ::= namespaceName(B).
{
    A = new (CTXT) AST::literalConstant(B->getFullName(), CTXT);
    A->setRange(CURRENT_LINE);
    delete B;
}
scalar(A) ::= T_NS_SEPARATOR namespaceName(B).
{
    B->setAbsolute();
    A = new (CTXT) AST::literalConstant(B->getFullName(), CTXT);
    A->setRange(CURRENT_LINE);
    delete B;
}

// static class constant
%type classConstant {AST::expr*}
classConstant(A) ::= namespaceName(TARGET) T_DBL_COLON T_IDENTIFIER(ID).
{
    A = new (CTXT) AST::literalConstant(*ID, CTXT, new (CTXT) AST::literalID(TARGET, TOKEN_RANGE(ID), CTXT));
    A->setRange(CURRENT_LINE);
    delete TARGET;
}
classConstant(A) ::= T_NS_SEPARATOR namespaceName(TARGET) T_DBL_COLON T_IDENTIFIER(ID).
{
    TARGET->setAbsolute();
    A = new (CTXT) AST::literalConstant(*ID, CTXT, new (CTXT) AST::literalID(TARGET, TOKEN_RANGE(ID), CTXT));
    A->setRange(CURRENT_LINE);
    delete TARGET;
}
// variable class constant
classConstant(A) ::= refVar(TARGET) T_DBL_COLON T_IDENTIFIER(ID).
{
    A = new (CTXT) AST::literalConstant(*ID, CTXT, TARGET);
    A->setRange(CURRENT_LINE);
}

// same as a scalar except can be +, - and array
%type staticScalar {AST::expr*}
staticScalar(A) ::= scalar(B). { A = B; }
staticScalar(A) ::= literalArray(B). { A = B; }
staticScalar ::= T_PLUS staticScalar. // ignore
staticScalar(A) ::= T_MINUS staticScalar(R).
{
    A = new (CTXT) AST::unaryOp(R, AST::unaryOp::NEGATIVE);
    A->setRange(CURRENT_LINE);
}
staticScalar(A) ::= T_HEREDOC_START T_HEREDOC_STRING(B) T_HEREDOC_END.
{
  AST::literalString *hd = new (CTXT) AST::literalString(*B);
  hd->setIsSimple(false);
  hd->setRange(CURRENT_LINE);
  A = hd;
}

%type literal {AST::literalExpr*} // common_scalar
// literal string
literal(A) ::= T_SQ_STRING(B).
{
  A = extractLiteralString(B, pMod, true);
  A->setRange(CURRENT_LINE);
}
literal(A) ::= T_DQ_STRING(B).
{
  A = extractLiteralString(B, pMod, false);
  A->setRange(CURRENT_LINE);
}
literal(A) ::= T_TICK_STRING(B).
{
  A = extractLiteralString(B, pMod, false);
  A->setRange(CURRENT_LINE);
}
literal(A) ::= T_HEREDOC_START T_HEREDOC_STRING(B) T_HEREDOC_END.
{
  AST::literalString *hd = new (CTXT) AST::literalString(*B);
  hd->setIsSimple(false);
  hd->setRange(CURRENT_LINE);
  A = hd;
}

// literal integers (decimal)
literal(A) ::= T_LNUMBER(B).
{
    A = new (CTXT) AST::literalInt(*B);
    A->setRange(CURRENT_LINE);
}

// literal integers (float)
literal(A) ::= T_DNUMBER(B).
{
    A = new (CTXT) AST::literalFloat(*B);
    A->setRange(CURRENT_LINE);
}

// literal identifier: null, true, false or constant
literal(A) ::= T_TRUE.
{
    A = new (CTXT) AST::literalBool(true);
    A->setRange(CURRENT_LINE);
}
literal(A) ::= T_FALSE.
{
    A = new (CTXT) AST::literalBool(false);
    A->setRange(CURRENT_LINE);
}
literal(A) ::= T_NULL.
{
    A = new (CTXT) AST::literalNull();
    A->setRange(CURRENT_LINE);
}

%type literalMagic {AST::expr*}
literalMagic(A) ::= T_MAGIC_FILE(ID).
{
    A = new (CTXT) AST::literalID(*ID, TOKEN_RANGE(ID), CTXT);
    A->setRange(CURRENT_LINE);
}
literalMagic(A) ::= T_MAGIC_LINE(ID).
{
    A = new (CTXT) AST::literalID(*ID, TOKEN_RANGE(ID), CTXT);
    A->setRange(CURRENT_LINE);
}
literalMagic(A) ::= T_MAGIC_CLASS(ID).
{
    A = new (CTXT) AST::literalID(*ID, TOKEN_RANGE(ID), CTXT);
    A->setRange(CURRENT_LINE);
}
literalMagic(A) ::= T_MAGIC_METHOD(ID).
{
    A = new (CTXT) AST::literalID(*ID, TOKEN_RANGE(ID), CTXT);
    A->setRange(CURRENT_LINE);
}
literalMagic(A) ::= T_MAGIC_FUNCTION(ID).
{
    A = new (CTXT) AST::literalID(*ID, TOKEN_RANGE(ID), CTXT);
    A->setRange(CURRENT_LINE);
}
literalMagic(A) ::= T_MAGIC_NS(ID).
{
    A = new (CTXT) AST::literalID(*ID, TOKEN_RANGE(ID), CTXT);
    A->setRange(CURRENT_LINE);
}


/** LITERAL ARRAY ITEMS **/
%type arrayItemList {AST::arrayList*}
arrayItemList(A) ::= .
{
    A = new AST::arrayList();
}
arrayItemList(A) ::= arrayItems(LIST) maybeComma.
{
    A = LIST;
}

maybeComma ::= T_COMMA.
maybeComma ::= .

%type arrayItems {AST::arrayList*}
arrayItems(A) ::= expr(B).
{
    A = new AST::arrayList();
    A->push_back(AST::arrayItem(NULL, B, false));
}
arrayItems(A) ::= T_AND expr(B).
{
    A = new AST::arrayList();
    A->push_back(AST::arrayItem(NULL, B, true));
}
arrayItems(A) ::= expr(KEY) T_ARROWKEY expr(VAL).
{
    A = new AST::arrayList();
    A->push_back(AST::arrayItem(KEY, VAL, false));
}
arrayItems(A) ::= expr(KEY) T_ARROWKEY T_AND expr(VAL).
{
    A = new AST::arrayList();
    A->push_back(AST::arrayItem(KEY, VAL, true));
}
arrayItems(A) ::= arrayItems(LIST) T_COMMA expr(B).
{
    LIST->push_back(AST::arrayItem(NULL, B, false));
    A = LIST;
}
arrayItems(A) ::= arrayItems(LIST) T_COMMA T_AND expr(B).
{
    LIST->push_back(AST::arrayItem(NULL, B, true));
    A = LIST;
}
arrayItems(A) ::= arrayItems(LIST) T_COMMA expr(KEY) T_ARROWKEY expr(VAL).
{
    LIST->push_back(AST::arrayItem(KEY, VAL, false));
    A = LIST;
}
arrayItems(A) ::= arrayItems(LIST) T_COMMA expr(KEY) T_ARROWKEY T_AND expr(VAL).
{
    LIST->push_back(AST::arrayItem(KEY, VAL, true));
    A = LIST;
}

// literal array
%type literalArray {AST::literalExpr*}
literalArray(A) ::= T_ARRAY(ARY) T_LEFTPAREN arrayItemList(B) T_RIGHTPAREN.
{
    A = new (CTXT) AST::literalArray(B);
    A->setRange(TOKEN_RANGE(ARY));
    delete B; // deletes the vector, NOT the exprs in it!
}

/** UNARY OPERATORS **/
%type unaryOp {AST::unaryOp*}
unaryOp(A) ::= T_PLUS expr(R).
{
    A = new (CTXT) AST::unaryOp(R, AST::unaryOp::POSITIVE);
    A->setRange(CURRENT_LINE);
}
unaryOp(A) ::= T_MINUS expr(R).
{
    A = new (CTXT) AST::unaryOp(R, AST::unaryOp::NEGATIVE);
    A->setRange(CURRENT_LINE);
}
unaryOp(A) ::= T_BOOLEAN_NOT expr(R).
{
    A = new (CTXT) AST::unaryOp(R, AST::unaryOp::LOGICALNOT);
    A->setRange(CURRENT_LINE);
}
unaryOp(A) ::= T_TILDE expr(R).
{
    A = new (CTXT) AST::unaryOp(R, AST::unaryOp::BITWISENOT);
    A->setRange(CURRENT_LINE);
}
/** BINARY OPERATORS **/
%type binaryOp {AST::binaryOp*}
binaryOp(A) ::= expr(L) T_DOT expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::CONCAT);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_BOOLEAN_AND expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::BOOLEAN_AND);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_BOOLEAN_AND_LIT expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::BOOLEAN_AND);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_BOOLEAN_OR expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::BOOLEAN_OR);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_BOOLEAN_OR_LIT expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::BOOLEAN_OR);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_BOOLEAN_XOR_LIT expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::BOOLEAN_XOR);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_DIV expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::DIV);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_MOD expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::MOD);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_MULT expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::MULT);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_PLUS expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::ADD);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_MINUS expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::SUB);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_GREATER_THAN expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::GREATER_THAN);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_LESS_THAN expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::LESS_THAN);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_GREATER_OR_EQUAL expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::GREATER_OR_EQUAL);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_LESS_OR_EQUAL expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::LESS_OR_EQUAL);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_EQUAL expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::EQUAL);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_NOT_EQUAL expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::NOT_EQUAL);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_IDENTICAL expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::IDENTICAL);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_NOT_IDENTICAL expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::NOT_IDENTICAL);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_CARET expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::BIT_XOR);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_PIPE expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::BIT_OR);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_AND expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::BIT_AND);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_SL expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::SHIFT_LEFT);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_SR expr(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::SHIFT_RIGHT);
    A->setRange(CURRENT_LINE);
}
binaryOp(A) ::= expr(L) T_INSTANCEOF maybeDynamicID(R).
{
    A = new (CTXT) AST::binaryOp(L, R, AST::binaryOp::INSTANCEOF);
    A->setRange(CURRENT_LINE);
}

/** PRE/POST OP **/
%type preOp {AST::preOp*}
preOp(A) ::= T_INC var(R).
{
    A = new (CTXT) AST::preOp(R, AST::preOp::INC);
    A->setRange(CURRENT_LINE);
}
preOp(A) ::= T_DEC var(R).
{
    A = new (CTXT) AST::preOp(R, AST::preOp::DEC);
    A->setRange(CURRENT_LINE);
}
%type postOp {AST::postOp*}
postOp(A) ::= var(R) T_INC.
{
    A = new (CTXT) AST::postOp(R, AST::postOp::INC);
    A->setRange(CURRENT_LINE);
}
postOp(A) ::= var(R) T_DEC.
{
    A = new (CTXT) AST::postOp(R, AST::postOp::DEC);
    A->setRange(CURRENT_LINE);
}

/** ASSIGNMENT **/
%type assignment {AST::assignment*}
assignment(A) ::= var(L) T_ASSIGN(EQ_SIGN) expr(R).
{
    A = new (CTXT) AST::assignment(L, R, false);
    A->setRange(TOKEN_RANGE(EQ_SIGN));
}
assignment(A) ::= var(L) T_ASSIGN T_AND(EQ_SIGN) var(R).
{
    A = new (CTXT) AST::assignment(L, R, true);
    A->setRange(TOKEN_RANGE(EQ_SIGN));
}
assignment(A) ::= var(L) T_ASSIGN T_AND(EQ_SIGN) functionInvoke(R).
{
    A = new (CTXT) AST::assignment(L, R, true);
    A->setRange(TOKEN_RANGE(EQ_SIGN));
}
assignment(A) ::= var(L) T_ASSIGN T_AND(EQ_SIGN) constructorInvoke(R).
{
    A = new (CTXT) AST::assignment(L, R, true);
    A->setRange(TOKEN_RANGE(EQ_SIGN));
}

%type opAssignment {AST::opAssignment*}
opAssignment(A) ::= var(L) T_AND_EQUAL(EQ_SIGN) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::AND);
    A->setRange(TOKEN_RANGE(EQ_SIGN));
}
opAssignment(A) ::= var(L) T_OR_EQUAL(EQ_SIGN) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::OR);
    A->setRange(TOKEN_RANGE(EQ_SIGN));
}
opAssignment(A) ::= var(L) T_XOR_EQUAL(EQ_SIGN) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::XOR);
    A->setRange(TOKEN_RANGE(EQ_SIGN));
}
opAssignment(A) ::= var(L) T_CONCAT_EQUAL(OP) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::CONCAT);
    A->setRange(TOKEN_RANGE(OP));
}
opAssignment(A) ::= var(L) T_DIV_EQUAL(OP) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::DIV);
    A->setRange(TOKEN_RANGE(OP));
}
opAssignment(A) ::= var(L) T_MUL_EQUAL(OP) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::MULT);
    A->setRange(TOKEN_RANGE(OP));
}
opAssignment(A) ::= var(L) T_PLUS_EQUAL(OP) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::ADD);
    A->setRange(TOKEN_RANGE(OP));
}
opAssignment(A) ::= var(L) T_MINUS_EQUAL(OP) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::SUB);
    A->setRange(TOKEN_RANGE(OP));
}
opAssignment(A) ::= var(L) T_MOD_EQUAL(OP) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::MOD);
    A->setRange(TOKEN_RANGE(OP));
}
opAssignment(A) ::= var(L) T_SL_EQUAL(OP) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::SHIFT_LEFT);
    A->setRange(TOKEN_RANGE(OP));
}
opAssignment(A) ::= var(L) T_SR_EQUAL(OP) expr(R).
{
    A = new (CTXT) AST::opAssignment(L, R, AST::opAssignment::SHIFT_RIGHT);
    A->setRange(TOKEN_RANGE(OP));
}

// XXX need to SetIsLval() on the listElements if they are expr
%type listAssignment {AST::listAssignment*}
listAssignment(A) ::= T_LIST(LIST) T_LEFTPAREN listAssignmentList(VARS) T_RIGHTPAREN T_ASSIGN expr(RVAL).
{
    AST::block* varList = new (CTXT) AST::block(CTXT, VARS);
    A = new (CTXT) AST::listAssignment(varList, RVAL);
    A->setRange(TOKEN_RANGE(LIST));
    delete VARS;
}

%type listAssignmentList {AST::statementList*}
listAssignmentList(A) ::= listElement(E).
{
    A = new AST::statementList();
    A->push_back(E);
}
listAssignmentList(A) ::= listAssignmentList(LIST) T_COMMA listElement(E).
{
    LIST->push_back(E);
    A = LIST;
}
// note a listElement can be null
%type listElement {AST::stmt*}
// simple var, may include array indices
listElement(A) ::= var(VAR). { A = VAR; }
// nested list, return a block
listElement(A) ::= T_LIST T_LEFTPAREN listAssignmentList(VARS) T_RIGHTPAREN.
{
    AST::block* varList = new (CTXT) AST::block(CTXT, VARS);
    A = static_cast<AST::stmt*>(varList);
    delete VARS;
}
// empty, i.e. skipped
listElement(A) ::= . { A = NULL; }

/** VARIABLES **/
%type rVar {AST::expr*}
rVar(A) ::= var(B). { A = B; }
/*
%type wVar {AST::expr*}
wVar(A) ::= var(B). { A = B; }
%type rwVar {AST::expr*}
rwVar(A) ::= var(B). { A = B; }
*/

%type var {AST::expr*}
var(A) ::= varWithFunCalls(B). { A = B; }

/* xx imported from matching phc rule xx
 *
 * The original rule read
 *
 * variable ::= base_variable_with_function_calls O_SINGLEARROW object_property
 *     method_or_not variable_properties
 *
 * However, this duplicates work done in variable_properties, because
 * variable_properties is a list of variable_property's, and
 *
 * variable_property ::= O_SINGLEARROW object_property method_or_not
 *
 * Now, in the original grammar, variable_properties allows for an empty list;
 * that's now changed, so that it requires at least one variable_property.
 *
 * We don't normally change the grammar, but this rule is difficult enough
 * as it is, so that we don't want to be duplicating code.
 */
var(A) ::= varWithFunCalls(TARGET) varPropertyList(PROPS).
{
  for (AST::expressionList::iterator i = PROPS->begin();
       i != PROPS->end();
       ++i) {

      AST::var* v = dyn_cast<AST::var>(*i);
      if (v) {
          v->setTarget(TARGET);
          // XXX phc checks for function params attribute here and
          // makes a new method call if it finds them, otherwise returning the var
          // we just do the var here so far
          TARGET = v;
      }
      else {
          AST::functionInvoke* f = dyn_cast<AST::functionInvoke>(*i);
          assert(f && "expected function invoke");
          f->setTarget(TARGET);
          TARGET = f;
      }

  }
  A = TARGET;

}

%type varPropertyList {AST::expressionList*}
varPropertyList(A) ::= varPropertyList(LIST) varProperty(PROP).
{
    LIST->push_back(PROP);
    A = LIST;
}
varPropertyList(A) ::= varProperty(PROP).
{
    A = new AST::expressionList();
    A->push_back(PROP);
}

/* xx imported from matching phc rule xx
 *
 * We decide to synthesise an Variable or an Method_invocation
 * based on the absence or presence of a parameter list (method_or_not).
 * If there is a parameter list, we _try_ to generate a method invocation.
 *
 * To do this, we take the name of the variable synthesised by
 * object_property, and use it for the name of the method invocation. That is,
 * if the name of the variable is VarName[x], we convert it to FnName[x];
 * otherwise, it must be an expression and we use the name as-is.
 *
 * However, this fails to work if the variable has array indices. This is
 * the case, for example, in "$x->f[]()" (i.e., "f[]()" as far as
 * variable_property is concerned). In this case, the name of the method
 * is "$x->f[]"; however, we cannot generate this here because we don't
 * know the "$x" part. Instead, we synthesise up "f[]" (Variable), and
 * we set a private attribute in Variable, called "function_params", to
 * the parameters of the method. The rule "variable ::= " must check for
 * this attribute, and generate the correct method invocation if set.
 */
%type varProperty {AST::expr*}
varProperty(A) ::= T_CLASSDEREF(T) objProperty(PROP) maybeMethodInvoke(ARGS).
{
    if (ARGS) {
        // XXX phc checks for array indices on PROP
        AST::functionInvoke* f = new (CTXT) AST::functionInvoke(new (CTXT) AST::literalID(PROP->name(), TOKEN_RANGE(T), CTXT), CTXT, ARGS);
        A = f;
        // PROP is now orphaned
        PROP->destroy(CTXT);
        delete ARGS;
    }
    else {
        // var
        A = PROP;
    }
}

%type maybeMethodInvoke {AST::expressionList*}
maybeMethodInvoke(A) ::= T_LEFTPAREN argList(ARGS) T_RIGHTPAREN.
{
    A = ARGS;
}
maybeMethodInvoke(A) ::= . { A  = NULL; }

%type varNoObjects {AST::var*}
varNoObjects(A) ::= refVar(VAR). { A = VAR; }
varNoObjects(A) ::= varVar(COUNT) refVar(VAR).
{
    VAR->setIndirectionCount(*COUNT);
    delete COUNT;
    A = VAR;
}

// foo::$bar
%type staticMember {AST::expr*}
staticMember(A) ::= namespaceName(TARGET) T_DBL_COLON varNoObjects(VAR).
{
    VAR->setTarget(new (CTXT) AST::literalID(TARGET, CTXT));
    A = VAR;
    delete TARGET;
}
staticMember(A) ::= T_NS_SEPARATOR namespaceName(TARGET) T_DBL_COLON varNoObjects(VAR).
{
    TARGET->setAbsolute();
    VAR->setTarget(new (CTXT) AST::literalID(TARGET, CTXT));
    A = VAR;
    delete TARGET;
}
// static::$foo
staticMember(A) ::= T_STATIC(T) T_DBL_COLON varNoObjects(VAR).
{
    VAR->setTarget(new (CTXT) AST::literalID("static", TOKEN_RANGE(T), CTXT));
    A = VAR;
}
// $cname::$prop
staticMember(A) ::= refVar(TARGET) T_DBL_COLON varNoObjects(VAR).
{
    VAR->setTarget(new (CTXT) AST::dynamicID(TARGET));
    A = VAR;
}


%type varWithFunCalls {AST::expr*}
varWithFunCalls(A) ::= baseVar(VAR). { A = VAR; }
varWithFunCalls(A) ::= functionInvoke(FUN). { A = FUN; }

%type baseVar {AST::expr*}
baseVar(A) ::= varNoObjects(VAR). { A = VAR; }
baseVar(A) ::= staticMember(B). { A = B; }

%type refVar {AST::var*}
refVar(A) ::= T_VARIABLE(B).
{
    // strip $
    A = new (CTXT) AST::var((*B).substr(1), CTXT);
    A->setRange(CURRENT_LINE);
}
refVar(A) ::= T_VARIABLE(B) arrayIndices(C).
{
    // strip $
    A = new (CTXT) AST::var((*B).substr(1), CTXT, C);
    A->setRange(CURRENT_LINE);
    delete C;
}
// XXX refVar: support ${expr} syntax here?
/////

%type objProperty {AST::var*}
objProperty(A) ::= T_IDENTIFIER(ID).
{
    A = new (CTXT) AST::var(*ID, CTXT);
    A->setRange(CURRENT_LINE);
}
objProperty(A) ::= T_IDENTIFIER(ID) arrayIndices(INDICES).
{
    A = new (CTXT) AST::var(*ID, CTXT, INDICES);
    A->setRange(CURRENT_LINE);
    delete INDICES;
}
// $foo->$bar
objProperty(A) ::= varNoObjects(VAR).
{
    VAR->setIndirectionCount(1);
    A = VAR;
}

// $foo->{expr}
objProperty(A) ::= T_LEFTCURLY expr(VAL) T_RIGHTCURLY.
{
    A = new (CTXT) AST::var(VAL, CTXT);
    A->setRange(CURRENT_LINE);
}

%type varVar {pUInt*}
varVar(A) ::= T_DOLLAR. { A = new pUInt(1); }
varVar(A) ::= varVar(COUNT) T_DOLLAR. { (*COUNT)++; A = COUNT; }

/** ARGLIST **/
%type argList {AST::expressionList*}
argList(A) ::= expr(B).
{
    A = new AST::expressionList();
    A->push_back(B);
}
argList(A) ::= expr(B) T_COMMA argList(C).
{
    C->push_back(B);
    A = C;
}
argList(A) ::= .
{
    A = new AST::expressionList();
}

/** ARRAY INDICES **/
%type arrayIndices {AST::expressionList*}
arrayIndices(A) ::= T_LEFTSQUARE expr(B) T_RIGHTSQUARE.
{
    A = new AST::expressionList();
    A->push_back(B);
}
arrayIndices(A) ::= T_LEFTCURLY expr(B) T_RIGHTCURLY.
{
    A = new AST::expressionList();
    A->push_back(B);
}
arrayIndices(A) ::= arrayIndices(B) T_LEFTSQUARE expr(C) T_RIGHTSQUARE.
{
    B->push_back(C);
    A = B;
}
arrayIndices(A) ::= arrayIndices(B) T_LEFTCURLY expr(C) T_RIGHTCURLY.
{
    // XXX unparse needs to know curly
    B->push_back(C);
    A = B;
}
arrayIndices(A) ::= T_LEFTSQUARE T_RIGHTSQUARE.
{
    A = new AST::expressionList();    
    AST::stmt* noop = new (CTXT) AST::emptyStmt();
    A->push_back(static_cast<AST::expr*>(noop));
}
arrayIndices(A) ::= arrayIndices(B) T_LEFTSQUARE T_RIGHTSQUARE.
{
    AST::stmt* noop = new (CTXT) AST::emptyStmt();
    B->push_back(static_cast<AST::expr*>(noop));
    A = B;
}

/** FUNCTION/METHOD INVOKE **/
%type functionInvoke {AST::functionInvoke*}
// foo() or $foo() or $foo[1]() ...
functionInvoke(A) ::= maybeDynamicID(ID) T_LEFTPAREN argList(ARGS) T_RIGHTPAREN.
{
    // args come in backward, reverse them
    std::reverse(ARGS->begin(), ARGS->end());
    A = new (CTXT) AST::functionInvoke(ID, // f name
                                       CTXT,
                                       ARGS  // expression list: arguments, copied
                                       );
    A->setRange(CURRENT_LINE);
    delete ARGS;
}
// foo::bar() (or self:: or parent::)
functionInvoke(A) ::= namespaceName(TARGET) T_DBL_COLON T_IDENTIFIER(ID) T_LEFTPAREN argList(ARGS) T_RIGHTPAREN.
{
    // args come in backward, reverse them
    std::reverse(ARGS->begin(), ARGS->end());
    A = new (CTXT) AST::functionInvoke(new (CTXT) AST::literalID(*ID, CTXT), // f name
                                       CTXT,
                                       ARGS,  // expression list: arguments, copied
                                       new (CTXT) AST::literalID(TARGET, CTXT)
                                       );
    A->setRange(CURRENT_LINE);
    delete ARGS;
    delete TARGET;
}
functionInvoke(A) ::= namespaceName(TARGET) T_DBL_COLON varNoObjects(DNAME) T_LEFTPAREN argList(ARGS) T_RIGHTPAREN.
{
    // args come in backward, reverse them
    std::reverse(ARGS->begin(), ARGS->end());
    A = new (CTXT) AST::functionInvoke(DNAME, // f name
                                       CTXT,
                                       ARGS,  // expression list: arguments, copied
                                       new (CTXT) AST::literalID(TARGET, CTXT)
                                       );
    A->setRange(CURRENT_LINE);
    delete ARGS;
    delete TARGET;
}
functionInvoke(A) ::= T_NS_SEPARATOR namespaceName(TARGET) T_DBL_COLON T_IDENTIFIER(ID) T_LEFTPAREN argList(ARGS) T_RIGHTPAREN.
{
    // args come in backward, reverse them
    std::reverse(ARGS->begin(), ARGS->end());
    TARGET->setAbsolute();
    A = new (CTXT) AST::functionInvoke(new (CTXT) AST::literalID(*ID, CTXT), // f name
                                       CTXT,
                                       ARGS,  // expression list: arguments, copied
                                       new (CTXT) AST::literalID(TARGET, CTXT)
                                       );
    A->setRange(CURRENT_LINE);
    delete ARGS;
    delete TARGET;
}
functionInvoke(A) ::= T_NS_SEPARATOR namespaceName(TARGET) T_DBL_COLON varNoObjects(DNAME) T_LEFTPAREN argList(ARGS) T_RIGHTPAREN.
{
    // args come in backward, reverse them
    std::reverse(ARGS->begin(), ARGS->end());
    TARGET->setAbsolute();
    A = new (CTXT) AST::functionInvoke(DNAME, // f name
                                       CTXT,
                                       ARGS,  // expression list: arguments, copied
                                       new (CTXT) AST::literalID(TARGET, CTXT)
                                       );
    A->setRange(CURRENT_LINE);
    delete ARGS;
    delete TARGET;
}
// $foo::bar()
functionInvoke(A) ::= refVar(TARGET) T_DBL_COLON T_IDENTIFIER(ID) T_LEFTPAREN argList(ARGS) T_RIGHTPAREN.
{
    // args come in backward, reverse them
    std::reverse(ARGS->begin(), ARGS->end());
    A = new (CTXT) AST::functionInvoke(new (CTXT) AST::literalID(*ID, CTXT), // f name
                                       CTXT,
                                       ARGS,  // expression list: arguments, copied
                                       TARGET
                                       );
    A->setRange(CURRENT_LINE);
    delete ARGS;
}
// $foo()
functionInvoke(A) ::= varNoObjects(DNAME) T_LEFTPAREN argList(ARGS) T_RIGHTPAREN.
{
    // args come in backward, reverse them
    std::reverse(ARGS->begin(), ARGS->end());
    A = new (CTXT) AST::functionInvoke(DNAME, // f name
                                       CTXT,
                                       ARGS  // expression list: arguments, copied
                                       );
    A->setRange(CURRENT_LINE);
    delete ARGS;
}


/** CONSTRUCTOR INVOKE **/
%type constructorInvoke {AST::functionInvoke*}
constructorInvoke(A) ::= T_NEW maybeDynamicID(ID) T_LEFTPAREN argList(C) T_RIGHTPAREN.
{
    // args come in backward, reverse them
    std::reverse(C->begin(), C->end());
    A = new (CTXT) AST::functionInvoke(ID, // f name
                                       CTXT,
                                       C  // expression list: arguments, copied
                                       );
    A->setRange(CURRENT_LINE);
    A->setConstructor();
    delete C;
}
constructorInvoke(A) ::= T_NEW maybeDynamicID(ID).
{
    A = new (CTXT) AST::functionInvoke(ID, // f name
                                       CTXT
                                       );
    A->setRange(CURRENT_LINE);
    A->setConstructor();
}



/* DYNAMIC IDENTIFIERS */
// these are either identifiers or a variable representing one

%type literalID {AST::expr*}
literalID(A) ::= namespaceName(NSNAME).
{
    A = new (CTXT) AST::literalID(NSNAME, CTXT);
    A->setRange(CURRENT_LINE);
    delete NSNAME;
}
literalID(A) ::= T_NS_SEPARATOR namespaceName(NSNAME).
{
    NSNAME->setAbsolute();
    A = new (CTXT) AST::literalID(NSNAME, CTXT);
    A->setRange(CURRENT_LINE);
    delete NSNAME;
}
%type maybeDynamicID {AST::expr*}
maybeDynamicID(A) ::= literalID(B). { A = B; }
maybeDynamicID(A) ::= baseVar(VAL).
{
    A = new (CTXT) AST::dynamicID(VAL);
    A->setRange(CURRENT_LINE);
}

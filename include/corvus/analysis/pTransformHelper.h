/* ***** BEGIN LICENSE BLOCK *****
;;
;; Copyright (c) 2009 Shannon Weyrick <weyrick@mozek.us>
;; Copyright (c) 2010 Cornelius Riemenschneider <c.r1@gmx.de>
;;
;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.
   ***** END LICENSE BLOCK *****
*/

#ifndef COR_PTRANSFORMHELPER_H_
#define COR_PTRANSFORMHELPER_H_

#include "corvus/analysis/pAST.h"
#include "corvus/analysis/pParseContext.h"
#include "corvus/analysis/pTempVar.h"

namespace corvus { namespace AST {
class pTransformHelper {
    pParseContext& C_;
    pTempVar t_;

public:
    pTransformHelper(pParseContext& C): C_(C), t_(C) {}

    // lTrue and lFalse provide an easy way to get a literal true or false in the code.
    literalBool* lTrue() {
        return new (C_) literalBool(true);
    }
    literalBool* lFalse() {
        return new (C_) literalBool(false);
    }
    // This method gets several expr*s which are chained together in a list of binaryOp*s.
    // You normally want to use this with binaryOp::BOOLEAN_AND
    // This function copys all expr's it's using clone().
    expr* chainExpressions(const expressionList* expressions, enum binaryOp::opKind operationType) {
        assert(!expressions->empty());
        assert(expressions->size() > 1);

        expressionList::const_iterator it = expressions->begin();
        expr* prevExpr = (*it)->clone(C_);
        ++it;
        for(expressionList::const_iterator end = expressions->end(); it != end; ++it)
            prevExpr = new (C_) binaryOp(prevExpr, (*it)->clone(C_), operationType);

        return prevExpr;
    }
    // That function is currently a slightly modified version of the one above with the whole code duplicated. Very bad.
    expr* chainExpressionsFromBlock(stmt::const_child_range statements, enum binaryOp::opKind operationType) {
        assert(!statements.empty());
        assert(++statements.begin() != statements.end() && " To chain expressions, you need at least two of them!");

        stmt::const_child_iterator it = statements.begin();
        expr* prevExpr = cast<expr>(it->clone(C_));
        ++it;
        for(stmt::const_child_iterator end = statements.end(); it != end; ++it)
            prevExpr = new (C_) binaryOp(prevExpr, cast<expr>(it->clone(C_)), operationType);

        return prevExpr;
    }
    var* tempVar(pStringRef name) {
        return t_.getTempVar(name);
    }
};


} } // namespace

#endif /* COR_PTRANSFORMHELPER_H_ */

/* ***** BEGIN LICENSE BLOCK *****
;; corvus analyzer
;;
;; Copyright (c) 2008-2009 Shannon Weyrick <weyrick@mozek.us>
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
   ***** END LICENSE BLOCK *****
*/

#ifndef COR_PBASEVISITOR_H_
#define COR_PBASEVISITOR_H_

#include "corvus/analysis/pAST.h"
#include "corvus/analysis/pPass.h"

namespace corvus { namespace AST {

class pBaseVisitor: public pPass {
private:

    typedef void (pBaseVisitor::*dispatchFunction)(stmt *);
    typedef bool (pBaseVisitor::*childDispatchFunction)(stmt *);

    static dispatchFunction preDispatchTable_[];
    static dispatchFunction postDispatchTable_[];
    static childDispatchFunction childrenDispatchTable_[];

public:
    pBaseVisitor(const char* name, const char* desc, pSourceModule* m): pPass(name,desc,m) { }
    virtual ~pBaseVisitor(void) { }

    // pass
    void run(void);

    // root dispatch
    void visit(stmt*);
    virtual void visitChildren(stmt*);
    virtual void visitChildren(stmt::child_iterator begin, stmt::child_iterator end);

    virtual void visit_pre_stmt(stmt* ) { }
    virtual void visit_post_stmt(stmt* ) { }

    virtual void visit_pre_expr(expr* ) { }
    virtual void visit_post_expr(expr* ) { }

    // PRE
#define STMT(CLASS, PARENT) virtual void visit_pre_##CLASS(CLASS *) { }
#include "corvus/analysis/astNodes.def"

    // POST
#define STMT(CLASS, PARENT) virtual void visit_post_##CLASS(CLASS *) { }
#include "corvus/analysis/astNodes.def"

    // CHILDREN
    // for custom children handler, define and return true
#define STMT(CLASS, PARENT) virtual bool visit_children_##CLASS(CLASS *) { return false; }
#include "corvus/analysis/astNodes.def"

};


} } // namespace

#endif /* COR_PBASEVISITOR_H_ */
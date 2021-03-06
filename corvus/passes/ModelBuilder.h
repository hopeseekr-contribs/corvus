/* ***** BEGIN LICENSE BLOCK *****
;;
;; Copyright (c) 2012 Shannon Weyrick <weyrick@mozek.us>
;;
;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.
   ***** END LICENSE BLOCK *****
*/

#ifndef COR_PASS_MODEL_BUILDER_H_
#define COR_PASS_MODEL_BUILDER_H_

#include "corvus/pAST.h"
#include "corvus/pNSVisitor.h"
#include "corvus/pModel.h"

#include <vector>

#define RESOLVE_FQN(sym) \
    ( (ns_use_list_.find(sym) != ns_use_list_.end()) ? ns_use_list_[sym] : sym)

namespace corvus {

namespace AST { namespace Pass {

class ModelBuilder: public pNSVisitor {

private:

    pModel::oid c_id_;
    pModel::oid m_id_;
    std::vector<pModel::oid> f_id_list_;

    // child of global node
    bool global_;
    // depth of e.g. if blocks
    int blockDepth_;
    // branch of current if block e.g. true, false
    int branch_;

public:
    ModelBuilder():
            pNSVisitor("ModelBuilder","Build the code model"),
            c_id_(pModel::NULLID),
            m_id_(pModel::NULLID),
            global_(false),
            blockDepth_(0),
            branch_(0)
            { }

    void pre_run(void);
    void post_run(void);

    void visit_pre_namespaceDecl(namespaceDecl* n);
    void visit_post_namespaceDecl(namespaceDecl* n);

    void visit_post_useIdent(useIdent* n);

    void visit_pre_ifStmt(ifStmt* n);
    bool visit_children_ifStmt(ifStmt* n);
    void visit_post_ifStmt(ifStmt* n);
    void visit_pre_globalDecl(globalDecl* n);
    void visit_post_globalDecl(globalDecl* n);
    void visit_pre_classDecl(classDecl* n);
    void visit_post_classDecl(classDecl* n);
    void visit_post_propertyDecl(propertyDecl *n);

    void visit_pre_literalArray(literalArray* n);
    void visit_pre_constDecl(constDecl* n);

    void visit_pre_signature(signature* n);    
    void visit_post_functionDecl(functionDecl *n);
    void visit_post_methodDecl(methodDecl *n);

    void visit_pre_var(var *n);

    void visit_pre_functionInvoke(functionInvoke *n);

    /*
    void visit_pre_block(block* n);
    void visit_post_block(block* n);
    */

};

} } } // namespace

#endif

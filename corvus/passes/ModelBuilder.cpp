/* ***** BEGIN LICENSE BLOCK *****
;;
;; Copyright (c) 2012 Shannon Weyrick <weyrick@mozek.us>
;;
;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.
   ***** END LICENSE BLOCK *****
*/

#include "md5.h"

#include "corvus/passes/ModelBuilder.h"

#include "corvus/pSourceModule.h"
#include "corvus/pSourceFile.h"
#include <stdio.h>
#include <sstream>

namespace corvus { namespace AST { namespace Pass {


void ModelBuilder::pre_run(void) {

    pNSVisitor::pre_run();

    // generate the source hash
    md5_byte_t digest[16];
    md5_state_t state;
    md5_init(&state);
    md5_append(&state,
               reinterpret_cast<const md5_byte_t *>(module_->source()->contents()->getBufferStart()),
               module_->source()->contents()->getBufferSize());
    md5_finish(&state, digest);
    char hash[32];
    for (int di = 0; di < 16; ++di)
        sprintf(hash + di * 2, "%02x", digest[di]);

    // is the source module dirty? i.e. does it exist in the model already and
    // has it changed since we last built it?
    if (!model_->sourceModuleDirty(module_->fileName(), hash)) {
        // don't run the pass
        abortPass();
        return;
    }

    // XXX if we get here, we may be deleting a source module if it exists.
    // if that source module defined classes, they will be cascade deleted
    // throughout the existing model db (including all properties, relations,
    // etc). HOWEVER, if the module had defined a class which it
    // now now longer defines (or has added/removed properties or fields),
    // and a different class from another module had
    // depended on it and resolved it previously (into its own "extends" field in the class
    // table), that data is now stale.
    // so essentially we need a to scan the "extends" and "implements" fields in model db
    // in the class table here for any classes that were defined in this module we
    // are about to delete, and reset that dependant class row to "unresolved"
    // (by setting unresolved_extends = extends and unresolved_implementes = implements)
    // so that the class model will rebuild based on the new data we're about to make
    // XXX the way to remove this requirement is to move "unresolved_extends/implements" into
    //     its own normalized table with cascade delete
    // XXX

    m_id_ = model_->getSourceModuleOID(module_->fileName(),
                                       hash,
                                       true /* delete first */
                                       );

}

void ModelBuilder::post_run(void) {

    model_->resolveMultipleDecls(m_id_);

}

void ModelBuilder::visit_pre_namespaceDecl(namespaceDecl* n) {

    ns_id_ = model_->getNamespaceOID(n->name(), true);

}

void ModelBuilder::visit_post_namespaceDecl(namespaceDecl* n) {

    // we only lose the namespace if this one had a body, i.e. block
    if (n->body()) {
        ns_id_ = model_->getRootNamespaceOID();
        ns_use_list_.clear();
    }

}

void ModelBuilder::visit_post_useIdent(useIdent* n) {

    std::string alias;

    // use \foo\myclass
    //     ~~~~~~~~~~~~ = nsname, blank alias

    // if we don't have an alias, we want to extract the symbolname
    // which is myclass in this case

    // use \foo\myclass as bar
    //     ~~~~~~~~~~~~    ~~~ = alias

    // then anytime we see symbol 'alias', we instead use 'nsname'

    alias = n->alias();
    if (alias.empty()) {
        alias = n->nsname();
        if (alias.find('\\') != std::string::npos) {
            alias = alias.substr(alias.find_last_of('\\')+1);
        }
    }

    //std::cout << "use: " << alias << " => " << n->nsname().str() << "\n";
    ns_use_list_[alias] = n->nsname();

}

void ModelBuilder::visit_pre_classDecl(classDecl* n) {

    std::stringstream extends, implements;
    if (n->extendsCount()) {
        for (idList::iterator i = n->extends_begin();
             i != n->extends_end();
             ++i) {
            // interfaces have multiple inheritance
            extends << RESOLVE_FQN(*i) << ",";
        }
    }
    if (n->implementsCount()) {
        for (idList::iterator i = n->implements_begin();
             i != n->implements_end();
             ++i) {
            implements << RESOLVE_FQN(*i) << ",";
        }
    }

    std::string extendsS(extends.str());
    std::string implementsS(implements.str());

    c_id_ = model_->defineClass(ns_id_,
                                m_id_,
                                n->name(),
                                (n->classType() == classDecl::IFACE) ?
                                    pModel::IFACE : pModel::CLASS,
                                n->extendsCount(),
                                n->implementsCount(),
                                extendsS.substr(0,extendsS.size()-1),
                                implementsS.substr(0,implementsS.size()-1),
                                n->range());

}

void ModelBuilder::visit_post_propertyDecl(propertyDecl *n) {

    if (n->flags() & memberFlags::CONST) {
        expr* value = n->defaultValue();
        assert(llvm::isa<literalExpr>(value) || llvm::isa<unaryOp>(value));        
        std::string def;
        if (llvm::isa<unaryOp>(value)) {
            switch (llvm::dyn_cast<unaryOp>(value)->opKind()) {
                case unaryOp::NEGATIVE:
                    def.push_back('-');
                    break;
                case unaryOp::BITWISENOT:
                    def.push_back('~');
                    break;
                default:
                    break;
            }
            value = llvm::dyn_cast<unaryOp>(value)->rVal();
            def.append(llvm::dyn_cast<literalExpr>(value)->getStringVal());
        }
        else {
            def = llvm::dyn_cast<literalExpr>(value)->getStringVal();
        }
        model_->defineClassDecl(c_id_,
                                n->name(),
                                pModel::CONST,
                                pModel::NO_FLAGS,
                                pModel::PUBLIC, // implicit
                                def,
                                n->range());
    }

}

void ModelBuilder::visit_post_classDecl(classDecl* n) {

    c_id_ = pModel::NULLID;

}

void ModelBuilder::visit_pre_signature(signature* n) {


    int minArity = 0;
    for (int i = 0; i < n->numParams(); i++) {
        formalParam *p = n->getParam(i);
        if (p->hasDefault())
            break;
        minArity++;
    }
    f_id_list_.push_back(model_->defineFunction(ns_id_,
                          m_id_,
                          c_id_,
                          n->name(),
                          pModel::FUNCTION,
                          pModel::NO_FLAGS,
                          pModel::PUBLIC,
                          minArity,
                          n->numParams(),
                          n->range()
                          ));

    for (int i = n->numParams()-1; i >= 0; i--) {
        formalParam *p = n->getParam(i);
        // XXX get types based on hints and defaults
        model_->defineFunctionVar(f_id_list_.back(),
                                 p->name(),
                                 pModel::PARAM,
                                 pModel::NO_FLAGS,
                                 pModel::TYPE_UNKNOWN, // XXX
                                 0, // blockDepth
                                 0, // branch
                                 "", // XXX datatype obj
                                 "", // XXX default
                                 p->range()
                    );
    }

}

void ModelBuilder::visit_pre_globalDecl(globalDecl* n) {
    global_ = true;
}

void ModelBuilder::visit_post_globalDecl(globalDecl* n) {
    global_ = false;
}

void ModelBuilder::visit_pre_ifStmt(ifStmt* n) {
    blockDepth_++;
}

bool ModelBuilder::visit_children_ifStmt(ifStmt* n) {
    branch_ = 0;
    visit(n->condition());
    branch_ = 1;
    if (n->trueBlock())
        visit(n->trueBlock());
    branch_ = 2;
    if (n->falseBlock())
        visit(n->falseBlock());
    branch_ = 0;
    return true; // this says don't use standard child visitor
}

void ModelBuilder::visit_post_ifStmt(ifStmt* n) {
    blockDepth_--;
}

void ModelBuilder::visit_post_functionDecl(functionDecl *n) {
    f_id_list_.pop_back();
}

void ModelBuilder::visit_post_methodDecl(methodDecl *n) {
    f_id_list_.pop_back();
}

void ModelBuilder::visit_pre_var(var* n) {

    // XXX right now only in the function context
    if (f_id_list_.size() == 0)
        return;

    // can't handle dynamic vars
    if (n->hasDynamicName())
        return;

    // XXX handle target i.e. class::$foo
    if (n->target() != NULL)
        return;

    // if it's a superglobal, we ignore
    if (n->name() == "_REQUEST" ||
        n->name() == "_GET" ||
        n->name() == "_POST" ||
        n->name() == "_COOKIE" ||
        n->name() == "_SERVER" ||
        n->name() == "GLOBALS" ||
        n->name() == "_ENV")
        return;

    // it's only considered a decl if we have no indices
    // i.e. $arr = array() is a decl but $arr['foo'] = 5 is not
    // if there are indices it's always a use

    int datatype = pModel::TYPE_UNKNOWN;
    if (n->prop("datatype") == "null") {
        datatype = pModel::TYPE_NULL;
    }

    // if it's an lval which isn't an array, or a global, it's a declaration
    // but not if we're inside a branch
    if ((n->isLval() && n->numIndices() == 0) || global_) {
        model_->defineFunctionVar(f_id_list_.back(),
                                 n->name(),
                                 pModel::FREE_VAR,
                                 pModel::NO_FLAGS,
                                 datatype,
                                 blockDepth_,
                                 branch_,
                                 "", // XXX if object, the class name we think it is
                                 "", // default (only func params)
                                 n->range()
                    );
    }
    else {
        // if it's an rval or array assign
        // it's a use and it should have had a decl
        // by now since we would have visited it in the tree before
        // now

        // if we're in a class and the var is the implicit $this, skip it
        if (c_id_ != pModel::NULLID && n->name() == "this")
            return;

        model_->defineFunctionVarUse(f_id_list_.back(),
                                     blockDepth_,
                                     branch_,
                                     n->name(),
                                     n->range());
    }

}

void ModelBuilder::visit_pre_literalArray(literalArray* n)  {
    for (arrayList::reverse_iterator i = n->itemList().rbegin();
        i != n->itemList().rend();
        ++i)
    {
        if ((*i).key) {
            visit((*i).key);
        }
        visit((*i).val);
    }
}

void ModelBuilder::visit_pre_constDecl(constDecl* n) {

    for (stmt::child_iterator i = n->child_begin(), e = n->child_end(); i != e; ) {

        expr* name =  llvm::dyn_cast<expr>(*i++);
        expr* value =  llvm::dyn_cast<expr>(*i++);

        std::string strval;
        if (llvm::isa<literalExpr>(value)) {
            strval = llvm::dyn_cast<literalExpr>(value)->getStringVal();
        }

        model_->defineConstant(m_id_,
                               ns_id_,
                               llvm::dyn_cast<literalID>(name)->name(),
                               pModel::CONST,
                               strval,
                               n->range());

    }

}

void ModelBuilder::visit_pre_functionInvoke(functionInvoke *n) {

    // can't do anything with dynamics
    if (!n->hasLiteralName())
        return;

    if (n->target()) {
        // method invoke
    }
    else {
        // function invoke

        // if this is define(), we do a constant
        if (n->literalName().equals("define") && n->numArgs() == 2) {
            // need to pull the name and value from param list
            expr* name = n->arg(0);
            expr* value = n->arg(1);
            if (!llvm::isa<literalExpr>(name)) {
                // this happens if they, e.g. contact a string together
                // to build a dynamic constant name. we can't handle those.
                //addDiagnostic(n, "expected literal name for define()");
                return;
            }
            std::string strval;
            if (llvm::isa<literalExpr>(value)) {
                strval = llvm::dyn_cast<literalExpr>(value)->getStringVal();
            }
            model_->defineConstant(m_id_,
                                   llvm::dyn_cast<literalExpr>(name)->getStringVal(),
                                   pModel::DEFINE,
                                   strval,
                                   n->range());
            return;
        }
    }

}

} } } // namespace


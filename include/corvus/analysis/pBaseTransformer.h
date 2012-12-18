/* ***** BEGIN LICENSE BLOCK *****
;; corvus analyzer
;;
;; Copyright (c) 2009 Shannon Weyrick <weyrick@mozek.us>
;; Copyright (c) 2010 Cornelius Riemenschneider <c.r1@gmx.de>
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

#ifndef RPHP_PTRANSFORMER_H_
#define RPHP_PTRANSFORMER_H_

#include "corvus/analysis/pAST.h"
#include "corvus/analysis/pParseContext.h"
#include "corvus/analysis/pPass.h"
#include "corvus/analysis/pTransformHelper.h"

namespace corvus { namespace AST {

class pBaseTransformer: public pPass {
private:

    typedef stmt* (pBaseTransformer::*dispatchFunction)(stmt *);

    static dispatchFunction preDispatchTable_[];
    static dispatchFunction postDispatchTable_[];

protected:
    pTransformHelper h_;

public:
    pBaseTransformer(const char* name, const char* desc, pSourceModule* m): pPass(name,desc,m), h_(C_) { }
    virtual ~pBaseTransformer() { }

    // pass
    void run(void);

    // root transform
    stmt* transform(stmt*);

    // PRE
#define STMT(CLASS, PARENT) virtual PARENT * transform_pre_##CLASS(CLASS *n) { return n; }
#include "corvus/analysis/astNodes.def"

    // POST
#define STMT(CLASS, PARENT) virtual PARENT * transform_post_##CLASS(CLASS *n) { return n; }
#include "corvus/analysis/astNodes.def"


};


} } // namespace

#endif /* RPHP_PTRANSFORMER_H_ */

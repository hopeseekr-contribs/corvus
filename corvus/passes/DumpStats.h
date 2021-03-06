/* ***** BEGIN LICENSE BLOCK *****
;;
;; Copyright (c) 2008-2010 Shannon Weyrick <weyrick@mozek.us>
;;
;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.
   ***** END LICENSE BLOCK *****
*/

#ifndef COR_DUMPSTATS_H_
#define COR_DUMPSTATS_H_

#include "corvus/pAST.h"
#include "corvus/pBaseVisitor.h"

namespace corvus { namespace AST { namespace Pass {

class DumpStats: public pBaseVisitor {

public:
    DumpStats():
            pBaseVisitor("Statistics Dump","Dump parse and memory statistics")
            { }

    void post_run(void);

};

} } } // namespace

#endif /* COR_DUMPAST_H_ */

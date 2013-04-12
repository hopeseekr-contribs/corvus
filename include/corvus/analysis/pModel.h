/* ***** BEGIN LICENSE BLOCK *****
;;
;; Copyright (c) 2008-2009 Shannon Weyrick <weyrick@mozek.us>
;;
;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.
   ***** END LICENSE BLOCK *****
*/

#ifndef COR_PMODEL_H_
#define COR_PMODEL_H_

#include "corvus/pTypes.h"

#include <sqlite3.h>
#include <map>

namespace corvus {

class pModel {
public:

    typedef sqlite3_int64 oid;

    // general
    const static int NULLID   = 0;
    const static int NO_FLAGS = 0;

    // flags
    const static int STATIC   = 0x1;
    const static int ABSTRACT = 0x2;

    // function types
    const static int TOP_LEVEL = 0;
    const static int FUNCTION  = 1;
    const static int METHOD    = 2;

    // function var types
    const static int PARAM     = 0;
    const static int FREE_VAR  = 1;

    // visibility
    const static int PUBLIC    = 0;
    const static int PROTECTED = 1;
    const static int PRIVATE   = 2;

    // types
    const static int T_UNKNOWN = 0;

private:

    typedef std::map<std::string, oid> IDMAP;

    sqlite3 *db_;
    bool trace_;

    IDMAP modules_;
    IDMAP namespaces_;

    void sql_execute(pStringRef query);
    oid sql_insert(pStringRef query);
    void sql_setup();
    void sql_done();

    void makeTables();

    pStringRef oidOrNull(oid val);
    pStringRef strOrNull(pStringRef val);

public:

    pModel(sqlite3 *db, bool trace=false): db_(db), trace_(trace) {
        sql_setup();
    }

    void commit(bool begin=true);

    oid getSourceModule(pStringRef realPath);
    oid getNamespace(pStringRef ns);

    oid defineClass(oid ns, pStringRef name);
    oid defineFunction(oid ns_id, oid m_id, oid c_id, pStringRef name,
                        int type, int flags, int vis, int sl, int sc,
                        int el, int ec);
    void defineFunctionVar(oid f_id, pStringRef name,
                          int type, int flags, int datatype, pStringRef datatype_obj,
                          pStringRef defaultVal,
                          int sl, int sc);

};

} // namespace

#endif /* COR_PSOURCEFILE_H_ */
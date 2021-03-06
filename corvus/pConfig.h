/* ***** BEGIN LICENSE BLOCK *****
;;
;; Copyright (c) 2013 Shannon Weyrick <weyrick@mozek.us>
;;
;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.
   ***** END LICENSE BLOCK *****
*/

#ifndef COR_PCONFIG_H_
#define COR_PCONFIG_H_

#include "pTypes.h"
#include <string>
#include <llvm/ADT/Twine.h>
#include <vector>
#include <string>

namespace corvus {

struct pConfig {
    typedef std::vector<std::string> StringListType;
    StringListType includePaths;
    StringListType inputFiles;
    StringListType diagFiles;
    std::string rootDir;
    std::string dbName;
    std::string exts;
    int verbosity;
    bool debugParse;
    bool debugModel;
    bool debugDiags;
    pConfig(): exts("php"), verbosity(0), debugParse(false), debugModel(false),
               debugDiags(false) { }

};

class pConfigMgr {

public:

    static bool read(const llvm::Twine &file, pConfig &c);

};

} // namespace

#endif

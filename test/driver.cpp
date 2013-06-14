/* ***** BEGIN LICENSE BLOCK *****
;;
;; Copyright (c) 2013 Shannon Weyrick <weyrick@mozek.us>
;;
;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.
   ***** END LICENSE BLOCK *****
*/

#include <exception>
#include <iostream>
#include <string>

#include "corvus/pSourceManager.h"
#include "corvus/pConfig.h"
#include "corvus/pDiagnostic.h"
#include "corvus/pModel.h"
#include <llvm/Support/FileSystem.h>
#include <sstream>

using namespace llvm;
using namespace corvus;

#define ASSERT(A,B) cassert(A,B,__LINE__)

void cassert(int a, int b, int line) {
    if (a != b) {
        std::cout << line << ": " << a << " != " << b << std::endl;
        exit(1);
    }
}

void cassert(pStringRef a, pStringRef b, int line) {
    if (!a.equals(b)) {
        std::cout << line << ": "<< "[" << a.str() << "] != [" << b.str() << "]" << std::endl;
        exit(1);
    }
}

void cassert(pSourceLoc a, pSourceLoc b, int line) {
    if (a != b) {
        std::cout << line << ": "<< "[" << a.toString() << "] != [" << b.toString() << "]" << std::endl;
        exit(1);
    }
}

void cassert(pSourceRange a, pSourceRange b, int line) {
    if (a != b) {
        std::stringstream outa, outb;
        outa << a.startLine << ":" << a.startCol << ":" <<
                     a.endLine << ":" << a.endCol;
        outb << b.startLine << ":" << b.startCol << ":" <<
                     b.endLine << ":" << b.endCol;
        std::cout << line << ": ""[" << outa.str() << "] != [" << outb.str() << "]" << std::endl;
        exit(1);
    }
}

int main( int argc, char* argv[] )
{

    pSourceManager sm;
    pConfig config;
    std::vector<std::string> inputFiles;

    //sm.setDebug(0,false,true);
    config.exts = "php";

    // try to read home directory config file
    char *home = getenv("HOME");
    if (home) {
        // will ignore if not found
        pConfigMgr::read(pStringRef(home)+"/.corvus", config);
    }

    if (!config.includePaths.empty()) {
        for (unsigned i = 0; i != config.includePaths.size(); ++i) {
            sm.addIncludeDir(config.includePaths[i], config.exts);
        }
    }

    sm.setModelDBName("test.db");
    inputFiles.push_back("test1.php");

    for (unsigned i = 0; i != inputFiles.size(); ++i) {

        sys::fs::file_status stat;
        sys::fs::status(inputFiles[i], stat);
        if (sys::fs::is_directory(stat))
            sm.addSourceDir(inputFiles[i], config.exts);
        else if (sys::fs::is_regular_file(stat))
            sm.addSourceFile(inputFiles[i]);
        else
            std::cerr << "skipping unknown path: " << inputFiles[i] << std::endl;

    }

    try {
        sm.refreshModel();
        sm.runDiagnostics();
    }
    catch (std::exception& e) {
        std::cout << "exception: " << e.what() << "\n";
        exit(1);
    }

    pSourceManager::DiagModuleListType mList = sm.getDiagModules();

    // 1 source module
    cassert(mList.size(), 1, __LINE__);

    pSourceModule::DiagListType dList = mList[0]->getDiagnostics();

    // DIAG COUNT
    cassert(dList.size(), 6, __LINE__);

    // DIAGS

    // 1
    int i = 0;
    ASSERT(dList[i]->msg(), "function 'nonexist' not defined");
    ASSERT(dList[i]->location().range(), pSourceRange(57,1,57,0)); // XXX

    // 2
    i++;
    ASSERT(dList[i]->msg(), "wrong number of arguments: function 'bar' takes between minArity and maxArity arguments (0 specified)");
    ASSERT(dList[i]->location().range(), pSourceRange(60,1,60,0)); // XXX

    // 3
    i++;
    ASSERT(dList[i]->msg(), "wrong number of arguments: function 'bar' takes between minArity and maxArity arguments (4 specified)");
    ASSERT(dList[i]->location().range(), pSourceRange(64,1,64,0)); // XXX

    // 4
    i++;
    ASSERT(dList[i]->msg(), "undefined constant: MYTHIRD");
    ASSERT(dList[i]->location().range(), pSourceRange(91,0,91,0)); // XXX

    // 5
    i++;
    ASSERT(dList[i]->msg(), "parameter should have default because previous parameter does");
    ASSERT(dList[i]->location().range(), pSourceRange(109,28,109,34));

    // 6 (second part of 4)
    i++;
    ASSERT(dList[i]->msg(), "first parameter with default defined here");
    ASSERT(dList[i]->location().range(), pSourceRange(109,20,109,24));

    // MODEL QUERIES
    const pModel *m = sm.model();

    // functions
    pModel::FunctionList f;
    f = m->queryFunctions(m->getNamespaceOID("\\myns"), pModel::NULLID, "foo");
    ASSERT(f.size(), 1);

    // classes
    pModel::ClassList c;
    c = m->queryClasses(m->getNamespaceOID("\\myns"), "myclass");
    ASSERT(c.size(), 1);

    // constants
    pModel::ConstantList cn;
    cn = m->queryConstants("MYFIRST");
    ASSERT(cn.size(), 1);


    std::cout << "all tests passing" << std::endl;
    return 0;

}
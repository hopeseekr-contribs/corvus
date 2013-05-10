/* ***** BEGIN LICENSE BLOCK *****
;;
;; Copyright (c) 2008-2010 Shannon Weyrick <weyrick@mozek.us>
;;
;; This Source Code Form is subject to the terms of the Mozilla Public
;; License, v. 2.0. If a copy of the MPL was not distributed with this
;; file, You can obtain one at http://mozilla.org/MPL/2.0/.
   ***** END LICENSE BLOCK *****
*/

#ifndef COR_PPARSECONTEXT_H_
#define COR_PPARSECONTEXT_H_

#include "corvus/pTypes.h"

#include <llvm/Support/Allocator.h>
#include <llvm/Support/StringPool.h>
#include <boost/unordered_map.hpp>


namespace corvus {

class pSourceModule;

namespace AST {
class pParseContext {
private:
    typedef boost::unordered_map<const pSourceRange*, pUInt> lineNumMapType;

    pUInt currentLineNum_;
    pSourceCharIterator lastNewline_;
    const pSourceRange* lastToken_;
    lineNumMapType tokenLineInfo_;

    /// Maintains memory of IR during entire analysis and code gen phases
    llvm::BumpPtrAllocator allocator_;

    /// String pool for identifiers to use. Also lives through analysis
    llvm::StringPool idPool_;

    // owning source module
    const pSourceModule* owner_;

public:

    pParseContext(const pSourceModule* o):
        currentLineNum_(0),
        lastNewline_(),
        lastToken_(NULL),
        tokenLineInfo_(),
        allocator_(),
        idPool_(),
        owner_(o)
        { }

    // MEMORY POOL
    llvm::BumpPtrAllocator& allocator(void) { return allocator_; }
    void *allocate(size_t size, size_t align = 8) {
        return allocator_.Allocate(size, align);
    }
    void deallocate(void* Ptr) {
        // note this is a NOOP for bumpptr
        allocator_.Deallocate(Ptr);
    }

    llvm::StringPool& idPool(void) { return idPool_; }

    // PARSING
    pUInt currentLineNum() const { return currentLineNum_; }
    void incLineNum(void) { ++currentLineNum_; }
    void incLineNum(pUInt i) { currentLineNum_ +=i; }

    pColRange getColPair(pSourceRange* r);

    void setLastNewline(pSourceCharIterator i) { lastNewline_ = i; }
    const pSourceCharIterator& lastNewline(void) const { return lastNewline_; }

    void setLastToken(const pSourceRange* i) { lastToken_ = i; }
    const pSourceRange* lastToken(void) const { return lastToken_; }

    void setTokenLine(const pSourceRange* t) {
        tokenLineInfo_[t] = currentLineNum_;
    }

    pUInt getTokenLine(const pSourceRange* t) {
        lineNumMapType::const_iterator i = tokenLineInfo_.find(t);
        if (i == tokenLineInfo_.end())
            return 0;
        else
            return (*i).second;
    }

    void finishParse(void) {
        currentLineNum_ = 0;
        lastToken_ = NULL;
        tokenLineInfo_.clear();
    }

    const pSourceModule* getOwner(void) const {
        return owner_;
    }

    // PARSE ERROR HANDLER
    void parseError(pSourceRange* r);
    void parseError(pStringRef msg);

};

} } // namespace

// placement allocators for constructing AST nodes. this is modeled after clang
inline void *operator new(size_t bytes, corvus::AST::pParseContext& C, size_t align=8) throw () {
  return C.allocate(bytes, align);
}

inline void operator delete(void *p, corvus::AST::pParseContext& C) throw () {
  C.deallocate(p);
}

inline void *operator new[](size_t bytes, corvus::AST::pParseContext& C, size_t align = 8) throw () {
  return C.allocate(bytes, align);
}

inline void operator delete[](void *p, corvus::AST::pParseContext& C) throw () {
  C.deallocate(p);
}

#endif /* COR_PPARSECONTEXT_H_ */
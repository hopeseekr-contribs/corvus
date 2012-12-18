/* ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler
;;
;; Copyright (c) 2009 Shannon Weyrick <weyrick@roadsend.com>
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

#ifndef RPHP_PPASSMANAGER_H_
#define RPHP_PPASSMANAGER_H_

#include <vector>

namespace corvus {

class pSourceModule;

namespace AST {
class pPass;
}

class pPassManager {
public:
    typedef std::vector<AST::pPass*> queueType;

private:

    queueType passQueue_;
    pSourceModule* module_;

    // no copy constructor
    pPassManager(const pPassManager&);

public:

    pPassManager(pSourceModule* m): passQueue_(), module_(m) { }
    ~pPassManager(void);

    /// add a pass. takes ownership.
    void addPass(AST::pPass* p);

    template <typename PassType>
    void addPass(void) {
        PassType* P = new PassType(module_);
        addPass(P);
    }

    void run(void);

};

} // namespace

#endif /* RPHP_PPASSMANAGER_H_ */

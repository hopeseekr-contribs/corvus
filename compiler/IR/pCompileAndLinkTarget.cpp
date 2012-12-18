/* ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler
;;
;; Copyright (c) 2008-2009 Shannon Weyrick <weyrick@roadsend.com>
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


#include "rphp/IR/pCompileAndLinkTarget.h"

using namespace llvm;

namespace rphp {

void pCompileAndLinkTarget::execute(void) {

    std::string outfileName = cTarget_->getInputFileName()+".bc";
    addInputFile(outfileName);
    cTarget_->configureWith(this);
    cTarget_->setCreateMain(true);
    cTarget_->execute();
    cTarget_->writeToFile(outfileName);
    pStandAloneTarget::execute();

}

} // namespace


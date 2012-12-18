/* ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler
;;
;; Copyright (c) 2009 Shannon Weyrick <weyrick@mozek.us>
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

#ifndef RPHP_SIMPLIFYSTRINGS_H_
#define RPHP_SIMPLIFYSTRINGS_H_

#include "corvus/analysis/pBaseTransformer.h"

namespace corvus { namespace AST { namespace Pass {

class SimplifyStrings: public pBaseTransformer {

    expr* simplifyString(pSourceCharIterator in_b, pSourceCharIterator in_e);

public:
    SimplifyStrings(pSourceModule *m):
            pBaseTransformer("SimplifyStrings","Convert double quoted strings to their more simple counterparts", m)
    {
    }

    expr* transform_post_literalString(literalString* n);

};

} } } // namespace

#endif /* RPHP_SIMPLIFYSTRINGS_H_ */

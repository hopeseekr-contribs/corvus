/* ***** BEGIN LICENSE BLOCK *****
;; corvus analyzer
;;
;; Copyright (c) 2008 Shannon Weyrick <weyrick@mozek.us>
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

#ifndef RPHP_PTARGETERROR_H_
#define RPHP_PTARGETERROR_H_

#include <string>
#include <stdexcept>

namespace corvus {

class pTargetError : public std::runtime_error {

    std::string msg_;

public:
    pTargetError(const std::string& msg):
        std::runtime_error(""),
        msg_(msg) { }

    pTargetError(const std::wstring& msg):
        std::runtime_error(""),
        msg_(msg.begin(), msg.end()) { }

    ~pTargetError(void) throw() { }

    const char* what() const throw() {
        std::string fullMsg;
        fullMsg = "target error: " + msg_;
        return fullMsg.c_str();
    } 

};

} // namespace

#endif /* RPHP_PTARGETERROR_H_ */

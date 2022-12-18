/*
   Copyright 2022 natinusala

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import Foundation
import Stencil

/// Creates and return the Stencil environment.
func getEnvironment() -> Environment {
    let ext = Extension()

    registerWrappedBy(in: ext)

    return Environment(
        loader: nil,
        extensions: [ext],
        templateClass: Template.self,
        trimBehaviour: .smart
    )
}

/// `wrappedBy:` filter: returns `true` or `false` if the given property is wrapped
/// by the given property wrapper.
private func registerWrappedBy(in ext: Extension) {
    ext.registerFilter("wrappedBy") { (value: Any?, arguments: [Any?]) throws -> Bool in
        if arguments.count != 1 {
            throw TemplateSyntaxError("'wrappedBy' filter takes exactly one argument")
        }

        guard let wrapperName = arguments[0] as? String else {
            throw TemplateSyntaxError("'wrappedBy' filter's first argument must be the property wrapper name")
        }

        guard let property = value as? Property else {
            throw TemplateSyntaxError("'wrappedBy' filter can only be applied to properties")
        }

        return property.attributes.contains { attribute in
            switch attribute {
                case .customAttribute(let name) where name == wrapperName:
                    return true
                default:
                    return false
            }
        }
    }
}

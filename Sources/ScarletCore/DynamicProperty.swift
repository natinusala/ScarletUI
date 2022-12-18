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

import Runtime

/// A property which storage is managed by ScarletUI.
///
/// The table below describes how different elements behave depending on if they are stateless or stateful and if they are a POD or not.
/// "Stateful" here designate any element with a dynamic property.
///
///|                       | **Comparison**                                                       | **Dynamic properties installation**                                             | **Value storage**                                                               | **State storage**                                                     |
///|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------|-----------------------------------------------------------------------|
///| **Stateful POD**      | _Undefined - all dynamic properties have objects and cannot be PODs_ | _Undefined_                                                                     | _Undefined_                                                                     | _Undefined_                                                           |
///| **Stateless POD**     | memcmp                                                               | Can be done after comparison as there are no dynamic properties anyway          | Store whole value for memcmp                                                    | Stored directly in value, doesn't change anything                     |
///| **Stateful non-POD**  | Field by field mirror, ignoring dynamic properties                   | Can be done after comparison since dynamic properties are ignored in comparison | Store whole value, it's fine since dynamic properties are ignored in comparison | Stored directly in value, avoids duplication with whole value storage |
///| **Stateless non-POD** | _Undefined - not supported_                                          | _Undefined_                                                                     | _Undefined_                                                                     | _Undefined_                                                           |
protocol DynamicProperty {
    /// Accepts the given visitor into the property.
    /// Should call the appropriate `visit` methode of the visitor.
    func accept<Visitor: ElementVisitor>(
        visitor: Visitor,
        in property: PropertyInfo,
        target: inout Visitor.Visited,
        using context: ElementNodeContext
    ) throws
}

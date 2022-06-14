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

/// Represents a view that can generate dynamic views from an underlying collection of identified data.
/// This protocol is aimed to be used in parents with static edges, and cannot be used for recycling purposes.
public protocol DynamicViewContent {
    /// Returns the count of dynamic views in the collection.
    func count() -> Int

    /// Makes the dynamic view at given index in the collection.
    func make(at: Int, identifiedBy: AnyHashable, input: MakeInput) -> MakeOutput
}

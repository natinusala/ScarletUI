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

@_exported import CGlad

// The Swift C header parser ignores defines so we need to
// redefine every GL function here.

// Warning: they are all unsafe functions, please ensure that the context is
// created before calling any of those functions.

public let glGenTextures = glad_glGenTextures!
public let glBindTexture = glad_glBindTexture!
public let glTexStorage2D = glad_glTexStorage2D!
public let glBindBuffer = glad_glBindBuffer!
public let glPixelStorei = glad_glPixelStorei!
public let glTexSubImage2D = glad_glTexSubImage2D!
public let glEnable = glad_glEnable!
public let glGetIntegerv = glad_glGetIntegerv!
public let glGenFramebuffers = glad_glGenFramebuffers!
public let glBindFramebuffer = glad_glBindFramebuffer!
public let glFramebufferTexture2D = glad_glFramebufferTexture2D!
public let glGenRenderbuffers = glad_glGenRenderbuffers!
public let glBindRenderbuffer = glad_glBindRenderbuffer!
public let glRenderbufferStorage = glad_glRenderbufferStorage!
public let glFramebufferRenderbuffer = glad_glFramebufferRenderbuffer!
public let glCheckFramebufferStatus = glad_glCheckFramebufferStatus!
public let glClear = glad_glClear!
public let glDebugMessageCallback = glad_glDebugMessageCallback!
public let glGetTexLevelParameteriv = glad_glGetTexLevelParameteriv!
public let glGetString = glad_glGetString!

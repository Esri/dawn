// Copyright 2022 The Dawn & Tint Authors
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "dawn/native/opengl/EGLFunctions.h"

namespace dawn::native::opengl {

void EGLFunctions::Init(void* (*getProc)(const char*)) {
    GetProcAddress = reinterpret_cast<PFNEGLGETPROCADDRESSPROC>(getProc);
    BindAPI = reinterpret_cast<PFNEGLBINDAPIPROC>(GetProcAddress("eglBindAPI"));
    ChooseConfig = reinterpret_cast<PFNEGLCHOOSECONFIGPROC>(GetProcAddress("eglChooseConfig"));
    CreateContext = reinterpret_cast<PFNEGLCREATECONTEXTPROC>(GetProcAddress("eglCreateContext"));
    CreatePbufferSurface =
        reinterpret_cast<PFNEGLCREATEPBUFFERSURFACEPROC>(GetProcAddress("eglCreatePbufferSurface"));
    CreatePlatformWindowSurface = reinterpret_cast<PFNEGLCREATEPLATFORMWINDOWSURFACEPROC>(
        GetProcAddress("eglCreatePlatformWindowSurface"));
    DestroyContext =
        reinterpret_cast<PFNEGLDESTROYCONTEXTPROC>(GetProcAddress("eglDestroyContext"));
    GetConfigs = reinterpret_cast<PFNEGLGETCONFIGSPROC>(GetProcAddress("eglGetConfigs"));
    GetCurrentContext =
        reinterpret_cast<PFNEGLGETCURRENTCONTEXTPROC>(GetProcAddress("eglGetCurrentContext"));
    GetCurrentDisplay =
        reinterpret_cast<PFNEGLGETCURRENTDISPLAYPROC>(GetProcAddress("eglGetCurrentDisplay"));
    GetCurrentSurface =
        reinterpret_cast<PFNEGLGETCURRENTSURFACEPROC>(GetProcAddress("eglGetCurrentSurface"));
    GetDisplay = reinterpret_cast<PFNEGLGETDISPLAYPROC>(GetProcAddress("eglGetDisplay"));
    GetError = reinterpret_cast<PFNEGLGETERRORPROC>(GetProcAddress("eglGetError"));
    Initialize = reinterpret_cast<PFNEGLINITIALIZEPROC>(GetProcAddress("eglInitialize"));
    MakeCurrent = reinterpret_cast<PFNEGLMAKECURRENTPROC>(GetProcAddress("eglMakeCurrent"));
    QueryString = reinterpret_cast<PFNEGLQUERYSTRINGPROC>(GetProcAddress("eglQueryString"));
    CreateSyncKHR = reinterpret_cast<PFNEGLCREATESYNCKHRPROC>(GetProcAddress("eglCreateSyncKHR"));
    SignalSyncKHR = reinterpret_cast<PFNEGLSIGNALSYNCKHRPROC>(GetProcAddress("eglSignalSyncKHR"));
    DestroySyncKHR =
        reinterpret_cast<PFNEGLDESTROYSYNCKHRPROC>(GetProcAddress("eglDestroySyncKHR"));
    ClientWaitSyncKHR =
        reinterpret_cast<PFNEGLCLIENTWAITSYNCKHRPROC>(GetProcAddress("eglClientWaitSyncKHR"));
}

}  // namespace dawn::native::opengl

//
//  initGL.h
//  CS562
//
//  Created by Felipe Robledo on 8/14/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#ifndef CS562_initGL_h
#define CS562_initGL_h

#include <OpenGL/gltypes.h>

#define RENDER_PASSES 1
#define RESULT_TEXTURE RENDER_PASSES

// Initializes main frame buffer and binds output texture to it.
// NOTE: from https://support.apple.com/en-us/HT202823, the OpenGL version this
//       laptop supports is 4.1 and OpenCL 1.2
GLuint*  initGL(GLuint* frameBuffers, GLuint* renderBuffer, int fbCount, int width, int height);

#endif

//
//  OpenGLErrorHandling.c
//  CS562
//
//  Created by Felipe Robledo on 10/3/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#include <OpenGLErrorHandling.h>
#include <stdio.h>
#include <OpenGL/gl3.h>
#include <OpenGL/gltypes.h>

void CheckOpenGLError(void) {
    GLenum err = GL_NO_ERROR;
    while((err = glGetError()) != GL_NO_ERROR) {
        switch(err) {
            case GL_INVALID_ENUM:
            {
                printf("GL_INVALID_ENUM\n"); break;
            }
            case GL_INVALID_VALUE:
            {
                printf("GL_INVALID_VALUE\n"); break;
            }
            case GL_OUT_OF_MEMORY:
            {
                printf("GL_OUT_OF_MEMORY\n"); break;
            }
            case GL_INVALID_FRAMEBUFFER_OPERATION:
            {
                printf("GL_INVALID_FRAMEBUFFER_OPERATION\n"); break;
            }
            case GL_INVALID_OPERATION:
            {
                printf("GL_INVALID_OPERATION\n"); break;
            }
            default:
            {
                printf("Unknown Error\n"); break;
            }
        }
    }
}

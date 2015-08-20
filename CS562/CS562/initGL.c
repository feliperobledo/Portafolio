//
//  initGL.c
//  CS562
//
//  Created by Felipe Robledo on 8/14/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#include "initGL.h"
#include <stdlib.h>
#include <stdio.h>
#include <OpenGL/gl.h>
#include <OpenGL/gltypes.h>

GLuint* initGL(GLuint* frameBuffers, GLuint* renderBuffer,
                int fbCount, int width, int height)
{
    // Create all textures for each render pass + output texture
    GLuint *offscreenTextures = (GLuint*)malloc(sizeof(GLuint) * (RENDER_PASSES + 1));
    
    glGenTextures(RENDER_PASSES + 1, offscreenTextures);
    GLuint textureID = offscreenTextures[RESULT_TEXTURE];
    if (textureID == 0)
    {
        return NULL;
    }
    
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0,
                 GL_BGRA, GL_UNSIGNED_BYTE, NULL);//NULL means reserve texture memory, but texels are undefined
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    //----------------------------------------------------------------

    // Generate output frame buffer.
    // Tie in result texture.
    glGenFramebuffers(1, frameBuffers);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffers[0]);
    
    // Generate depth render buffer and attach it to frame buffer
    glGenRenderbuffers(1, renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer[0]);
    glRenderbufferStorage(GL_RENDERBUFFER,
                          GL_DEPTH_COMPONENT16,
                          width, height);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER,
                              renderBuffer[0]);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_DEPTH_ATTACHMENT,
                           GL_TEXTURE_2D,
                           textureID, 0);

    
    //Does the GPU support current FBO configuration?
    GLenum status;
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    switch(status)
    {
        case GL_FRAMEBUFFER_COMPLETE:
            printf("GL_FRAMEBUFFER_COMPLETE: good\n");
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
            printf("GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT\n");
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            printf("GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT\n");
            break;
        default:
            printf("GL_FRAMEBUFFER_COMPLETE: bad\n");
            break;
    }
    
    return offscreenTextures;
}
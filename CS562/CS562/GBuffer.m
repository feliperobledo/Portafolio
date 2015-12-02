//
//  GBuffer.m
//  CS562
//
//  Created by Felipe Robledo on 10/2/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "GBuffer.h"
#import <GLKit/GLKit.h>
#include <OpenGLErrorHandling.h>

@interface GBuffer(PrivateMethods)
-(void) activateTextures;
-(BOOL) createBufferWithWidth:(GLfloat)width height:(GLfloat)height;
@end

@implementation GBuffer
{
    GLuint depthRenderBuffer;
    GLuint fbo;
    GLuint textures[GBUFFER_NUM_TEXTURES];
    GLuint depthTexture;
}

-(id)initWithBounds:(NSRect)bounds {
    if((self = [super init])) {
        BOOL success = [self createBufferWithWidth:bounds.size.width height:bounds.size.height];
        NSAssert(success != NO, @"ERROR: GBuffer creation problem. OpenGL error.");
    }
    return self;
}

-(void)bindForWriting {
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, fbo);
    CheckOpenGLError();
    
    [self activateTextures];
}

-(void)bindForReading {
    glBindFramebuffer(GL_READ_FRAMEBUFFER, fbo);
    CheckOpenGLError();
}

-(void)setReadBuffer:(enum GBUFFER_TEXTURE_TYPE)textureType {
    GLenum DrawBuffers[] = { GL_COLOR_ATTACHMENT0,
        GL_COLOR_ATTACHMENT1,
        GL_COLOR_ATTACHMENT2};
    GLenum attachment = DrawBuffers[textureType];
    glReadBuffer(attachment);
}

-(void)dealloc {
    glDeleteTextures(GBUFFER_NUM_TEXTURES, textures);
    glDeleteTextures(1, &depthTexture);
    glDeleteFramebuffers(1, &fbo);
}

-(GLuint) getTextureHandleFor:(enum GBUFFER_TEXTURE_TYPE)textureType {
    return textures[textureType];
}

-(GLuint) getDepthTextureHandle {
    return depthTexture;
}

-(void) bindTheseTexturesForWriting:(enum GBUFFER_TEXTURE_TYPE[])texturesToWrite withCount:(GLint)count;{
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, fbo);
    CheckOpenGLError();
    
    GLenum TextureSlot[] = { GL_TEXTURE0,
                             GL_TEXTURE1,
                             GL_TEXTURE2};
    
    for(GLuint i = 0; i < count; ++i) {
        
        GLint textureIndex = (GLint)texturesToWrite[i];
        GLuint textureHandle = textures[textureIndex];
        
        glActiveTexture(TextureSlot[i]);
        CheckOpenGLError();
        glBindTexture(GL_TEXTURE_2D, textureHandle);
        CheckOpenGLError();
    }
}

// PRIVATES -----------------------------------------------------------------
-(void) activateTextures {
    GLenum TextureSlot[] = { GL_TEXTURE0,
                             GL_TEXTURE1,
                             GL_TEXTURE2};
    
    for (int i = 0 ;  i < GBUFFER_NUM_TEXTURES; i++) {
        GLuint textureHandle = textures[i];
        glActiveTexture(TextureSlot[i]);
        CheckOpenGLError();
        glBindTexture(GL_TEXTURE_2D, textureHandle);
        CheckOpenGLError();
    }
}

-(BOOL) createBufferWithWidth:(GLfloat)width height:(GLfloat)height {
    // Store original framebuffer object
    GLint fbObject = 0;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fbObject);
    
    // Create the FBO
    glGenFramebuffers(1, &fbo);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, fbo);
    
    // Create the gbuffer textures
    glGenTextures(GBUFFER_NUM_TEXTURES, textures);
    glGenTextures(1, &depthTexture);
    
    GLenum DrawBuffers[] = { GL_COLOR_ATTACHMENT0,
                             GL_COLOR_ATTACHMENT1,
                             GL_COLOR_ATTACHMENT2};
    //                         GL_COLOR_ATTACHMENT3 }; // index 3
    
    // Not the most optimal use of storage, but it works
    // TODO: should use 32 bit floats for the normals
    for (unsigned int i = 0 ; i < GBUFFER_NUM_TEXTURES ; i++) {
        glBindTexture(GL_TEXTURE_2D, textures[i]);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, width, height, 0, GL_RGBA, GL_FLOAT, NULL);

        // I don't understand why I need this
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 0);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
        glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER,
                               DrawBuffers[i],
                               GL_TEXTURE_2D,
                               textures[i],
                               0);
        CheckOpenGLError();
    }
    
    glBindTexture(GL_TEXTURE_2D, depthTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT16, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
    glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER,
                           GL_DEPTH_ATTACHMENT,
                           GL_TEXTURE_2D,
                           depthTexture,
                           0);
    CheckOpenGLError();
    
    // When accessing the textures inside a shader
    glDrawBuffers(GBUFFER_NUM_TEXTURES, DrawBuffers);
    CheckOpenGLError();
    
    GLenum status;
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    switch(status) {
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
            printf("ERROR: Unidentified status number %d\n",status);
            break;
    }
    
    // restore default FBO
    glBindFramebuffer(GL_FRAMEBUFFER, fbObject);
    return true;
}

-(void) showWithWidth:(GLfloat)width andHeight:(GLfloat)height {
    [self bindForReading];
    
    const GLsizei incrementX = (GLsizei)(width / (float)GBUFFER_NUM_TEXTURES);
    const GLsizei incrementY = (GLsizei)(height * 0.2f);
    GLint currentDestX = 0,
          currentDestY = 0;
    //const GLsizei increment
    
    [self setReadBuffer:GBUFFER_TEXTURE_TYPE_POSITION];
    glBlitFramebuffer(0, 0, width, height,
                      currentDestX, currentDestY,
                      currentDestX + incrementX, currentDestY + incrementY,
                      GL_COLOR_BUFFER_BIT, GL_LINEAR);
    
    currentDestX += incrementX;
    [self setReadBuffer:GBUFFER_TEXTURE_TYPE_NORMAL];
    glBlitFramebuffer(0, 0, width, height,
                      currentDestX, currentDestY,
                      currentDestX + incrementX, currentDestY + incrementY,
                      GL_COLOR_BUFFER_BIT, GL_LINEAR);
    
    currentDestX += incrementX;
    [self setReadBuffer:GBUFFER_TEXTURE_TYPE_DIFFUSE];
    glBlitFramebuffer(0, 0, width, height,
                      currentDestX, currentDestY,
                      currentDestX + incrementX, currentDestY + incrementY,
                      GL_COLOR_BUFFER_BIT, GL_LINEAR);
     /*
     currentDestX += incrementX;
     SetReadBuffer(GBUFFER_TEXTURE_TYPE_TEXCOORD);
     glBlitFramebuffer(0, 0, width, height,
                       currentDestX, currentDestY,
                       currentDestX + incrementX, currentDestY + incrementY,
                       GL_COLOR_BUFFER_BIT, GL_LINEAR);
     
     currentDestX += incrementX;
     glReadBuffer(GL_DEPTH_ATTACHMENT);
     glBlitFramebuffer(0, 0, width, height,
                       currentDestX, currentDestY,
                       currentDestX + incrementX, currentDestY + incrementY,
                       GL_DEPTH_BUFFER_BIT, GL_LINEAR);
     */
}

@end

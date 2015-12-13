//
//  RenderTarget.m
//  CS562
//
//  Created by Felipe Robledo on 9/30/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "RenderTarget.h"
#import <OpenGL/gl3.h>
#include <OpenGLErrorHandling.h>

@interface RenderTarget(PrivateMethods)
-(BOOL) createBufferWithWidth:(GLfloat)width height:(GLfloat)height;
@end


@implementation RenderTarget
{
    enum RenderTargets Type;
    GLenum currentBindType;
    GLuint fbo;
    GLuint texture;
}

-(id)initWithTargetType:(RenderTargets)type andBounds:(NSRect)bounds {
    if((self = [super init])) {
        Type = type;
        currentBindType = 0;
        fbo = texture = 0;
        
        [self createBufferWithWidth:bounds.size.width height:bounds.size.height];
    }
    return self;
}

-(void) bindFor:(GLenum)fboType {
    glBindFramebuffer(fboType,fbo);
    currentBindType = fboType;
    
    if(fboType == GL_DRAW_BUFFER) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture);
    }
    
    CheckOpenGLError();
}

-(GLuint) renderTexture {
    return texture;
}

-(void) dealloc {
    glDeleteTextures(1, &texture);
    glDeleteFramebuffers(1, &fbo);
}

// PRIVATES -----------------------------------------------------------------

-(BOOL) createBufferWithWidth:(GLfloat)width height:(GLfloat)height {
    // Store original framebuffer object
    GLint fbObject = 0;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fbObject);
    
    // Create the FBO
    glGenFramebuffers(1, &fbo);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, fbo);
    
    // Create the gbuffer textures
    glGenTextures(1, &texture);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, width, height, 0, GL_RGBA, GL_FLOAT, NULL);
    
    // I don't understand why I need this
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 0);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D,
                           texture,
                           0);
    CheckOpenGLError();
    
    // fbo requires a depth texture for completion
    GLuint depthTexture = 0;
    glGenTextures(1, &depthTexture);
    glBindTexture(GL_TEXTURE_2D, depthTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT16, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
    glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER,
                           GL_DEPTH_ATTACHMENT,
                           GL_TEXTURE_2D,
                           depthTexture,
                           0);
    CheckOpenGLError();
    
    // When accessing the textures inside a shader
    GLenum DrawBuffers[] = { GL_COLOR_ATTACHMENT0 };
    glDrawBuffers(1, DrawBuffers);
    CheckOpenGLError();
    
    GLenum status;
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    printf("\n%s ::: ",RenderTagetsStatic[Type]);
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

@end

//
//  Skydome.m
//  CS562
//
//  Created by Felipe Robledo on 11/18/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "Skydome.h"
#import <OpenGL/gl3.h>
#import <OpenGLErrorHandling.h>

@implementation Skydome
{
    GLuint shadowFbo;
    GLuint depthTexture;
    GLsizei width, height;
}

-(id) init {
    if(self = [super init]) {
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if(self = [super initWithOwner:owner]){
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser {
    if(self = [super initWithOwner:owner usingSerializer:ser]){
        
    }
    return self;
}

/* Mimic dictionary interface.
 * Required for component initialization
 */
-(id) initWithDictionary:(NSDictionary*)dict {
    
    return self;
}

-(void) serializeWith:(NSObject*)ser {
    // ..get data from object
}

-(void) postInit {
    // width and height must be the same size as the viewport
    width = 1600;
    height = 1800;
    
    GLint fbObject = 0;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fbObject);
    
    // Create the FBO
    glGenFramebuffers(1, &shadowFbo);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, shadowFbo);
    
    // Create depth texture (Need a way to get screen size for this view)
    glGenTextures(1, &depthTexture);
    glBindTexture(GL_TEXTURE_2D, depthTexture);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_R32F, width, height, 0, GL_RED, GL_FLOAT, NULL);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    
    GLfloat border[]={1.0f,0.0f,0.0f,0.0f};
    glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_BORDER_COLOR, border);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_COMPARE_MODE,
                    GL_COMPARE_REF_TO_TEXTURE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_COMPARE_FUNC,
                    GL_LESS);
        
    glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D, depthTexture, 0);
    
    // Check
    GLenum status;
    printf("Shadow Casting Depth Framebuffer Target: ");
    status = glCheckFramebufferStatus(GL_DRAW_FRAMEBUFFER);
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
}

-(CGSize) getSize {
    CGSize s;
    s.width  = width;
    s.height = height;
    return s;
}

-(GLuint) getTargetHandle {
    return depthTexture;
}

-(void)bindForWriting:(GLenum)textureTarget {
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, shadowFbo);
    
    glActiveTexture(textureTarget);
    glBindTexture(GL_TEXTURE_2D, depthTexture);
    CheckOpenGLError();
}

-(void)bindForReading {
    glBindFramebuffer(GL_READ_FRAMEBUFFER, shadowFbo);
    CheckOpenGLError();
}

@end

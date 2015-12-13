//
//  ShadowCastingLight.m
//  CS562
//
//  Created by Felipe Robledo on 10/23/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "ShadowCastingLight.h"
#import <GLKit/GLKit.h>
#import <OpenGLErrorHandling.h>
#import <PointLight.h>
#import <DirectionalLight.h>
#import <ShaderManager.h>
#import <SpotLight.h>
#import <Transform.h>

// Private declaration
@interface ShadowCastingLight(PrivateMethods)
-(void) bindWriting_PointLight:(Shader*)shader;
-(void) bindWriting_DirectionalLight:(Shader*)shader;
-(void) bindWriting_SpotLight:(Shader*)shader;

-(void) bindReading_PointLight:(Shader*)shader;
-(void) bindReading_DirectionalLight:(Shader*)shader;
-(void) bindReading_SpotLight:(Shader*)shader;
@end

@implementation ShadowCastingLight
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
    width = height = 1024;
    
    GLint fbObject = 0;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fbObject);
    
    // Create the FBO
    glGenFramebuffers(1, &shadowFbo);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, shadowFbo);
    
    // Create depth texture (Need a way to get screen size for this view)
    glGenTextures(1, &depthTexture);
    glBindTexture(GL_TEXTURE_2D, depthTexture);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_R32F, width, height, 0, GL_RED, GL_FLOAT, NULL);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 0);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D,
                           depthTexture,
                           0);
    
    GLuint depth = 0;
    glGenTextures(1, &depth);
    glBindTexture(GL_TEXTURE_2D, depth);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT16, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
    glFramebufferTexture(GL_DRAW_FRAMEBUFFER,
                         GL_DEPTH_ATTACHMENT,
                         depth,
                         0);
    
    // When accessing the textures inside a shader
    GLenum DrawBuffers[] = { GL_COLOR_ATTACHMENT0 };
    glDrawBuffers(1, DrawBuffers);
    CheckOpenGLError();
    
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

-(Shader*) getDrawShaderFrom:(ShaderManager*)shaderManager {
    // Look at all light types
    PointLight *pLight = (PointLight*)[[self Owner] getModelWithName:@"PointLight"];
    DirectionalLight *dLight = (DirectionalLight*)[[self Owner] getModelWithName:@"DirectionalLight"];
    SpotLight *sLight = (SpotLight*)[[self Owner] getModelWithName:@"SpotLight"];
    
    Shader* shader = nil;
    if (pLight != nil) {
        shader = [shaderManager getShader:@"shadowMap_PointLight"];
    } else if(dLight != nil) {
        shader = [shaderManager getShader:@"shadowMap_DirectionalLight"];
    } else if(sLight != nil) {
        shader = [shaderManager getShader:@"shadowMap_SpotLight"];
    }
    
    return shader;
}

-(GLKMatrix4) getPerspective {
    DirectionalLight *dLight = (DirectionalLight*)[[self Owner] getModelWithName:@"DirectionalLight"];
    SpotLight *sLight = (SpotLight*)[[self Owner] getModelWithName:@"SpotLight"];
    
    if(dLight != nil) {
        return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), 1, 1.0f, 100.0);
        return GLKMatrix4MakeOrtho(-30, 30, -30, 30, 1.0f, 100.0);
    } else if(sLight != nil) {
        return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), 1, 2.0f, 15.0);
    } else {
        return GLKMatrix4Identity;
    }
}

-(GLKMatrix4) getEyeTransformation {
    DirectionalLight *dLight = (DirectionalLight*)[[self Owner] getModelWithName:@"DirectionalLight"];
    SpotLight *sLight = (SpotLight*)[[self Owner] getModelWithName:@"SpotLight"];
    Transform *transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    
    GLKVector3 direction, up, right, pos = [transform position];
    if(dLight != nil) {
        direction = *[dLight direction];
    } else if(sLight != nil) {
        direction = *[sLight direction];
    } else {
        return GLKMatrix4Identity;
    }
    
    // I checked my math already, and this process right here make the
    //     toLightSpace matrix already. I don't need to invert it!
    direction = GLKVector3Normalize(direction);
    up = GLKVector3Make(0, 1, 0);
    
    //right = GLKVector3CrossProduct(direction,up);
    //right = GLKVector3Normalize(right);
    
    //up = GLKVector3CrossProduct(right, direction);
    //up = GLKVector3Normalize(up);
    
    GLKVector3 target = GLKVector3Add(pos, direction);

    
    GLKMatrix4 t = GLKMatrix4MakeLookAt(pos.x, pos.y, pos.z,
                                target.x, target.y, target.z,
                                up.x, up.y, up.z);
    
    bool isInvertible = YES;
    GLKMatrix4 inverse = GLKMatrix4Invert(t, &isInvertible);
    if(!isInvertible) {
        //NSLog(@"ERROR: Light matrix is not invertible.");
        // As far as I can tell, this case is beint hit when the light
        //     right above the the scene and the direction vector is -y axis.
        up = GLKVector3Make(1, 0 , 0);
        
        //right = GLKVector3CrossProduct(up,direction);
        //right = GLKVector3Normalize(right);
        
        //up = GLKVector3CrossProduct(direction, right);
        //up = GLKVector3Normalize(up);
        
        //GLKVector3 target = GLKVector3Add(pos, direction);
        
        t = GLKMatrix4MakeLookAt(pos.x, pos.y, pos.z,
                                 target.x, target.y, target.z,
                                  up.x, up.y, up.z);
    }
    
    return t;
    
    // Creating the inverse of the light matrix myself to check
    GLKVector4 c1 = GLKVector4MakeWithVector3(right, 0),
                c2 = GLKVector4MakeWithVector3(up, 0),
                c3 = GLKVector4MakeWithVector3(direction, 0),
                c4 = GLKVector4Make(0, 0, 0, 1);
    
    GLKMatrix4 rotation = GLKMatrix4MakeWithColumns(c1, c2, c3, c4),
    translation = GLKMatrix4MakeTranslation(pos.x,pos.y, pos.z);
    GLKMatrix4 temp = GLKMatrix4Multiply(translation,rotation);
    
    return GLKMatrix4Invert(inverse, &isInvertible);	
}

-(GLuint) getTargetHandle {
    return depthTexture;
}

-(void)bindForWriting {
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, shadowFbo);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, depthTexture);
    CheckOpenGLError();
}

-(void)bindForReading {
    glBindFramebuffer(GL_READ_FRAMEBUFFER, shadowFbo);
    CheckOpenGLError();
}

-(void) setDirection:(GLKVector3)newLookAtDir {
    DirectionalLight *dLight = (DirectionalLight*)[[self Owner] getModelWithName:@"DirectionalLight"];
    SpotLight *sLight = (SpotLight*)[[self Owner] getModelWithName:@"SpotLight"];
    
    if(dLight != nil) {
        *[dLight direction] = newLookAtDir;
    } else if(sLight != nil) {
        *[sLight direction] = newLookAtDir;
    }
}

-(void) sendUniformForWritingShadowMap:(Shader*)shader{
    PointLight *pLight = (PointLight*)[[self Owner] getModelWithName:@"PointLight"];
    DirectionalLight *dLight = (DirectionalLight*)[[self Owner] getModelWithName:@"DirectionalLight"];
    SpotLight *sLight = (SpotLight*)[[self Owner] getModelWithName:@"SpotLight"];
    
    if (pLight != nil) {
        [self bindWriting_PointLight:shader];
    } else if(dLight != nil) {
        [self bindWriting_DirectionalLight:shader];
    } else if(sLight != nil) {
        [self bindWriting_SpotLight:shader];
    }
}

-(void) sendUniformForReadingShadowMap:(Shader*)shader {
    PointLight *pLight = (PointLight*)[[self Owner] getModelWithName:@"PointLight"];
    DirectionalLight *dLight = (DirectionalLight*)[[self Owner] getModelWithName:@"DirectionalLight"];
    SpotLight *sLight = (SpotLight*)[[self Owner] getModelWithName:@"SpotLight"];
    
    if (pLight != nil) {
        [self bindReading_PointLight:shader];
    } else if(dLight != nil) {
        [self bindReading_DirectionalLight:shader];
    } else if(sLight != nil) {
        [self bindReading_SpotLight:shader];
    }
}

// PRIVATES --------------------------------------------------------------------

-(void) bindWriting_PointLight:(Shader*)shader {
    
}

-(void) bindWriting_DirectionalLight:(Shader*)shader {
    
}

-(void) bindWriting_SpotLight:(Shader*)shader {
    
}

-(void) bindReading_PointLight:(Shader*)shader {
    
}

-(void) bindReading_DirectionalLight:(Shader*)shader {
    
}

-(void) bindReading_SpotLight:(Shader*)shader {
    
}

@end

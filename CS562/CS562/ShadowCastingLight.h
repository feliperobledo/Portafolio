//
//  ShadowCastingLight.h
//  CS562
//
//  Created by Felipe Robledo on 10/23/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>
#import <GLKit/GLKMatrix4.h>
#import <OpenGL/gltypes.h>

@class ShaderManager;
@class Shader;

@interface ShadowCastingLight : IView

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

-(Shader*) getDrawShaderFrom:(ShaderManager*)shaderManager;
-(GLKMatrix4) getPerspective;
-(GLKMatrix4) getEyeTransformation;
-(GLuint) getTargetHandle;
-(CGSize) getSize;
-(void) bindForWriting;
-(void) bindForReading;

-(void) setDirection:(GLKVector3)newLookAtDir;

// TODO: should this really be in the view?
-(void) sendUniformForWritingShadowMap:(Shader*)shader;
-(void) sendUniformForReadingShadowMap:(Shader*)shader;

@end

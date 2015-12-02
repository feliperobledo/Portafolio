//
//  GBuffer.h
//  CS562
//
//  Created by Felipe Robledo on 10/2/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gltypes.h>

/*
 
 PROBLEM: my diffuse and normal textures had each other info, and the
 labels were wrong. Changing the ortder on the Gbuffer enums solves
 the problem, but it does not make sense that I had to do that...
 
 */

enum GBUFFER_TEXTURE_TYPE {
    GBUFFER_TEXTURE_TYPE_NORMAL,
    GBUFFER_TEXTURE_TYPE_DIFFUSE,
    GBUFFER_TEXTURE_TYPE_POSITION,
    //GBUFFER_TEXTURE_TYPE_TEXCOORD,
    GBUFFER_NUM_TEXTURES
};

@interface GBuffer : NSObject

-(id)initWithBounds:(NSRect)bounds;
-(void)bindForWriting;
-(void)bindForReading;
-(void)setReadBuffer:(enum GBUFFER_TEXTURE_TYPE)textureType;
-(GLuint) getTextureHandleFor:(enum GBUFFER_TEXTURE_TYPE)textureType;
-(GLuint) getDepthTextureHandle;
-(void) bindTheseTexturesForWriting:(enum GBUFFER_TEXTURE_TYPE[])texturesToWrite withCount:(GLint)count;

-(void) showWithWidth:(GLfloat)width andHeight:(GLfloat)height;

@end

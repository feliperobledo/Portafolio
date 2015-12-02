//
//  Image.h
//  HelloOpenGL
//
//  Created by Felipe Robledo on 10/30/14.
//  Copyright (c) 2014 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef char				s8;
typedef unsigned char		u8;
typedef signed short		s16;
typedef unsigned short		u16;
typedef signed long			s32;
typedef unsigned long		u32;
typedef signed long long	s64;
typedef unsigned long long	u64;
typedef float				f32;
typedef double				f64;

@interface Image : NSObject
{
    unsigned char* m_Data;
    signed long m_BPP;
    GLint m_SizeX;
    GLint m_SizeY;
    
    //GL specific privates
    GLint m_ID;
}

-(id)init;

//statics
+(Image*)Load:(NSString*)path;
+(void)Free:(Image*)image;

-(GLuint)textureID;
-(void)setTextureID:(GLuint)newID;
-(void)sendTexture:(GLenum)texture;

-(unsigned char*) Data;
-(signed long) BPP;
-(GLint) SizeX;
-(GLint) SizeY;


@end

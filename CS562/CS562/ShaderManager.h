//
//  ShaderManager.h
//  HelloOpenGL
//
//  Created by Felipe Robledo on 10/20/14.
//  Copyright (c) 2014 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Shader.h"

@interface ShaderManager : NSObject

@property (nonatomic,strong) NSMutableDictionary* m_ShaderDictionary;

-(Shader*) newProgramShaderWithVertex:(NSString*)vertName Fragment:(NSString*)fragName Named:(NSString*)identifier;
-(void) bindShader:(Shader*)shader Attribute:(NSString*) identifier Location:(GLuint)loc;
-(void) link:(Shader*)shader;
-(GLint) getShader:(Shader*)shader Uniform:(NSString*)identifier;
-(Shader*) getShader:(NSString*)key;

@end

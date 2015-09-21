//
//  ShaderManager.m
//  HelloOpenGL
//
//  Created by Felipe Robledo on 10/20/14.
//  Copyright (c) 2014 Felipe Robledo. All rights reserved.
//

#import "ShaderManager.h"

@implementation ShaderManager

-(id)init
{
    if(self = [super init])
    {
        self.m_ShaderDictionary = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(Shader*) newProgramShaderWithVertex:(NSString*)vertName Fragment:(NSString*)fragName Named:(NSString*)identifier;
{
    //Check if identifier is a taken key
    if([self.m_ShaderDictionary objectForKey:identifier] != nil)
    {
        return nil;
    }
    
    //Create new shader if the identifying key does not exist
    Shader* newShader = [[Shader alloc] init];
    newShader.m_Name = identifier;
    
    //open the shader
    NSString* vertShaderFile = [newShader openShader:vertName withExtension:@"vsh"];
    NSString* fragShaderFile = [newShader openShader:fragName withExtension:@"fsh"];
    
    //create the program
    [newShader createShaderProgram];
    
    //load the shader
    GLuint vertShader = [newShader load:GL_VERTEX_SHADER shader:[vertShaderFile UTF8String]];
    if(vertShader != 0)
    {
        NSLog(@"Attaching vertex shader");
        [newShader attachShader:vertShader];
    }
    else
    {
        NSLog(@"Problem with vertex shader: %s",[vertName UTF8String]);
    }
    
    GLuint fragShader = [newShader load:GL_FRAGMENT_SHADER shader:[fragShaderFile UTF8String]];
    if(fragShader != 0)
    {
        NSLog(@"Attaching fragment shader");
        [newShader attachShader:fragShader];
    }
    else
    {
        NSLog(@"Problem with fragment shader: %s",[fragName UTF8String]);
    }
    
    [self.m_ShaderDictionary setObject:newShader forKey:identifier];
    
    return newShader;
}

-(void) bindShader:(Shader*)shader Attribute:(NSString*) identifier Location:(GLuint)loc
{
    glBindAttribLocation([shader program], loc, [identifier UTF8String]);
}

-(void) link:(Shader*)shader
{
    [shader link];
}

-(GLint) getShader:(Shader*)shader Uniform:(NSString*)identifier
{
    const GLint NOT_FOUND = -1;
    GLint uniformLocation = [shader getUniform:identifier];
    if(uniformLocation != NOT_FOUND)
    {
        [shader addUniform:identifier Location:uniformLocation];
    }
    return uniformLocation;
}

-(Shader*) getShader:(NSString*)key
{
    return [self.m_ShaderDictionary objectForKey:key];
}


@end

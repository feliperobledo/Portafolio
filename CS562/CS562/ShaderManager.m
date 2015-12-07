//
//  ShaderManager.m
//  HelloOpenGL
//
//  Created by Felipe Robledo on 10/20/14.
//  Copyright (c) 2014 Felipe Robledo. All rights reserved.
//

#import "ShaderManager.h"
#import <Mesh.h>
#include <OpenGLErrorHandling.h>

@interface ShaderManager(PrivateShaderManager)
-(NSDictionary*)createMetaFrom:(NSString*)file;
-(BOOL) vertShaderUniforms:(NSDictionary*)vertUniforms equalFragShaderUniforms:(NSDictionary*)fragUniforms;

-(void) setUpShaderAttributeLocationConventions:(Shader*)newShader;
-(void) checkShaderFollowsAttributeConventions:(Shader*)newShader;
@end

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
    if([self.m_ShaderDictionary objectForKey:identifier] != nil) {
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
    
    NSDictionary *vertShaderUniforms = nil,
                 *fragShaderUniforms = nil;
    
    //load the shader
    GLuint vertShader = [newShader load:GL_VERTEX_SHADER shader:[vertShaderFile UTF8String]];
    if(vertShader != 0) {
        [newShader attachShader:vertShader ofType:GL_VERTEX_SHADER];
        vertShaderUniforms = [self createMetaFrom:vertShaderFile];
    } else {
        NSLog(@"Problem with vertex shader: %s",[vertName UTF8String]);
        return nil;
    }
    
    GLuint fragShader = [newShader load:GL_FRAGMENT_SHADER shader:[fragShaderFile UTF8String]];
    if(fragShader != 0) {
        [newShader attachShader:fragShader ofType:GL_FRAGMENT_SHADER];
        fragShaderUniforms = [self createMetaFrom:fragShaderFile];
    } else {
        NSLog(@"Problem with fragment shader: %s",[fragName UTF8String]);
        return nil;
    }
    
    if( ![self vertShaderUniforms:vertShaderUniforms equalFragShaderUniforms:fragShaderUniforms]) {
        NSLog(@"Uniforms Mismatch: %@\n%@",vertShaderUniforms,fragShaderUniforms);
        return nil;
    }
    
    // Setting up convention of vertex attributes accross ALL shaders
    [self setUpShaderAttributeLocationConventions:newShader];
    
    [newShader link];
    
    [self.m_ShaderDictionary setObject:newShader forKey:identifier];
    [newShader extractOpenGLUniformLocationFromUniforms:vertShaderUniforms];
    
    NSLog(@"%s : uniforms found",[identifier UTF8String]);
    for(NSString* uniformName in vertShaderUniforms) {
        NSLog(@"\t%s",[uniformName UTF8String]);
    }
    
    [self checkShaderFollowsAttributeConventions:newShader];
    
    return newShader;
}

-(void) extractUniformsFromShaders {
    
}

-(void) bindShader:(Shader*)shader Attribute:(NSString*)identifier Location:(GLuint)loc
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
    if(uniformLocation != NOT_FOUND) {
        [shader addUniform:identifier Location:uniformLocation];
    }
    return uniformLocation;
}

-(Shader*) getShader:(NSString*)key
{
    return [self.m_ShaderDictionary objectForKey:key];
}

// PRIVATE----------------------------------------------------------------------
-(NSDictionary*)createMetaFrom:(NSString*)file {
    NSArray *lines = [file componentsSeparatedByString:@"\n"];
    BOOL readingUniforms = NO;
    NSMutableDictionary* uniformData = [[NSMutableDictionary alloc] init];
    
    for (NSString* line in lines) {
        // if NOT in reading uniforms mode and
        // line does not contain "//uniforms"
        //     skip
        if(readingUniforms) {
            
            NSArray* uniformParts = [line componentsSeparatedByString:@" "];
            if([uniformParts count] != 3) {
                break;
            }
            
            NSString* uniformType = [uniformParts objectAtIndex:1];
            NSString* uniformIdentifier = [uniformParts objectAtIndex:2];

            // Remove the  ";" at the end of the identifier
            uniformIdentifier = [uniformIdentifier substringToIndex:[uniformIdentifier length] - 1 ];
            
            // For O(1) search purposes, store the uniform along with its type.
            // I don't know what I will use the type for, but I will keep it
            // around.
            [uniformData setObject:uniformType forKey:uniformIdentifier];
        } else {
            readingUniforms = [line containsString:@"// uniforms"];
        }
    }
    return uniformData;
}

-(BOOL) vertShaderUniforms:(NSDictionary*)vertUniforms equalFragShaderUniforms:(NSDictionary*)fragUniforms {
    if([vertUniforms count] != [fragUniforms count]) {
        return NO;
    }
    
    for(NSString* uniformName in vertUniforms) {
        if([fragUniforms valueForKey:uniformName] == nil) {
            return NO;
        }
    }
    
    return YES;
}

-(void) setUpShaderAttributeLocationConventions:(Shader*)newShader {
    glBindAttribLocation([newShader program], GLKVertexAttribPosition, "position");
    glBindAttribLocation([newShader program], GLKVertexAttribPosition, "position");
    glBindAttribLocation([newShader program], GLKVertexAttribTexCoord0, "u");
    glBindAttribLocation([newShader program], GLKVertexAttribTexCoord1, "v");
    glBindAttribLocation([newShader program], GLKVertexAttribColor, "color");
    glBindAttribLocation([newShader program], GLKVertexAttribTangent, "tangent");
    glBindAttribLocation([newShader program], GLKVertexAttribBinormal, "bitanget");
    CheckOpenGLError();
}

-(void) checkShaderFollowsAttributeConventions:(Shader*)newShader {
    GLint attrPos   = glGetAttribLocation([newShader program], "position"),
    attrN     = glGetAttribLocation([newShader program], "normal"),
    attrU    = glGetAttribLocation([newShader program], "u"),
    attrV    = glGetAttribLocation([newShader program], "v"),
    attrCol   = glGetAttribLocation([newShader program], "color"),
    attrTan   = glGetAttribLocation([newShader program], "tangent"),
    attrBiTan = glGetAttribLocation([newShader program], "bitanget");
    CheckOpenGLError();
    
    if(attrPos != GLKVertexAttribPosition) {
        NSLog(@"\t %s does not have attribute: position", [[newShader m_Name] UTF8String]);
        
    }
    if(attrN != GLKVertexAttribNormal) {
        NSLog(@"\t %s does not have attribute: normal", [[newShader m_Name] UTF8String]);
    }
    
    if(attrU != GLKVertexAttribTexCoord0) {
        NSLog(@"\t %s does not have attribute: u", [[newShader m_Name] UTF8String]);
    }
    
    if(attrV != GLKVertexAttribTexCoord1) {
        NSLog(@"\t %s does not have attribute: v", [[newShader m_Name] UTF8String]);
    }
    
    if(attrCol != GLKVertexAttribColor) {
        NSLog(@"\t %s does not have attribute: color", [[newShader m_Name] UTF8String]);
    }
    
    if(attrTan != GLKVertexAttribTangent) {
        NSLog(@"\t %s does not have attribute: tangent", [[newShader m_Name] UTF8String]);
    }
    
    if(attrBiTan != GLKVertexAttribBinormal) {
        NSLog(@"\t %s does not have attribute: bitangent", [[newShader m_Name] UTF8String]);
    }
}


@end

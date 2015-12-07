/*Start Header------------------------------------------------------------
 Copyright(C) 2013 DigiPen Institute of Technology Reproduction or
 disclosure of this file or its contents without the prior written
 consent of DigiPen Institute of Technology is prohibited.
 File Name: Shader.m
 Purpose: A class that abstracts all OpenGL ES shader and shader program
 handles for the purpose of usability. Only objects that are to
 be rendered should use this class.
 Platform: Mac OX X Version 10.9.5
 ms2012 (Compiler)
 Processor: Intel(R) Core(TM) i5 @ 2.40Hz
 Type: 64-bit OS
 RAM: 8 GB
 Hard-Drive: 250GB SSD
 Project: f.robledo_CS300_1
 Author: Felipe Robledo, f.robledo, 80002511
 Creation Date: 09/27/2014
 -End Header-------------------------------------------------------------*/

#import "Shader.h"
#include <stdio.h>

@implementation Shader{
    GLuint m_ShaderProgram;
    GLuint m_VertShader;
    GLuint m_FragShader;
}

-(id) init
{
    if(self = [super init])
    {
        self.m_Uniforms = [[NSMutableDictionary alloc] init];
    }
    return self;
}
//methods
-(void) createShaderProgram
{
    m_ShaderProgram = glCreateProgram();
    if(m_ShaderProgram == 0) {
        NSLog(@"Failed to create shader program");
    }
}

-(GLuint) load:(GLenum)type shader:(const char*)source
{
    GLuint shader = 0;
    GLint compiled = 0;
    
    //Create the shader object
    shader = glCreateShader(type);
    
    if(shader == 0) {
        return 0;
    }
    
    //Load the shader source
    glShaderSource(shader,1,&source,NULL);
    
    //Compile the shader
    glCompileShader(shader);
    
    //Check the compile status
    glGetShaderiv(shader,GL_COMPILE_STATUS,&compiled);
    if(!compiled) {
        GLint infoLen = 0;
        glGetShaderiv(shader,GL_INFO_LOG_LENGTH,&infoLen);
        
        if(infoLen > 1)
        {
            char* infoLog = (char*)malloc(sizeof(char) * infoLen);
            
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            printf("%s\n",infoLog);
            
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    } else {
        NSLog(@"SUCCESS: Shader compilation successful.");
    }
    
    return shader;
}

-(NSString*) openShader:(NSString*)filename withExtension:(NSString*)extension
{
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:filename
                                                           ofType:extension];
    NSData* myData = [NSData dataWithContentsOfFile:shaderPath];
    if(myData)
    {
        //The apple documentation says that by default, NSString is UTF-16, so I don't know if
        //it is okay to load as UTF-8
        NSString* newStr = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",newStr);
        return newStr;
    }
    return nil;
}

-(GLint) getUniform:(NSString*)identifier
{
    return glGetUniformLocation(m_ShaderProgram, [identifier UTF8String]);
}

-(GLint) uniformFromDictionary:(NSString*)identifier
{
    NSNumber* location = [self.m_Uniforms objectForKey:identifier];
    NSAssert1(location != nil,
              @"ERROR: Querying for a uniform that shader does not have: %s",
              [identifier UTF8String]);
    return [location intValue];
}

-(void) addUniform:(NSString*)identifier Location:(GLint)loc
{
    NSInteger uniformLocation = loc;
    [self.m_Uniforms setObject:[NSNumber numberWithInteger:uniformLocation] forKey:identifier];
}

-(void) attachShader:(GLuint)shaderId ofType:(GLenum)type
{
    if (type == GL_FRAGMENT_SHADER) {
        m_FragShader = shaderId;
    } else if(type == GL_VERTEX_SHADER) {
        m_VertShader = shaderId;
    }
    glAttachShader(m_ShaderProgram, shaderId);
}

-(void)link
{
    glLinkProgram(m_ShaderProgram);
    
    GLint linked = 0;
    glGetProgramiv(m_ShaderProgram,GL_LINK_STATUS,&linked);
    if(!linked)
    {
        GLint infoLen = 0;
        
        glGetProgramiv(m_ShaderProgram,GL_INFO_LOG_LENGTH,&infoLen);
        
        if(infoLen > 0)
        {
            char* infoLog = (char*)malloc(sizeof(char)*infoLen);
            
            glGetProgramInfoLog(m_ShaderProgram, infoLen, NULL, infoLog);
            printf("Error linking program:\n%s\n",infoLog);
            
            free(infoLog);
        }
        
        printf("Deleting shader program");
        glDeleteProgram(m_ShaderProgram);
    }
    else
    {
        NSLog(@"Shader linked successfully");
    }
}

-(void)use
{
   glUseProgram(m_ShaderProgram);
}

-(void)unuse
{
    glUseProgram(0);
}

-(GLuint)program {
    return m_ShaderProgram;
}

-(void)flushGL
{
    glDeleteProgram(m_ShaderProgram);
    glDeleteShader(m_VertShader);
    glDeleteShader(m_FragShader);
}

-(void)dealloc
{
    [self flushGL];
}

-(void)extractOpenGLUniformLocationFromUniforms:(NSDictionary*)uniforms {
    NSAssert(uniforms != nil, @"ERROR: uniforms may not be nil");
    
    for(NSString* uniformIdentifier in uniforms) {
        GLint location = [self getUniform:uniformIdentifier];
        if(location < 0) {
            NSLog(@"In %s shader: %s not being used",[self.m_Name UTF8String],[uniformIdentifier UTF8String]);
        }
        
        [self addUniform:uniformIdentifier Location:location];
    }
}

-(NSDictionary*) getUniforms {
    return self.m_Uniforms;
}

/*******************************UNIFORM OVERLOADS********************************/

-(void) uniformMatrix:(GLint)uniLocation Instances:(GLuint)i Transpose:(GLboolean)t Data:(const GLfloat*)d
{
     glUniformMatrix4fv(uniLocation,i,t,d);
}

@end

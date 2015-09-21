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

@implementation Shader
@synthesize m_ShaderProgram = ShaderProgram;


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
    ShaderProgram = glCreateProgram();
    if(ShaderProgram == 0)
    {
        NSLog(@"Failed to create shader program");
    }
}

-(GLuint) load:(GLenum)type shader:(const char*)source
{
    GLuint shader = 0;
    GLint compiled = 0;
    
    //Create the shader object
    shader = glCreateShader(type);
    
    if(shader == 0)
        return 0;
    
    //Load the shader source
    glShaderSource(shader,1,&source,NULL);
    
    //Compile the shader
    glCompileShader(shader);
    
    //Check the compile status
    glGetShaderiv(shader,GL_COMPILE_STATUS,&compiled);
    
    if(!compiled)
    {
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
    return glGetUniformLocation(self.m_ShaderProgram, [identifier UTF8String]);
}

-(GLint) uniformFromDictionary:(NSString*)identifier
{
    NSNumber* location = [self.m_Uniforms objectForKey:identifier];
    if(location != nil)
    {
        return [location intValue];
    }
    return -1;
}

-(void) addUniform:(NSString*)identifier Location:(GLint)loc
{
    NSInteger uniformLocation = loc;
    [self.m_Uniforms setObject:[NSNumber numberWithInteger:uniformLocation] forKey:identifier];
}

-(void) attachShader:(GLuint)shaderId
{
    glAttachShader(ShaderProgram, shaderId);
}

-(void)link
{
    glLinkProgram(ShaderProgram);
    
    GLint linked = 0;
    glGetProgramiv(ShaderProgram,GL_LINK_STATUS,&linked);
    if(!linked)
    {
        GLint infoLen = 0;
        
        glGetProgramiv(ShaderProgram,GL_INFO_LOG_LENGTH,&infoLen);
        
        if(infoLen > 0)
        {
            char* infoLog = (char*)malloc(sizeof(char)*infoLen);
            
            glGetProgramInfoLog(ShaderProgram, infoLen, NULL, infoLog);
            printf("Error linking program:\n%s\n",infoLog);
            
            free(infoLog);
        }
        
        printf("Deleting shader program");
        glDeleteProgram(ShaderProgram);
    }
    else
    {
        NSLog(@"Shader linked successfully");
    }
}

-(void)use
{
   glUseProgram(ShaderProgram);
}

-(void)unuse
{
    glUseProgram(0);
}

-(void)flushGL
{
    glDeleteProgram(ShaderProgram);
    glDeleteShader(m_VertShader);
    glDeleteShader(m_FragShader);
}

-(void)dealloc
{
    [self flushGL];
}

/*******************************UNIFORM OVERLOADS********************************/

-(void) uniformMatrix:(GLint)uniLocation Instances:(GLuint)i Transpose:(GLboolean)t Data:(const GLfloat*)d
{
     glUniformMatrix4fv(uniLocation,i,t,d);
}

@end

/*Start Header------------------------------------------------------------
 Copyright(C) 2013 DigiPen Institute of Technology Reproduction or
 disclosure of this file or its contents without the prior written
 consent of DigiPen Institute of Technology is prohibited.
 File Name: Shader.h
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

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Shader : NSObject

@property (nonatomic,strong) NSMutableDictionary* m_Uniforms;//string-integer
@property (nonatomic,retain) NSString* m_Name;

-(id) init;
-(void) createShaderProgram;
-(GLuint) load:(GLenum)type shader:(const char*)source;
-(NSString*) openShader:(NSString*)filename withExtension:(NSString*)extension;
-(GLint) getUniform:(NSString*)identifier;
-(GLuint) uniformFromDictionary:(NSString*)identifier;
-(void) addUniform:(NSString*)identifier Location:(GLint)loc;
-(void) attachShader:(GLuint)shaderId ofType:(GLenum)type;
-(void) extractUniformsFromShaders;
-(void)link;
-(void)use;
-(void)unuse;
-(void)dealloc;

-(GLuint)program;
-(NSDictionary*) getUniforms;
-(void)extractOpenGLUniformLocationFromUniforms:(NSDictionary*)uniforms;

//Need whole lot of unifor methods here
-(void) uniformMatrix:(GLint)uniLocation Instances:(GLuint)i Transpose:(GLboolean)t Data:(const GLfloat*)d;


@end

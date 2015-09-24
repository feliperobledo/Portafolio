//
//  View.m
//  CS562
//
//  This view knows about the deferred rendering process.
//
//  Created by Felipe Robledo on 7/5/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//


// FIXME: Remove
float points[] = {
    0.0f,  0.5f,  0.0f,
    0.5f, -0.5f,  0.0f,
    -0.5f, -0.5f,  0.0f
};

#import "View.h"
#include "initGL.h"
#include <OpenGL/gl3.h>
#include <OpenGL/gltypes.h>
#include <GLKit/GLKit.h>

@implementation View
{
    GLuint m_FrameBufferIds[1];
    GLuint m_RenderBuffers[1];
    GLuint *m_OffScreenTextures;
    
    // FIXME: Remove
    GLuint vbo;
    GLuint vao;
    GLuint shader_programme;
}

// Use this method to allocate and initialize the NSOpenGLPixelFormat object
+ (NSOpenGLPixelFormat*)defaultPixelFormat {
    
    NSOpenGLPixelFormatAttribute attributes [] = {
        //kCGLPFAOpenGLProfile,
        
        // Specifying "NoRecovery" gives us a context that cannot fall back to the software renderer.  This makes the View-based context a compatible with the layer-backed context, enabling us to use the "shareContext" feature to share textures, display lists, and other OpenGL objects between the two.
        //NSOpenGLPFANoRecovery, // Enable automatic use of OpenGL "share" contexts.
        
        // Helps guarantee all displays support pixel format
        NSOpenGLPFAScreenMask, 0,
 
        // Don't fall back to the software renderer
        NSOpenGLPFANoRecovery,

        // pixel format available to all renderers
        NSOpenGLPFAAllRenderers,
        
        // Only hardware-accelerated renderers are considered.
        NSOpenGLPFAAccelerated,
        
        // Front and Back Buffer
        NSOpenGLPFADoubleBuffer,
        
        // Bit sizes
        NSOpenGLPFAColorSize,  32,
        NSOpenGLPFADepthSize,  24,
        NSOpenGLPFAAlphaSize,   8,
        NSOpenGLPFAStencilSize, 8,
        
        // Use color, depth and accumulation sizes of sizes equal to or greater
        NSOpenGLPFAClosestPolicy,
        
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        
        (NSOpenGLPixelFormatAttribute)nil
    };
    
    // Adds the display mask attribute for selected display
    CGDirectDisplayID display = CGMainDisplayID ();
    attributes[1] = (NSOpenGLPixelFormatAttribute) CGDisplayIDToOpenGLDisplayMask (display);
    
    return  [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
}

// Retains the pixel format and sets up the notification
//     NSViewGlobalFrameDidChangeNotification
// Designated initializer for instances of NSView. However, when the view is
//     created from the storyboard file, this will not be called.
- (id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat*)format
{
    self = [super initWithFrame:frameRect];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(_surfaceNeedsUpdate:)
                                              name:NSViewGlobalFrameDidChangeNotification
                                              object:self];
        
        
        m_GLContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
        if( m_GLContext != nil) {
            [self setWantsLayer:YES];
            [m_GLContext setView:self];
            [m_GLContext makeCurrentContext];
            
            NSLog(@"OpenGL version = %s", glGetString(GL_VERSION));
            NSLog(@"GLSL version = %s", glGetString(GL_SHADING_LANGUAGE_VERSION));
            
            NSRect pixelBounds = [self convertRectToBacking:[self bounds]];
            glViewport(0, 0,
                       (GLint)NSWidth(pixelBounds),
                       (GLint)NSHeight(pixelBounds));
            
            m_HasGeneratedFocus = NO;
            
            // FIXME: Remove
            glGenBuffers (1, &vbo);
            glBindBuffer (GL_ARRAY_BUFFER, vbo);
            glBufferData (GL_ARRAY_BUFFER, 9 * sizeof (float), points, GL_STATIC_DRAW);
            
            // FIXME: Remove
            // Remember: VAOs allow us to matain a state of vbo's. This way, we
            //           only have to trigger the vao to use all vbo's attached
            //           to it.
            glGenVertexArrays (1, &vao);
            glBindVertexArray (vao);
            { // specify on which attribute of the vao
                glEnableVertexAttribArray (GLKVertexAttribPosition);
                glBindBuffer (GL_ARRAY_BUFFER, vbo);
                glVertexAttribPointer (0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
            }
            
            // FIXME: Remove
            // Example of creating shaders
            NSBundle* mainBundle = [NSBundle mainBundle];
            
            NSString *vertexShaderPath = [mainBundle pathForResource:@"simple" ofType:@"vsh"];
            NSString *fragmentShaderPath = [mainBundle pathForResource:@"simple" ofType:@"fsh"];
            
            NSData
            *vshData = [NSData dataWithContentsOfFile:vertexShaderPath],
            *fshData = [NSData dataWithContentsOfFile:fragmentShaderPath];
            
            NSString *vsh = nil, *fsh = nil;
            if(vshData && fshData)
            {
                vsh = [[NSString alloc] initWithData:vshData encoding:NSUTF8StringEncoding];
                fsh = [[NSString alloc] initWithData:fshData encoding:NSUTF8StringEncoding];
            }
            
            const char* vshSource = [vsh UTF8String];
            GLuint vs = glCreateShader (GL_VERTEX_SHADER);
            glShaderSource (vs, 1, &vshSource, NULL);
            glCompileShader (vs);
            
            const char* fshSource = [fsh UTF8String];
            GLuint fs = glCreateShader (GL_FRAGMENT_SHADER);
            glShaderSource (fs, 1, &fshSource, NULL);
            glCompileShader (fs);
            
            shader_programme = glCreateProgram ();
            glAttachShader (shader_programme, fs);
            glAttachShader (shader_programme, vs);
            glLinkProgram (shader_programme);
            
            GLint linked = 0;
            glGetProgramiv(shader_programme,GL_LINK_STATUS,&linked);
            if(!linked)
            {
                GLint infoLen = 0;
                
                glGetProgramiv(shader_programme,GL_INFO_LOG_LENGTH,&infoLen);
                
                if(infoLen > 0)
                {
                    char* infoLog = (char*)malloc(sizeof(char)*infoLen);
                    
                    glGetProgramInfoLog(shader_programme, infoLen, NULL, infoLog);
                    printf("Error linking program:\n%s\n",infoLog);
                    
                    free(infoLog);
                }
                
                printf("Deleting shader program");
                glDeleteProgram(shader_programme);
            }
            else
            {
                NSLog(@"Shader linked successfully");
            }
        }
    }
    return self;
}

- (void) _surfaceNeedsUpdate:(NSNotification*)notification {
    [self update];
    //[m_GLContext update];
}

// Used to set the OpenGL context we are going to use to draw
- (void)setOpenGLContext:(NSOpenGLContext*)context {
    m_GLContext = context;
}

// Context gettor
- (NSOpenGLContext*)openGLContext {
    return m_GLContext;
}

// Use this method to clear and release the NSOpenGLContext object
- (void)clearGLContext {
    [m_GLContext clearDrawable];
}

// Use this method to initialize OpenGL state after creating NSOpenGLContext
- (void)prepareOpenGL {
    if(m_HasGeneratedFocus) {
        return;
    }
    
    // Set-up for including a backed-layer. Should dive into this more
    //    deeply later.
    //CALayer* newBackedLayer = [[CALayer alloc]init];
    //[self setWantsLayer:YES];
    //[self setLayer:newBackedLayer];
    
    GLint rendererID = 0;
    [m_GLContext getValues:&rendererID forParameter:NSOpenGLCPCurrentRendererID];
    NSLog(@"Renderer/FrameBuffer ID: %d",rendererID);
    
    GLint drawFboId = 0, readFboId = 0, fbObject = 0;
    glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &drawFboId);
    glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING, &readFboId);
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fbObject);
    NSLog(@"Draw FBO ID: %d",drawFboId);
    NSLog(@"Read FBO ID: %d",readFboId);
    NSLog(@"FBO ID: %d",fbObject);
    
    if (false) {
        NSRect pixelBounds = [self convertRectToBacking:[self bounds]];
        m_OffScreenTextures = initGL(m_FrameBufferIds, m_RenderBuffers, 1, NSWidth(pixelBounds), NSHeight(pixelBounds));
        
        GLenum ret = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (ret != GL_NO_ERROR) {
            if( ret != GL_FRAMEBUFFER_COMPLETE) {
                NSLog(@"Something bad happened");
            }
        }
        
        glBindBuffer(GL_FRAMEBUFFER, fbObject);
    }

    m_HasGeneratedFocus = true;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    // call some code to set project back to initial state
}

// Call the update method of the NSOpenGLContext class
- (void)update {
    NSLog(@"update");

    if(m_GLContext) {
        //[m_GLContext update];
    }
    
    //[self display];
}

-(void) draw {
    if(m_GLContext) {
        [m_GLContext makeCurrentContext];
        
        // wipe the drawing surface clear
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glUseProgram (shader_programme);
        glBindVertexArray (vao);
        // draw points 0-3 from the currently bound VAO with current in-use shader
        glDrawArrays (GL_TRIANGLES, 0, 3);
        
        [m_GLContext flushBuffer];
    }
}

-(void) updateLayer {
    NSLog(@"updateLayer");
}

// In-case you need to switch your pixel format
- (void)setPixelFormat:(NSOpenGLPixelFormat*)pixelFormat {
    m_PixelFormat = pixelFormat;
}

// Returns the currect pixel format
- (NSOpenGLPixelFormat*)pixelFormat {
    return m_PixelFormat;
}

// Ensure that the view is locked prior to drawing and that the context is the
//     context is the current one.
- (void)lockFocus
{
    NSOpenGLContext* context = [self openGLContext];
    
    [super lockFocus];
    if ([context view] != self) {
        [context setView:self];
    }
    
    [context makeCurrentContext];
}

// Make all draw calls
- (void)drawRect:(NSRect)dirtyRect {
    NSLog(@"Drawing");
    
    [super drawRect:dirtyRect];
}

-(void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    if ([self window] == nil)
        [m_GLContext clearDrawable];
}

- (void) updateConstraints {
    NSWindow* window = self.window;
    NSRect frame = [window frame];
}

-(void) rightMouseDown:(NSEvent *)theEvent {
    // This is the only method that calls the super's version of the method.
    [super rightMouseDown:theEvent];
    
    NSPoint aPoint = [theEvent locationInWindow];
    NSLog(@"Event Point: [%f,%f]\n",aPoint.x,aPoint.y);
    NSPoint localPoint = [self convertPoint:aPoint fromView:nil];
    NSLog(@"Local Point: [%f,%f]\n",localPoint.x,localPoint.y);
}

-(void) dealloc {
    glDeleteTextures(1, m_OffScreenTextures);
    glDeleteFramebuffers(1, m_FrameBufferIds);
}
@end

//
//  View.m
//  CS562
//
//  Created by Felipe Robledo on 7/5/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "View.h"
#include "initGL.h"
#include <OpenGL/gl.h>
#include <OpenGL/gltypes.h>

@implementation View
{
    GLuint m_FrameBufferIds[1];
    GLuint m_RenderBuffers[1];
    GLuint *m_OffScreenTextures;
}

// Use this method to allocate and initialize the NSOpenGLPixelFormat object
+ (NSOpenGLPixelFormat*)defaultPixelFormat {
    
    NSOpenGLPixelFormatAttribute attributes [] = {
        //kCGLPFAOpenGLProfile,
        
        // Helps guarantee all displays support pixel format
        NSOpenGLPFAScreenMask, 0,
        
        // Don't fall back to the software renderer
        NSOpenGLPFANoRecovery,

        // pixel format available to all renderers
        NSOpenGLPFAAllRenderers,
        
        // Front and Back Buffer
        NSOpenGLPFADoubleBuffer,
        
        // Only hardware-accelerated renderers are considered.
        NSOpenGLPFAAccelerated,
        
        // Bit sizes
        NSOpenGLPFAColorSize,  32,
        NSOpenGLPFADepthSize,  24,
        NSOpenGLPFAAlphaSize,   8,
        NSOpenGLPFAStencilSize, 8,
        
        // Use color, depth and accumulation sizes of sizes equal to or greater
        NSOpenGLPFAClosestPolicy,
        
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
        if(m_GLContext != nil) {
            [self prepareOpenGL];
            

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
    [m_GLContext setView:self];
    [self setNeedsDisplay:YES];
    
    NSRect pixelBounds = [self convertRectToBacking:[self bounds]];
    [m_GLContext makeCurrentContext];
    glViewport(0, 0,
              (GLint)NSWidth(pixelBounds),
              (GLint)NSHeight(pixelBounds));
    
    // Set-up for including a backed-layer. Should dive into this more
    //    deeply later.
    //CALayer* newBackedLayer = [[CALayer alloc]init];
    //[self setWantsLayer:YES];
    //[self setLayer:newBackedLayer];
    
    if (false) {
        m_OffScreenTextures = initGL(m_FrameBufferIds, m_RenderBuffers, 1, NSWidth(pixelBounds), NSHeight(pixelBounds));
        
        GLenum ret = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (ret != GL_NO_ERROR) {
            if( ret != GL_FRAMEBUFFER_COMPLETE) {
                NSLog(@"Something bad happened");
            }
        }
    }

    //glEnable();
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    // call some code to set project back to initial state
}

// Call the update method of the NSOpenGLContext class
- (void)update {
    NSLog(@"update");

    if(m_GLContext) {
        [m_GLContext update];
    }
    
    [self display];
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
    if(m_GLContext) {
        [m_GLContext makeCurrentContext];
        
        //glClearColor(0,0,0,0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // Drawing code here.
        glColor3f(1.0f, 0.85f, 0.35f);
        glBegin(GL_TRIANGLES);
        {
            glVertex3f(  0.0,  0.6, 0.0);
            glVertex3f( -0.2, -0.3, 0.0);
            glVertex3f(  0.2, -0.3 ,0.0);
        }
        glEnd();
        
        [m_GLContext flushBuffer];
    }
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
    glDeleteFramebuffersEXT(1, m_FrameBufferIds);
}
@end

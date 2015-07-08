//
//  View.m
//  CS562
//
//  Created by Felipe Robledo on 7/5/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "View.h"
#include <OpenGL/gl.h>
#include <OpenGL/gltypes.h>

@implementation View
{
    GLuint m_FrameBufferIds[1];
    GLuint m_OffScreenTextures[1];
}

// Use this method to allocate and initialize the NSOpenGLPixelFormat object
+ (NSOpenGLPixelFormat*)defaultPixelFormat {
    NSOpenGLPixelFormatAttribute attributes [] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,         // If present, this attribute indicates that only hardware-accelerated renderers are considered.
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAStencilSize, 8,
        NSOpenGLPFAMultisample, // I think this is antialiasing
        (NSOpenGLPixelFormatAttribute)nil
    };
    
    NSOpenGLPixelFormat* newDefaultFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    return newDefaultFormat;
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
            [m_GLContext setView:self];
            [self setNeedsDisplay:YES];
            [self prepareOpenGL];
            
            NSRect pixelBounds = [self convertRectToBacking:[self bounds]];
            // Set-up for including a backed-layer. Should dive into this more
            //    deeply later.
            //CALayer* newBackedLayer = [[CALayer alloc]init];
            //[self setWantsLayer:YES];
            //[self setLayer:newBackedLayer];
            
            if (false) {
                glGenFramebuffers(1, m_FrameBufferIds);
                glBindFramebuffer(GL_FRAMEBUFFER, m_FrameBufferIds[0]);
                
                glGenTextures(1, m_OffScreenTextures);
                glBindTexture(GL_TEXTURE_2D, m_OffScreenTextures[0]);
                
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, NSWidth(pixelBounds), NSHeight(pixelBounds), 0,
                             GL_RGBA, GL_UNSIGNED_BYTE, NULL);
                // Need to remember other texture initialization...
                
                glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE, m_OffScreenTextures[0], 4);
                
                GLenum ret = glCheckFramebufferStatus(GL_FRAMEBUFFER);
                if (ret != GL_NO_ERROR) {
                    if( ret != GL_FRAMEBUFFER_COMPLETE) {
                        NSLog(@"Something bad happened");
                    }
                }
            }
        }
    }
    return self;
}

- (void) _surfaceNeedsUpdate:(NSNotification*)notification {
    [self update];
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
    NSRect pixelBounds = [self convertRectToBacking:[self bounds]];
    [m_GLContext makeCurrentContext];
    glViewport(0, 0,
              (GLint)NSWidth(pixelBounds),
              (GLint)NSHeight(pixelBounds));

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
        
        [m_GLContext makeCurrentContext];
        
        //[super drawRect:dirtyRect];
        
        glClearColor(0,0,0,0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // Drawing code here.
        
        [m_GLContext flushBuffer];
    }
    
    //[self setNeedsDisplay:YES];
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

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if(m_GLContext) {
        [m_GLContext makeCurrentContext];
        
        //glClearColor(0,0,0,0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // Drawing code here.
        
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
    NSPoint localPoint = [self convertPoint:aPoint fromView:nil];
}

-(void) dealloc {
    glDeleteTextures(1, m_OffScreenTextures);
    glDeleteFramebuffersEXT(1, m_FrameBufferIds);
}
@end

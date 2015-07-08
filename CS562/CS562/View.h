//
//  View.h
//  CS562
//
//  Created by Felipe Robledo on 7/5/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface View : NSView
{
    @private
    NSOpenGLContext*      m_GLContext;
    NSOpenGLPixelFormat*  m_PixelFormat;
}

// Use this method to allocate and initialize the NSOpenGLPixelFormat object
+ (NSOpenGLPixelFormat*)defaultPixelFormat;

// Retains the pixel format and sets up the notification
//     NSViewGlobalFrameDidChangeNotification
- (id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat*)format;

// Used to set the OpenGL context we are going to use to draw
- (void)setOpenGLContext:(NSOpenGLContext*)context;

// Context gettor
- (NSOpenGLContext*)openGLContext;

// Use this method to clear and release the NSOpenGLContext object
- (void)clearGLContext;

// Use this method to initialize OpenGL state after creating NSOpenGLContext
- (void)prepareOpenGL;
- (void)prepareForReuse;

// Call the update method of the NSOpenGLContext class
- (void)update;

// In-case you need to switch your pixel format
- (void)setPixelFormat:(NSOpenGLPixelFormat*)pixelFormat;

// Returns the currect pixel format
- (NSOpenGLPixelFormat*)pixelFormat;

// Ensure that the view is locked prior to drawing and that the context is the
//     context is the current one.
- (void)lockFocus;

- (void)drawRect:(NSRect)dirtyRect;

-(void)viewDidMoveToWindow;

- (void) updateConstraints;

-(void) rightMouseDown:(NSEvent *)theEvent;

@end

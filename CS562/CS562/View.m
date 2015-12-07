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

#import <Image.h>
#import <View.h>
#import <ShaderManager.h>
#import <Shader.h>
#import <Model3D.h>
#import <Transform.h>
#import <Material.h>
#import <MeshStore.h>
#import <Mesh.h>
#import <ShadowCastingLight.h>
#import <PerspectiveView.h>
#import <GBuffer.h>
#import <PointLight.h>
#import <DirectionalLight.h>
#import <SpotLight.h>
#import <CS562Core/CS562Core.h>
#include <initGL.h>
#include <OpenGL/gl3.h>
#include <OpenGL/gltypes.h>
#include <GLKit/GLKit.h>
#include <MacroCommons.h>
#include <OpenGLErrorHandling.h>

GLfloat quatPoints[] = {
    -1.0f,  1.0f, 0.0f, //0 - upper left
    -1.0f, -1.0f, 0.0f, //1 - lower left
     1.0f, -1.0f, 0.0f, //2 - lower right
     1.0f,  1.0f, 0.0f  //3 - upper right
};

GLshort quadFaces[] = {
    0,1,2,
    2,3,0
};

// Privates
@interface View(PrivateMethods)

-(void) loadHDRImages;
-(void) createShaderPrograms;
-(void) drawSkyDome:(NSDictionary*)data;
-(void) geometryPass:(NSDictionary*)data;
-(void) shadowPass:(NSDictionary*)data;
-(void) IBL:(NSDictionary*)data;
-(void) lightPass:(NSDictionary*)data;
-(void) compositePass:(NSDictionary*)data;

-(void) generateShadowMapFor:(Entity*)light withData:(NSDictionary*)data shadowMapShader:(Shader*)shadowMapShader;

-(void) getView:(GLKMatrix4*)v perspective:(GLKMatrix4*)p fromData:(NSDictionary*)data;

-(void) submitPointLight:(Entity*)entity uniformsFromShader:(Shader*)shader;
-(void) submitSpotLight:(Entity*)entity uniformsFromShader:(Shader*)shader;
-(void) submitDirectionalLight:(Entity*)entity uniformsFromShader:(Shader*)shader;

@end

@implementation View
{
    GLKVector3 gBufferBackgroundColor, sceneBackgroundColor;
    GLfloat iblExposure, iblContrast;
    GLint  originalFrameBuffer;
    ShaderManager* shaderManager;
    GBuffer* gBuffer;
    GLKTextureInfo* skydomeImage, *irradianceImage;
    NSMutableDictionary* selectionSubmitionDic;
    
    NSPoint prevCoords;
    BOOL slidingCamera;
    BOOL rotatingCamera;
    BOOL drawDebug;
    BOOL debugDepthTexture;
    
    // FIXME: Remove
    GLuint vbo;
    GLuint indices;
    GLuint vao;
    GLuint shader_programme;
    GLuint textureID;
    GLuint irradianceID;
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
        
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        
        // Bit sizes
        NSOpenGLPFAColorSize,  16,
        NSOpenGLPFADepthSize,  16,
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
        drawDebug = false;
        slidingCamera = false;
        rotatingCamera = false;
        debugDepthTexture = false;
        
        iblContrast = iblExposure = 1.0f;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(_surfaceNeedsUpdate:)
                                              name:NSViewGlobalFrameDidChangeNotification
                                              object:self];
        
        
        m_GLContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
        if( m_GLContext != nil) {
            gBufferBackgroundColor = GLKVector3Make(0.55f,0.55f,0.55f);
            sceneBackgroundColor = GLKVector3Make(0.55f,0.55f,0.55f);
            
            [self setWantsLayer:YES];
            [m_GLContext setView:self];
            [m_GLContext makeCurrentContext];
            
            NSLog(@"OpenGL version = %s", glGetString(GL_VERSION));
            NSLog(@"GLSL version = %s", glGetString(GL_SHADING_LANGUAGE_VERSION));
            
            NSRect pixelBounds = [self convertRectToBacking:[self bounds]];
            glViewport(0, 0,
                       (GLint)NSWidth(pixelBounds),
                       (GLint)NSHeight(pixelBounds));
            gBuffer = [[GBuffer alloc]initWithBounds:pixelBounds];
            NSAssert(gBuffer != nil,@"ERROR: GBuffer could not be created.");
            
            [self createShaderPrograms];
            m_HasGeneratedFocus = NO;
            
            // Store original framebuffer object
            glGetIntegerv(GL_FRAMEBUFFER_BINDING, &originalFrameBuffer);
            
            
            {//==============================================================
                // FIXME: Remove
                // Remember: VAOs allow us to matain a state of vbo's. This way, we
                //           only have to trigger the vao to use all vbo's attached
                //           to it.
                glGenVertexArrays (1, &vao);
                glBindVertexArray (vao);
                
                // FIXME: Remove
                glGenBuffers (1, &vbo);
                glBindBuffer (GL_ARRAY_BUFFER, vbo);
                glBufferData (GL_ARRAY_BUFFER,
                              12 * sizeof (GLfloat),
                              quatPoints,
                              GL_STATIC_DRAW);
                glVertexAttribPointer (GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
                glEnableVertexAttribArray (GLKVertexAttribPosition);

                
                glGenBuffers(1, &indices);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indices);
                glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                             6 * sizeof(GLshort),
                             quadFaces,
                             GL_STATIC_DRAW);
                
                glBindVertexArray(0);
                
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
                if(!linked) {
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
                } else {
                    NSLog(@"Shader linked successfully");
                }
            }//==============================================================
            
            //Image* metal_roof_diffuse = [Image Load:@"metal_roof_diff_512x512"];
            //textureID = 0;
            //glGenTextures(1, &textureID);
            //[metal_roof_diffuse setTextureID:textureID];
            
            glFrontFace(GL_CCW);
            CheckOpenGLError();
            
            // TODO: uncomment this
            [self loadHDRImages];
            
            selectionSubmitionDic = [[NSMutableDictionary alloc] init];
            [selectionSubmitionDic setObject:@"submitPointLight:uniformsFromShader:" forKey:@"PointLight"];
            [selectionSubmitionDic setObject:@"submitSpotLight:uniformsFromShader:" forKey:@"SpotLight"];
            [selectionSubmitionDic setObject:@"submitDirectionalLight:uniformsFromShader:" forKey:@"DirectionalLight"];
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

-(void) draw:(NSDictionary*)dataToDraw {
    if(m_GLContext) {
        [m_GLContext makeCurrentContext];
        
        // wipe the drawing surface clear
        
        // draw points 0-3 from the currently bound VAO with current in-use shader
        BOOL simpleDraw = NO;
        if(simpleDraw) {
            
            glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glUseProgram (shader_programme);
            glBindVertexArray (vao);
            CheckOpenGLError();
            glEnableVertexAttribArray (GLKVertexAttribPosition);
            CheckOpenGLError();
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT,0);
            CheckOpenGLError();
            glDisableVertexAttribArray(GLKVertexAttribPosition);
            CheckOpenGLError();
            
        } else {
            
            [self drawSkyDome:dataToDraw];
            [self geometryPass:dataToDraw];
            [self shadowPass:dataToDraw];
            [self IBL:dataToDraw];
            //[self lightPass:dataToDraw];
            
        }
        
        if(!drawDebug) {
            [m_GLContext flushBuffer];
        } else {
            // debug information will be shown over the image created by the
            // last pass.
            [gBuffer showWithWidth:[self bounds].size.width * 2 andHeight:[self bounds].size.height * 2];
            [m_GLContext flushBuffer];
            CheckOpenGLError();
        }
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

- (BOOL) acceptsFirstResponder {
    return YES;
}

- (void) keyDown:(NSEvent *)theEvent {
    // Arrow keys are associated with the numeric keypad
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) {
        NSString *arrowKey = [theEvent charactersIgnoringModifiers];
        unichar keyChar = 0;
        
        if ( [arrowKey length] == 1 ) {
            
            keyChar = [arrowKey characterAtIndex:0];
            
            if ( keyChar == NSLeftArrowFunctionKey ) {
                //
                [self emmit:@"moveLeft" withData:nil];
                [[self window] invalidateCursorRectsForView:self];
                return;
            }
            if ( keyChar == NSRightArrowFunctionKey ) {
                //
                [self emmit:@"moveRight" withData:nil];
                [[self window] invalidateCursorRectsForView:self];
                return;
            }
            if ( keyChar == NSUpArrowFunctionKey ) {
                //
                [self emmit:@"moveUp" withData:nil];
                [[self window] invalidateCursorRectsForView:self];
                return;
            }
            if ( keyChar == NSDownArrowFunctionKey ) {
                //
                [self emmit:@"moveDown" withData:nil];
                [[self window] invalidateCursorRectsForView:self];
                return;
            }
            
            [super keyDown:theEvent];
        }
        //[self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    } else {
        NSString* temp = [theEvent characters];
        //NSLog(@"KeyCode: %hu", [theEvent keyCode]);
        //NSLog(@"Characters: %@", [theEvent characters]);
        
        if([temp isEqualToString:@"w"]) {
            [self emmit:@"lookUp" withData:nil];
        }
        if([temp isEqualToString:@"s"]) {
            [self emmit:@"lookDown" withData:nil];
        }
        if([temp isEqualToString:@"d"]) {
            [self emmit:@"moveRight" withData:nil];
        }
        if([temp isEqualToString:@"a"]) {
            [self emmit:@"moveLeft" withData:nil];
        }
        
        // Check for space bar
        if ([temp isEqualToString:@"l"]) {
            [self emmit:@"lightMove" withData:nil];
        }
    }
    

}

- (void) keyUp:(NSEvent *)theEvent {
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setObject:theEvent forKey:@"Event"];
    [self emmit:@"keyboardUp" withData:data];
}

-(void) rightMouseDown:(NSEvent *)theEvent {
    NSPoint aPoint = [theEvent locationInWindow];
    NSPoint localPoint = [self convertPoint:aPoint fromView:nil];
    
    if(!slidingCamera) {
        slidingCamera = true;
        prevCoords = aPoint;
    }
}

- (void) rightMouseDragged:(NSEvent *)theEvent {
    if(slidingCamera) {
        NSPoint currLoc = [theEvent locationInWindow];
        
        int dy = currLoc.y - prevCoords.y;
        if (dy > 0) {
            [self emmit:@"moveForward" withData:nil];
        } else if(dy < 0) {
            [self emmit:@"moveBack" withData:nil];
        }
        
        prevCoords = currLoc;
    }
}

- (void) rightMouseUp:(NSEvent *)theEvent {
    if(slidingCamera) {
        slidingCamera = false;
    }
}

- (void) mouseDown:(NSEvent *)theEvent {
    if( ([theEvent modifierFlags] == NSLeftMouseDown) &&
        ([theEvent modifierFlags] == NSRightMouseDown) ) {
        return;
    }
    
    NSPoint localPoint = [theEvent locationInWindow];
    //NSPoint localPoint = [self convertPoint:aPoint fromView:nil];
    
    if([theEvent type] == NSLeftMouseDown) {
        rotatingCamera = YES;
        prevCoords = localPoint;
    }
    
}

- (void) mouseDragged:(NSEvent *)theEvent {
    if( ([theEvent modifierFlags] == NSLeftMouseDragged) &&
        ([theEvent modifierFlags] == NSRightMouseDragged) ) {
        return;
    }
    
    NSPoint localPoint = [theEvent locationInWindow];
    //NSPoint localPoint = [self convertPoint:aPoint fromView:nil];
    
    if([theEvent type] == NSLeftMouseDragged) {
        int dx = localPoint.x - prevCoords.x;
        if (dx > 0) {
            [self emmit:@"turnRight" withData:nil];
        } else if(dx < 0) {
            [self emmit:@"turnLeft" withData:nil];
        }
    }
    
    prevCoords = localPoint;
}

- (void) mouseUp:(NSEvent *)theEvent {
    if(rotatingCamera && [theEvent type] == NSLeftMouseUp) {
        rotatingCamera = NO;
    } 
}

-(void) dealloc {
}

// PRIVATES --------------------------------------------------------------------
-(void) loadHDRImages {
    // Acquire a list from the bundle that contains all of the hdr images
    NSBundle* bundle = [NSBundle mainBundle];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryAndFileNames = [fm contentsOfDirectoryAtPath:[bundle resourcePath] error:&error];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.hdr'"],
                *fltrIrr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.irrhdr'"];
    NSArray *onlyHDR = [directoryAndFileNames filteredArrayUsingPredicate:fltr],
            *onlyIrrHDR = [directoryAndFileNames filteredArrayUsingPredicate:fltrIrr];
    
    //all *.irrhdr have the same filename.
    
    //Need to load this list of hdr images asynchroneously!!!!
    
    /* NOTE: First impressions told me HDR images were in sRGB, but they
     actually are in scRGB. There is an extensive article that
     goes over this. Point is, don't use the following line when
     loading *.hdr images.
     
     NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft:@YES, GLKTextureLoaderSRGB:@YES};
     */
    NSString *filePath = [bundle pathForResource:@"14-Hamarikyu_Bridge_B_3k" ofType:@"hdr"];
    NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft:@YES,
                              GLKTextureLoaderGenerateMipmaps:@YES};
    
    
    
    GLKTextureInfo* txtInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:&error];
    
    if(error) {
        for(NSString* key in [error userInfo]) {
            NSString* errorDescription = [[error userInfo] valueForKey:key];
            NSLog(@"ERROR: %s",[errorDescription UTF8String]);
        }
    } else {
        NSLog(@"Texture loaded, name: %d, WxH: %d x %d",
              txtInfo.name,
              txtInfo.width,
              txtInfo.height);
        
        glBindTexture(GL_TEXTURE_2D, [txtInfo name]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        CheckOpenGLError();
        
        skydomeImage = txtInfo;
    }
    
    
    
    filePath = [bundle pathForResource:@"14-Hamarikyu_Bridge_B_3k" ofType:@"irrhdr"];
    txtInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:&error];
    
    if(error) {
        for(NSString* key in [error userInfo]) {
            NSString* errorDescription = [[error userInfo] valueForKey:key];
            NSLog(@"ERROR: %s",[errorDescription UTF8String]);
        }
    } else {
        NSLog(@"Texture loaded, name: %d, WxH: %d x %d",
              txtInfo.name,
              txtInfo.width,
              txtInfo.height);
        
        glBindTexture(GL_TEXTURE_2D, [txtInfo name]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        CheckOpenGLError();
        
        irradianceImage = txtInfo;
    }
}

-(void) createShaderPrograms {
    const char* shaderProgramNames[] = {
        "geometry",
        "lighting_PointLight",
        "lighting_DirectionalLight",
        "lighting_DirectionalLight_shadowed",
        "lighting_SpotLight",
        "shadowMap",
        "skydome",
        "ibl",
        NULL
    };
    
    shaderManager = [[ShaderManager alloc] init];
    for(int i = 0; shaderProgramNames[i] != NULL; ++i) {
        NSString* temp = [[NSString alloc] initWithCString:shaderProgramNames[i] encoding:NSUTF8StringEncoding];
        
        Shader* shader = [shaderManager newProgramShaderWithVertex:temp Fragment:temp Named:temp];
        
        NSAssert(shader != nil,@"ERROR! Shader could not compile.");
        
        NSString* t = [[NSString alloc] initWithUTF8String:shaderProgramNames[i]];
    }
    
}

-(void) drawSkyDome:(NSDictionary*)data {
    const GLuint VERTEX_COUNT = 3;

    [gBuffer bindForWriting];
    
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    glDisable(GL_DEPTH_TEST);
    
    //glDisable(GL_CULL_FACE);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    CheckOpenGLError();
    
    // Required databases
    Shader*    skydomeShader   = [shaderManager getShader:@"skydome"];
    [skydomeShader use];
    MeshStore* meshStore       = [data valueForKey:@"meshStore"];
    
    // Get the skydome object
    NSNumber *cameraID  = [data valueForKey:@"eyeID"];
    NSNumber *skydomeID = [data valueForKey:@"skydomeID"];
    Entity   *skydome   = [EntityCreator getEntity:[skydomeID unsignedLongLongValue]];
    Entity   *camera    = [EntityCreator getEntity:[cameraID unsignedLongLongValue]];
    
    Transform *skydomeTransform = (Transform*)[skydome getModelWithName:@"Transform"],
              *cameraTransform  = (Transform*)[camera getModelWithName:@"Transform"];
    
    GLKMatrix4 world = [skydomeTransform transformation];
    GLKMatrix4 view, persp;
    [self getView:&view perspective:&persp fromData:data];
    GLKVector3 eye = [cameraTransform position];
    
    // Disregard any entities that are not renderable
    Model3D* model3d = (Model3D*)[skydome getModelWithName:@"Model3D"];
    NSAssert(model3d != nil,@"ERROR: Skydome entity has no 3D model");
    NSString* meshName = [model3d   meshSource];
    Mesh*     mesh     = [meshStore getMeshFromName:meshName];
    GLint     indices  = [mesh      faceCount] * VERTEX_COUNT;
    [mesh bindMesh];
    
    // Get uniforms and send the data
    GLint uTexture = [skydomeShader uniformFromDictionary:@"objectTexture"],
          uWVP     = [skydomeShader uniformFromDictionary:@"wvp"],
          uWorld   = [skydomeShader uniformFromDictionary:@"world"],
          uEye     = [skydomeShader uniformFromDictionary:@"eye"];
    CheckOpenGLError();

    glUniformMatrix4fv(uWVP, 1, GL_FALSE, GLKMatrix4Multiply(persp,GLKMatrix4Multiply(view, world)).m );
    glUniformMatrix4fv(uWorld, 1, GL_FALSE, world.m);
    glUniform3fv(uEye, 1, eye.v);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D,[skydomeImage name]);
    glUniform1i(uTexture,3);
    CheckOpenGLError();

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    //glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
    
    glDrawElements(GL_TRIANGLES, indices, GL_UNSIGNED_INT,NULL);

    //glDisableVertexAttribArray(GLKVertexAttribTexCoord1);
    //glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    CheckOpenGLError();
    
    [skydomeShader unuse];
}

-(void) geometryPass:(NSDictionary*)data {
    const GLuint VERTEX_COUNT = 3;
    
    Shader*    geometryShader  = [shaderManager getShader:@"geometry"];
    NSNumber*  cameraID        = [data valueForKey:@"eyeID"];
    MeshStore* meshStore       = [data valueForKey:@"meshStore"];
    NSArray*   worldObjectIDs  = [data valueForKey:@"gameObjectIDs"];
    Entity*    camera          = [EntityCreator getEntity:[cameraID unsignedLongLongValue]];
    
    GLKMatrix4 view, persp;
    [self getView:&view perspective:&persp fromData:data];
    
    [geometryShader use];
    
    [gBuffer bindForWriting];
    
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    CheckOpenGLError();

    GLint uWorld   = [geometryShader uniformFromDictionary:@"world"],
          uDiffuse = [geometryShader uniformFromDictionary:@"diffuse"],
          uWVP     = [geometryShader uniformFromDictionary:@"wvp"],
          uView    = [geometryShader uniformFromDictionary:@"view"];
    CheckOpenGLError();
    
    for(NSNumber* entityID in worldObjectIDs) {
        // Acquire the entity in question
        uint64 temp = [entityID unsignedLongLongValue];
        Entity* entity = [EntityCreator getEntity:temp];
        GLint indices = 0;
        
        // Disregard any entities that are not renderable
        Model3D* model3d = (Model3D*)[entity getModelWithName:@"Model3D"];
        if(model3d == nil) {
            continue;
        }
        
        // Bind mesh data
        NSString* meshName = [model3d   meshSource];
        Mesh*     mesh     = [meshStore getMeshFromName:meshName];
                  indices  = [mesh      faceCount] * VERTEX_COUNT;
        [mesh bindMesh];
        
        // Submit the diffuse color
        GLKVector4 diffuse; // assumes diffuse color is not a texture
        Material* material = (Material*)[entity getModelWithName:@"Material"];
        NSAssert(material != nil, @"ERROR: Entity with model does not have a material");
        diffuse = *[material diffuse];
        glUniform4fv(uDiffuse, 1, diffuse.v);
        CheckOpenGLError();
        
        // Submit transformation matrices
        Transform* entTransform = (Transform*)[entity getModelWithName:@"Transform"];
        
        GLKMatrix4 world = [entTransform transformation];
        glUniformMatrix4fv(uWorld, 1, GL_FALSE, world.m );
        glUniformMatrix4fv(uView , 1, GL_FALSE, view.m );
        glUniformMatrix4fv(uWVP  , 1, GL_FALSE, GLKMatrix4Multiply(persp,GLKMatrix4Multiply(view, world)).m );
        CheckOpenGLError();
    
        // Fire up shader
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
        
        glDrawElements(GL_TRIANGLES, indices, GL_UNSIGNED_INT,NULL);
        
        glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glDisableVertexAttribArray(GLKVertexAttribNormal);
        glDisableVertexAttribArray(GLKVertexAttribPosition);
        
        CheckOpenGLError();
    }
    
    // write the data from the texture to a random file
    [geometryShader unuse];
}

-(void) shadowPass:(NSDictionary*)data {
    return;
    // Setting blending on
    glDisable(GL_BLEND);
    
    // Set depth testing off
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glCullFace(GL_FRONT);
    
    NSDictionary* lightsInWorld = [data objectForKey:@"lights"];
    
    Shader *shadowMapShader = [shaderManager getShader:@"shadowMap"];
    
    [shadowMapShader use];
    // for each type of light
    for(NSString* lightType in lightsInWorld) {
        NSArray* lightEntityIDs = [lightsInWorld objectForKey:lightType];
        
        // go update the shadow map of every shadow casting light in the
        // current group of lights
        for(NSNumber* entityID in lightEntityIDs) {
            uint64 temp = [entityID unsignedLongLongValue];
            Entity* light = [EntityCreator getEntity:temp];

            ShadowCastingLight *shadowCasterView = (ShadowCastingLight*)[light getViewWithName:@"ShadowCastingLight"];
            
            if(shadowCasterView == nil) {
                continue;
            }
            
            [self generateShadowMapFor:light withData:data shadowMapShader:shadowMapShader];
        }
    }
    [shadowMapShader unuse];
    
    NSRect pixelBounds = [self convertRectToBacking:[self bounds]];
    glViewport(0, 0,
               (GLint)NSWidth(pixelBounds),
               (GLint)NSHeight(pixelBounds));
}

-(void) generateShadowMapFor:(Entity*)light withData:(NSDictionary*)data shadowMapShader:(Shader*)shadowMapShader {
    const GLuint VERTEX_COUNT = 3;
    BOOL debugTexture = NO;
    
    NSArray*   worldObjectIDs  = [data valueForKey:@"gameObjectIDs"];
    MeshStore* meshStore       = [data valueForKey:@"meshStore"];
    
    // Get this shadow casting light ready for writing
    ShadowCastingLight *shadowCasterView = (ShadowCastingLight*)[light getViewWithName:@"ShadowCastingLight"];
    CGSize size = [shadowCasterView getSize];
    [shadowCasterView bindForWriting];
    
    if(debugTexture) {
        glBindFramebuffer(GL_FRAMEBUFFER, originalFrameBuffer);
    } else {
        glViewport(0, 0, size.width, size.height);
    }

    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    GLKMatrix4 lightTrans = [shadowCasterView getEyeTransformation];
    GLKMatrix4 lightPersp = [shadowCasterView getPerspective];
    
    // TODO: some of this logic changes for point lights since the shadow mapping
    //       for them is done from 2 views , 2 hemispheres. For simplicity I will
    //       perform directional light first, then spot light.
    
    for(NSNumber* entityID in worldObjectIDs) {
        uint64 temp = [entityID unsignedLongLongValue];
        Entity* worldObj = [EntityCreator getEntity:temp];
        
        // Check that this entity is not a light even if it has a model
        PointLight       *pLight = (PointLight*)[worldObj getModelWithName:@"PointLight"];
        DirectionalLight *dLight = (DirectionalLight*)[worldObj getModelWithName:@"DirectionalLight"];
        SpotLight        *sLight = (SpotLight*)[worldObj getModelWithName:@"SpotLight"];
        
        if(pLight != nil || dLight != nil || sLight != nil) {
            continue;
        }
        
        // Get current entity model
        // Disregard any entities that do not have one.
        Model3D* model3d = (Model3D*)[worldObj getModelWithName:@"Model3D"];
        if(model3d == nil) {
            continue;
        }
        
        // Bind mesh data
        NSString* meshName = [model3d   meshSource];
        Mesh*     mesh     = [meshStore getMeshFromName:meshName];
        GLint indices  = [mesh faceCount] * VERTEX_COUNT;
        [mesh bindMesh];
        CheckOpenGLError();
        
        Transform* entTransform = (Transform*)[worldObj getModelWithName:@"Transform"];
        
        GLKMatrix4 world = [entTransform transformation];
        
        // MWLP (Model-World-Light-Perspective)
        GLKMatrix4 MWLP = GLKMatrix4Multiply(lightPersp, GLKMatrix4Multiply(lightTrans, world));
        
        GLint uMWLP = [shadowMapShader uniformFromDictionary:@"MWLP"];
        glUniformMatrix4fv(uMWLP, 1, GL_FALSE, MWLP.m );
        CheckOpenGLError();

        [shadowCasterView sendUniformForWritingShadowMap:shadowMapShader];
        CheckOpenGLError();
        
        // Fire up shadow shader
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        
        glDrawElements(GL_TRIANGLES, indices, GL_UNSIGNED_INT,NULL);
        CheckOpenGLError();
        
        glDisableVertexAttribArray(GLKVertexAttribPosition);
    }
    
    if( false ) {
        // This shows that my shadow buffer IS being written to,
        // and I am copying the contents of it to the framebuffer
        // where the final result goes
        [shadowCasterView bindForReading];
        glReadBuffer(GL_COLOR_ATTACHMENT0);
        glBlitFramebuffer(0, 0, size.width, size.height,
                          0, 0, 1600, 1600,
                          GL_COLOR_BUFFER_BIT, GL_LINEAR);
        CheckOpenGLError();
    }
}

-(void) IBL:(NSDictionary*)data {
    Shader*    iblShader  = [shaderManager getShader:@"ibl"];
    [iblShader use];
    
    MeshStore* meshStore       = [data valueForKey:@"meshStore"];
    NSArray*   worldObjectIDs  = [data valueForKey:@"gameObjectIDs"];
    
    NSNumber*  cameraID  = [data valueForKey:@"eyeID"];
    Entity*    camera    = [EntityCreator getEntity:[cameraID unsignedLongLongValue]];
    Transform* transform = (Transform*)[camera getModelWithName:@"Transform"];
    GLKVector3 eye       = [transform position];
    
    NSRect  screenBounds = [self bounds];
    GLfloat screenWidth  = screenBounds.size.width * 2,
    screenHeight = screenBounds.size.height * 2;
    
    //TODO: Add a GBuffer render target for specular vec and roughness
    GLfloat roughness = 5000;
    GLKVector3 Ks = GLKVector3Make(0.8f,0.8f,0.8f);
    
    glBindFramebuffer(GL_FRAMEBUFFER, originalFrameBuffer);
    glClearColor(0.2f,0.2f,0.2f,1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    CheckOpenGLError();
    
    [gBuffer bindForReading];
    GLuint positionTextureHandle = [gBuffer getTextureHandleFor:GBUFFER_TEXTURE_TYPE_POSITION],
    diffuseTextureHandle  = [gBuffer getTextureHandleFor:GBUFFER_TEXTURE_TYPE_DIFFUSE],
    normalTextureHandle   = [gBuffer getTextureHandleFor:GBUFFER_TEXTURE_TYPE_NORMAL];
    
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    CheckOpenGLError();
    
    GLint uPosBuffer  = [iblShader uniformFromDictionary:@"positionBuffer"],
    uDiffBuffer = [iblShader uniformFromDictionary:@"diffuseBuffer"],
    uNorBuffer  = [iblShader uniformFromDictionary:@"normalBuffer"],
    uEnvBuffer  = [iblShader uniformFromDictionary:@"environmentBuffer"],
    uIrrBuffer  = [iblShader uniformFromDictionary:@"irradianceBuffer"],
    uEye        = [iblShader uniformFromDictionary:@"eye"],
    uRoughness  = [iblShader uniformFromDictionary:@"roughness"],
    uWinSize    = [iblShader uniformFromDictionary:@"windowSize"],
    uContrast   = [iblShader uniformFromDictionary:@"contrast"],
    uExposure   = [iblShader uniformFromDictionary:@"exposure"],
    uKs         = [iblShader uniformFromDictionary:@"Ks"];
    CheckOpenGLError();
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,positionTextureHandle);
    glUniform1i(uPosBuffer,0);
    CheckOpenGLError();
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D,normalTextureHandle);
    glUniform1i(uNorBuffer,1);
    CheckOpenGLError();
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D,diffuseTextureHandle);
    glUniform1i(uDiffBuffer,2);
    CheckOpenGLError();
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [skydomeImage name] );
    glUniform1i(uEnvBuffer,3);
    CheckOpenGLError();
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [irradianceImage name]);
    glUniform1i(uIrrBuffer,4);
    CheckOpenGLError();
    
    glUniform1f(uRoughness, roughness);
    glUniform1f(uContrast,  iblContrast);
    glUniform1f(uExposure,  iblExposure);
    glUniform3fv(uKs, 1, Ks.v);
    glUniform3fv(uEye, 1, eye.v);
    glUniform2f(uWinSize, screenWidth, screenHeight);
    CheckOpenGLError();
    
    // We will render everything to a quad
    glBindVertexArray (vao);
    CheckOpenGLError();
    
    glEnableVertexAttribArray (GLKVertexAttribPosition);
    CheckOpenGLError();
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT,0);
    CheckOpenGLError();
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    CheckOpenGLError();
    
    glBindVertexArray(0);
    CheckOpenGLError();
    
    [iblShader unuse];
}

-(void) lightPass:(NSDictionary*)data {
    //return;
    NSDictionary* lightsInWorld = [data objectForKey:@"lights"];
    
    // Create view and perspective matrices
    GLKMatrix4 view, persp, viewInverse;
    [self getView:&view perspective:&persp fromData:data];
    bool isInvertible = true;
    viewInverse = GLKMatrix4Invert(view, &isInvertible);
    
    NSNumber *cameraID = [data valueForKey:@"eyeID"];
    Entity *camera = [EntityCreator getEntity:[cameraID unsignedLongLongValue]];
    Transform* transform = [camera getModelWithName:@"Transform"];
    GLKVector3 eye = [transform position];
    
    glBindFramebuffer(GL_FRAMEBUFFER, originalFrameBuffer);
    glClearColor(0.2f,0.2f,0.2f,1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    CheckOpenGLError();
    
    // Setting blending on
    glEnable(GL_BLEND);
    glBlendEquation(GL_FUNC_ADD);
   	glBlendFunc(GL_ONE, GL_ONE);
    
    // Set depth testing off
    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
    
    glCullFace(GL_BACK);
    
    NSRect  screenBounds = [self bounds];
    GLfloat screenWidth = screenBounds.size.width * 2,
            screenHeight = screenBounds.size.height * 2;
    
    //TODO: Add a GBuffer render target for specular vec and roughness
    GLfloat roughness = 50;
    GLKVector3 Ks = GLKVector3Make(0.08f,0.08f,0.08f);
    
    [gBuffer bindForReading];
    GLuint positionTextureHandle = [gBuffer getTextureHandleFor:GBUFFER_TEXTURE_TYPE_POSITION],
           diffuseTextureHandle  = [gBuffer getTextureHandleFor:GBUFFER_TEXTURE_TYPE_DIFFUSE],
           normalTextureHandle   = [gBuffer getTextureHandleFor:GBUFFER_TEXTURE_TYPE_NORMAL],
           depthTextureHandle    = [gBuffer getDepthTextureHandle];
    
    // I need to loop through every type of different light
    // for every type of light
    //     get shader to render this light
    //     for every instance of this light type
    //          pass uniform data
    //          render
    BOOL useShadowCast = false;
    CheckOpenGLError();
    for(NSString* lightType in lightsInWorld) {
        NSArray* lightEntityIDs = [lightsInWorld objectForKey:lightType];
        
        // Get shader for this light
        NSMutableString* shaderName = [[NSMutableString alloc] initWithUTF8String:"lighting_"];
        [shaderName appendString:lightType];
        
        for(NSNumber* entityID in lightEntityIDs) {
            uint64 temp = [entityID unsignedLongLongValue];
            Entity* entity = [EntityCreator getEntity:temp];
            
            // If this is a shadow casting light, prepare the opengl resources
            ShadowCastingLight *shadowCasterView = (ShadowCastingLight*)[entity getViewWithName:@"ShadowCastingLight"];
            if(shadowCasterView != nil && useShadowCast) {
                [shaderName appendString:@"_shadowed"];
                [shadowCasterView bindForReading];
            }
            
            Shader* lightShader = [shaderManager getShader:shaderName];
            NSAssert(lightShader != nil, @"ERROR: lighting shader not found");
            
            // Get the selector for this light type
            NSString* selectorName = [selectionSubmitionDic objectForKey:lightType];
            SEL selector = NSSelectorFromString(selectorName);
            IMP imp = [self methodForSelector:selector];
            void (*submitLightUniforms)(id,SEL,Entity*,Shader*) = (void*)imp;
            
            [lightShader use];
            
            // These uniforms wil always be the same
            GLint posBufferUniform    = [lightShader getUniform:@"positionBuffer"],
            normalBufferUniform = [lightShader getUniform:@"normalBuffer"],
            diffBufferUniform   = [lightShader getUniform:@"diffuseBuffer"],
            depthBufferUniform  = [lightShader getUniform:@"depthBuffer"],
            viewUniform         = [lightShader getUniform:@"view"],
            eyeUniform          = [lightShader getUniform:@"eye"],
            KsUniform           = [lightShader getUniform:@"Ks"],
            roughnessUniform    = [lightShader getUniform:@"roughness"],
            windowSizeUniform   = [lightShader getUniform:@"windowSize"];
            
            submitLightUniforms(self,selector,entity, lightShader);
            
            // We are not sending texture IDs but rather texture units
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D,positionTextureHandle);
            glUniform1i(posBufferUniform,0);
            CheckOpenGLError();
            
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D,normalTextureHandle);
            glUniform1i(normalBufferUniform,1);
            CheckOpenGLError();
            
            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D,diffuseTextureHandle);
            glUniform1i(diffBufferUniform,2);
            CheckOpenGLError();
            
            glActiveTexture(GL_TEXTURE3);
            glBindTexture(GL_TEXTURE_2D, depthTextureHandle);
            glUniform1i(depthBufferUniform,3);
            CheckOpenGLError();
            
            // Texture binding is not working...why???
            if(shadowCasterView != nil && useShadowCast) {
                // Theres something going on with binding these mf texture!
                
                GLKMatrix4 lightTrans = [shadowCasterView getEyeTransformation];
                GLKMatrix4 lightPersp = [shadowCasterView getPerspective];
                GLKMatrix4 LP = GLKMatrix4Multiply(lightPersp, lightTrans);
                
                GLint uDepthBuffer = [lightShader getUniform:@"depthBuffer"],
                      uLP          = [lightShader getUniform:@"LP"];
                
                GLuint depthTextureHandle = [shadowCasterView getTargetHandle];
                
                glActiveTexture(GL_TEXTURE4);
                glBindTexture(GL_TEXTURE_2D,depthTextureHandle);
                glUniform1i(uDepthBuffer,4);
                
                glUniformMatrix4fv(uLP, 1, GL_FALSE, LP.m);
                CheckOpenGLError();
            }
            
            glUniform1f(roughnessUniform, roughness);
            glUniform3fv(KsUniform, 1, Ks.v);
            glUniform3fv(eyeUniform, 1, eye.v);
            glUniform2f(windowSizeUniform, screenWidth, screenHeight);
            glUniformMatrix4fv(viewUniform, 1, GL_FALSE, view.m );
            CheckOpenGLError();
            
            // We will render everything to a quad
            glBindVertexArray (vao);
            CheckOpenGLError();
            
            glEnableVertexAttribArray (GLKVertexAttribPosition);
            CheckOpenGLError();
            
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT,0);
            CheckOpenGLError();
            
            glDisableVertexAttribArray(GLKVertexAttribPosition);
            CheckOpenGLError();
            
            glBindVertexArray(0);
            CheckOpenGLError();
            
            [lightShader unuse];
        }
    }
}

// Brings all of the outputs from the previous passes together
-(void) compositePass:(NSDictionary*)data {
    NSArray*   worldObjectIDs  = [data valueForKey:@"gameObjectIDs"];
    
    NSNumber *cameraID = [data valueForKey:@"eyeID"];
    Entity *camera = [EntityCreator getEntity:[cameraID unsignedLongLongValue]];
    Transform* transform = [camera getModelWithName:@"Transform"];
    GLKVector3 eye = [transform position];
    
    for(NSNumber* entityID in worldObjectIDs) {
        uint64 temp = [entityID unsignedLongLongValue];
        Entity* entity = [EntityCreator getEntity:temp];
    
    }
}

-(void) getView:(GLKMatrix4*)v perspective:(GLKMatrix4*)p fromData:(NSDictionary*)data {
    // Create view and perspective matrices
    NSNumber* cameraID = [data valueForKey:@"eyeID"];
    Entity* camera = [EntityCreator getEntity:[cameraID unsignedLongLongValue]];
    
    Transform* camTransform = (Transform*)[camera getModelWithName:@"Transform"];
    PerspectiveView* perspective = (PerspectiveView*)[camera getModelWithName:@"PerspectiveView"];
    
    // I need these 2 pieces of information to draw
    NSRect bounds = [self bounds];
    *v  = [camTransform transformation];
    *p  = [perspective makeTransformWithWidth:bounds.size.width andHeight:bounds.size.height];
    
    bool isInvertible = true;
    *v = GLKMatrix4Invert(*v, &isInvertible);
    if(!isInvertible) { NSLog(@"Problem with camera matrix"); }
}

-(void) submitPointLight:(Entity*)entity uniformsFromShader:(Shader*)shader {
    // So this setup is working now. TIME TO MAKE ROASTED TOMATOES!!!
    
    PointLight* pLight = [entity getModelWithName:@"PointLight"];
    Transform * plTransform = [entity getModelWithName:@"Transform"];
    
    GLuint uColor = [shader getUniform:@"light.color"],
            uPos   = [shader getUniform:@"light.position"],
            uRange = [shader getUniform:@"light.range"],
            uAtte  = [shader getUniform:@"light.attenuation"];
    
    GLfloat range = [[pLight range] floatValue],
            atte  = [[pLight attenuation] floatValue];
    
    GLKVector3 pos = [plTransform position];
    GLKVector4 color = *[pLight color];
    
    glUniform1f(uRange, range);
    glUniform1f(uAtte, atte);
    glUniform3fv(uPos, 1, pos.v);
    glUniform4fv(uColor, 1, color.v);
    
}

-(void) submitSpotLight:(Entity*)entity uniformsFromShader:(Shader*)shader {

}

-(void) submitDirectionalLight:(Entity*)entity uniformsFromShader:(Shader*)shader {
    DirectionalLight *dLight = (DirectionalLight*)[entity getModelWithName:@"DirectionalLight"];
    Transform  *plTransform  = (Transform*)[entity getModelWithName:@"Transform"];
    
    GLuint uColor = [shader getUniform:@"light.color"],
           uDir   = [shader getUniform:@"light.direction"],
           uPos   = [shader getUniform:@"light.position"];
    
    GLKVector4 color = *[dLight color];
    GLKVector3 dir   = *[dLight direction];
    GLKVector3 pos   = [plTransform position];
    
    glUniform3fv(uPos, 1, pos.v);
    glUniform3fv(uDir, 1, dir.v);
    glUniform4fv(uColor, 1, color.v);
}

@end

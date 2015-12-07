//
//  RenderTarget.h
//  CS562
//
//  Created by Felipe Robledo on 9/30/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gltypes.h>

#define DEFINE_RENDER_TARGET(x) x ,
enum RenderTargets {
    #include <RenderTargetDefs.h>
    TOTAL
};
#undef DEFINE_RENDER_TARGET
typedef enum RenderTargets RenderTargets;

#define DEFINE_RENDER_TARGET(x) #x ,
static const char* RenderTagetsStatic[] = {
    #include <RenderTargetDefs.h>
    NULL
};
#undef DEFINE_RENDER_TARGET

@interface RenderTarget : NSObject

-(id)initWithTargetType:(RenderTargets)type andBounds:(NSRect)bounds;
-(void) bindFor:(GLenum)fboType;
-(GLuint) renderTexture;
-(void) dealloc;

@end

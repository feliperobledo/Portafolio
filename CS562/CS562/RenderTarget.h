//
//  RenderTarget.h
//  CS562
//
//  Created by Felipe Robledo on 9/30/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>


#define DEFINE_RENDER_TARGET(x) x ,
enum RenderTargets {
    #include <RenderTargetDefs.h>
    TOTAL
};
#undef DEFINE_RENDER_TARGET

#define DEFINE_RENDER_TARGET(x) #x ,
static const char* RenderTagetsStatic[] = {
    #include <RenderTargetDefs.h>
    NULL
};
#undef DEFINE_RENDER_TARGET

@interface RenderTarget : NSObject

-(id)init;
-(void) start;
-(void) stop;

@end

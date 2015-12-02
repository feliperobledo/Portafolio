//
//  PerspectiveView.m
//  CS562
//
//  Created by Felipe Robledo on 9/30/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "PerspectiveView.h"
#import <GLKit/GLKMath.h>

@implementation PerspectiveView

START_SPECIAL_SETTORS(PerspectiveView)


END_SPECIAL_SETTORS

-(id) init {
    if ((self = [super init])) {
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if ((self = [super initWithOwner:owner])) {
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser {
    if ((self = [super initWithOwner:owner usingSerializer:ser])) {
        
    }
    return self;
}

-(id) initWithDictionary:(NSDictionary*)dict {
    if ((self = [super initWithDictionary:dict])) {
        
    }
    return self;
}

-(void) serializeWith:(NSObject*)ser {
    
}

-(void) postInit {
    
}

-(GLKMatrix4) makeTransformWithWidth:(GLfloat)width andHeight:(GLfloat)height {
    GLfloat near = [[self near] floatValue],
            far  = [[self far]  floatValue],
            fov  = fabsf(GLKMathDegreesToRadians([[self fov] floatValue]));
    
    return GLKMatrix4MakePerspective(fov, fabsf(width/height), near, far);
}

@end

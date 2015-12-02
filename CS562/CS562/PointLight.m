//
//  PointLight.m
//  CS562
//
//  Created by Felipe Robledo on 9/28/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "PointLight.h"
#import <CDataInitializer.h>

@implementation PointLight

START_SPECIAL_SETTORS(PointLight)

    ADD_SPECIAL_SETTER(@"color", @"specialSetterColor:");

END_SPECIAL_SETTORS

-(id) init {
    if ((self = [super init])) {
        _color = (GLKVector4*)malloc(sizeof(GLKVector4));
        memset(_color, 0, sizeof(GLKVector4));
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

//special setters
-(void) specialSetterColor:(NSData*)data {
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    GLKVector4 temp = [CDataInitializer getVec4ColorFromDictionary:dict];
    (*_color) = temp;
}

@end

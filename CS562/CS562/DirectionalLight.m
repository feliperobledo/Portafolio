//
//  DirectionalLight.m
//  CS562
//
//  Created by Felipe Robledo on 10/20/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "DirectionalLight.h"
#import <CDataInitializer.h>

@implementation DirectionalLight

START_SPECIAL_SETTORS(DirectionalLight)

    ADD_SPECIAL_SETTER(@"color", @"specialSetterColor:");
    ADD_SPECIAL_SETTER(@"direction", @"specialSetterDirection:");

END_SPECIAL_SETTORS

-(id) init {
    if ((self = [super init])) {
        _color = (GLKVector4*)malloc(sizeof(GLKVector4));
        memset(_color, 0, sizeof(GLKVector4));
        
        _direction = (GLKVector3*)malloc(sizeof(GLKVector3));
        memset(_direction, 0, sizeof(GLKVector3));
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

-(void) specialSetterDirection:(NSData*)data {
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    GLKVector3 temp = [CDataInitializer getVec3FromDictionary:dict];
    (*_direction) = temp;
}

@end

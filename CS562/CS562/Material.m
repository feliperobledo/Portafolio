//
//  Material.m
//  CS562
//
//  Created by Felipe Robledo on 9/28/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <Material.h>
#import <CDataInitializer.h>

@implementation Material

START_SPECIAL_SETTORS(Material)

    ADD_SPECIAL_SETTER(@"diffuse",  @"specialSetterDiffuse:")
    ADD_SPECIAL_SETTER(@"emissive", @"specialSetterEmissive:")

END_SPECIAL_SETTORS

-(id) init {
    if ((self = [super init])) {
        _diffuse  = (GLKVector4*)malloc(sizeof(GLKVector4));
        _emissive = (GLKVector4*)malloc(sizeof(GLKVector4));
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

// special setters
-(void) specialSetterDiffuse:(NSDictionary*)data {
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    (*_diffuse)= [CDataInitializer getVec4ColorFromDictionary:dict];
}

-(void) specialSetterEmissive:(NSDictionary*)data {
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    (*_emissive)= [CDataInitializer getVec4ColorFromDictionary:dict];
}

@end

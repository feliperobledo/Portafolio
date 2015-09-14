//
//  MeshStore.m
//  CS562
//
//  Created by Felipe Robledo on 9/14/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "MeshStore.h"

@implementation MeshStore

-(id) init {
    if((self = [super init])) {
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if((self = [super initWithOwner:owner])) {
        
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
    // For every filename in our array, we are going to create all our meshes
}

@end

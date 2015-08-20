//
//  IController.m
//  CS562Core
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "IController.h"

@implementation IController

-(id) initWithOwner:(Entity*)owner {
    if(self != [super init]){
        _owner = owner;
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSObject*)ser {
    if(self != [super init]){
        
    }
    return self;
}

//------------------------------------------------------------------------------

-(void) serializeWith:(NSObject*)ser {
    // ..get data from object
}

-(const Entity*)Owner{
    return _owner;
}

-(void) initControllerBindings {
    [self doesNotRecognizeSelector:_cmd];
}

-(void) update:(Float32)dt {
    [self doesNotRecognizeSelector:_cmd];    
}

@end

//
//  IModel.m
//  CS562Core
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "IModel.h"

@implementation IModel

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

@end

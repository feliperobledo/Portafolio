//
//  SampleModel2.m
//  CS562Core
//
//  Created by Felipe Robledo on 9/11/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "SampleModel2.h"
#import <objc/runtime.h>

@implementation SampleModel2

-(id) init {
    if(self == [super init]){

    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if(self == [super initWithOwner:owner]){
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser {
    if(self == [super initWithOwner:owner usingSerializer:ser]){
        
    }
    return self;
}

@end

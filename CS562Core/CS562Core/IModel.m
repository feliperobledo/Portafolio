//
//  IModel.m
//  CS562Core
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "IModel.h"

@implementation IModel

-(id) init {
    if(self = [super init]){
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if(self = [super initWithOwner:owner]){
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser {
    if(self = [super initWithOwner:owner usingSerializer:ser]){
        
    }
    return self;
}

-(void)postInit {
    [self doesNotRecognizeSelector:_cmd];
}

/* Mimic dictionary interface.
 * Required for component initialization
 */
-(id) initWithDictionary:(NSDictionary*)dict {
    
    return self;
}

-(void) serializeWith:(NSObject*)ser {
    // ..get data from object
}

@end

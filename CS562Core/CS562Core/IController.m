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
    if(self != [super initWithOwner:owner]){
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser {
    if(self != [super initWithOwner:owner usingSerializer:ser]){
        
    }
    return self;
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

//------------------------------------------------------------------------------

-(void) initControllerBindings {
    [self doesNotRecognizeSelector:_cmd];
}

-(void) update:(Float32)dt {
    [self doesNotRecognizeSelector:_cmd];    
}

@end

//
//  Connector.m
//  CS562Core
//
//  Created by Felipe Robledo on 8/27/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "Connector.h"
#import <Cocoa/Cocoa.h>

@implementation Connector


-(id) initWithOwner:(Entity*)owner {
    if(self == [super init]){
        _owner = owner;
    }
    
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser {
    if(self == [super init]){
        
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

-(void) setOwner:(Entity*)newOwner{
    _owner = newOwner;
}

-(const Entity*)Owner{
    return _owner;
}

@end

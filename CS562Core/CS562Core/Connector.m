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

-(void) serializeWith:(NSObject*)ser {
    // ..get data from object
}

-(const Entity*)Owner{
    return _owner;
}

//------------------------------------------------------------------------------

-(void) connect:(SEL)method toSignal:(NSString*)signal from:(Connector*)caster {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:method
                                          name:signal
                                          object:caster];
    
    /*
     Be sure to invoke removeObserver:name:object: before notificationObserver or any object specified in addObserver:selector:name:object: is deallocated.
     */
}

-(void) disconnect:(NSString*)signalName {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:signalName object:nil];
}

-(void) disconnectionCompletely {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) emmit:(NSString*)signalName withData:(NSDictionary*)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:signalName object:self userInfo:data];
}

@end

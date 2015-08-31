//
//  Connector.h
//  CS562Core
//
//  Created by Felipe Robledo on 8/27/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Entity;

@interface Connector : NSObject
{
    @private
        Entity* _owner;
}

-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSObject*)ser;
-(void) serializeWith:(NSObject*)ser;
-(const Entity*)Owner;

// Connect self to a signal from another object
-(void) connect:(SEL)method toSignal:(NSString*)signal from:(Connector*)caster;

// Remove this connector from that signal
-(void) disconnect:(NSString*)signalName;

// Remove this connector from all signals it has been attached to
-(void) disconnectionCompletely;

// Have this connector emit a signal with specific data
-(void) emmit:(NSString*)signalName withData:(NSDictionary*)data;

@end

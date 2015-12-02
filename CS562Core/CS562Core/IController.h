//  IController.h
//  CS562Core
//
//  Description: A Controller acts as a bridge between a View and a Model. When
//               created, the Controller should bind to the notification center
//               after serialized.
//
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.

#import "Connector.h"

@class Entity;

// Should intead inherit from NSResponder
/* For my own looping, I need to create a timer as follows:
 *
 *  const float framerate = 40;
    const float frequency = 1.0f/framerate;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:frequency
        target:self selector:@selector(update) userInfo:nil repeats:YES];
 *
 *
 * This code would have to be in the main world view.
 */
@interface IController : Connector

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

// controller only methods
-(void) initControllerBindings;
-(void) update:(Float32)dt;

@end

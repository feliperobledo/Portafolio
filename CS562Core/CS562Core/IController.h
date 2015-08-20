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

#import <Foundation/Foundation.h>

// Forward declarations
@class Entity;

@interface IController : NSObject
{
    @private
    Entity* _owner;
}

-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSObject*)ser;
-(void) serializeWith:(NSObject*)ser;
-(const Entity*)Owner;

// controller only methods
-(void) initControllerBindings;
-(void) update:(Float32)dt;

@end

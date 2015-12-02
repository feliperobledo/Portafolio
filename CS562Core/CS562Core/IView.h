//
//  IView.h
//  CS562Core
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//
// should connect to a controller for update (ie. on controller.Notify - view.update

#import "Connector.h"

@class Entity;

@interface IView : Connector
{
    @private
}

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

// all other public methods are child-class dependent and should be used to inform
//     the controller of changes.

@end

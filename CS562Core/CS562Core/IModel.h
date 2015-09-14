//
//  IModel.h
//  CS562Core
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "Connector.h"

@class Entity;

@interface IModel : Connector

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) postInit;
-(void) serializeWith:(NSObject*)ser;

// all other public methods are child-class dependent and should be used to inform
//     the controller of changes.

@end

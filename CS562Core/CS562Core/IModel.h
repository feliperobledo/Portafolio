//
//  IModel.h
//  CS562Core
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Entity;

@interface IModel : NSObject
{
    @private
        Entity* _owner;
}

-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSObject*)ser;
-(void) serializeWith:(NSObject*)ser;
-(const Entity*)Owner;

// all other public methods are child-class dependent and should be used to inform
//     the controller of changes.

@end

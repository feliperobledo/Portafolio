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
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;

-(void) setOwner:(Entity*)newOwner;
-(const Entity*)Owner;



@end

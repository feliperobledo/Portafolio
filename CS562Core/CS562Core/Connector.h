//
//  Connector.h
//  CS562Core
//
//  Created by Felipe Robledo on 8/27/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//
//  Todo: add support for json name aliases, so in-code names follow a standard
//        and json names are human readable.
//

#import <Foundation/Foundation.h>

/*json alises*/
#define CORE_SETUP_DECLARE \
    +(void) addAliasesToGlobalStore;\
    +(void) addClassToGlobalStore;

#define START_ALIASES_SETUP \
    +(void) addAliasesToGlobalStore { \

#define ADD_ALIAS(varName,alias) \
    [[self __aliases] addValue:varName forKey:[[NSString alloc] initWithUTF8String:#alias]

#define END_ALIASES_SETUP }

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

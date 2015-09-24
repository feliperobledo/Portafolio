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



/*
    The following macros help with the serialization of objects that are not 
    strictly children of NSObject. JSONSerializer uses NSArray, NSDictionary,
    NSNumber and NSString for all its values, and we need to translate those to
    out special C structs or other classes, meaning that the representation on
    the JSON file does NOT equate to the type in the application.
 */
#define SPECIAL_SETTOR_DECLARE(class)                                          \
+(NSMutableDictionary*) get##class##SpecialSetterDictionary;                   \
+(void) addSpecialSettors;                                                     \
-(BOOL) couldProperBeSetWithSpecialSetter:(NSString*)propName withData:(NSObject*)data;

#define START_SPECIAL_SETTORS(class)                                           \
    -(BOOL) couldProperBeSetWithSpecialSetter:(NSString*)propName withData:(NSObject*)data {            \
        NSDictionary* specialSetterDict =                                      \
            [class get##class##SpecialSetterDictionary];                       \
                                                                               \
       NSString* selectorName = [specialSetterDict valueForKey:propName];      \
       if(selectorName == nil) {\
           NSLog(@"%s: does not have special setter for %s",#class,[propName UTF8String]);\
           return NO;                                                          \
       }                                                                       \
       SEL selector = NSSelectorFromString(selectorName);                      \
       IMP imp = [self methodForSelector:selector];                            \
       void (*func)(id, SEL,NSObject*) = (void *)imp;                          \
       func(self, selector,data);                                              \
       return YES;                                                             \
    }                                                                          \
                                                                               \
    +(NSMutableDictionary*) get##class##SpecialSetterDictionary {              \
        static NSMutableDictionary *dict = nil;                                \
        if (dict == nil) {                                                     \
            NSLog(@"%s: init special setter dictionary",#class);               \
            dict = [[NSMutableDictionary alloc] init];                         \
        }                                                                      \
        return dict;                                                           \
    }                                                                          \
                                                                               \
    +(void) addSpecialSettors {                                                \
        static BOOL hasInitialized = NO;                                       \
        if(!hasInitialized) {                                                  \
            NSMutableDictionary* temp = [class get##class##SpecialSetterDictionary];

#define ADD_SPECIAL_SETTER(varName,setterStringName) \
    [temp setObject:setterStringName forKey:varName];\


#define END_SPECIAL_SETTORS NSLog(@"Dict: - %@",temp);}}




// Before setting a property
//     look into a dictionary of the classes' exceptions
//     if the name of the property is in the dictionary
//         call the selector that is in the dictionary with the data used to serialize
//     else
//         use the common initialization

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

SPECIAL_SETTOR_DECLARE(Connector)



@end

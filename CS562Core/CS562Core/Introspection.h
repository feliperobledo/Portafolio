//
//  Introspection.h
//  CS562Core
//
//  Created by Felipe Robledo on 9/1/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Introspection : NSObject

+(NSArray*)getPropertiesOfClass:(Class)objectClass;
+(NSString*)convertToJsonName:(NSString*)propName start:(NSInteger)start;

@end

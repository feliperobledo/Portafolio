//
//  Introspection.m
//  CS562Core
//
//  Created by Felipe Robledo on 9/1/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "Introspection.h"
#import <objc/runtime.h>

@implementation Introspection

+(NSArray*)getPropertiesOfClass:(Class)objectClass
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(objectClass, &outCount);
    NSMutableArray *gather = [NSMutableArray arrayWithCapacity:outCount];
    for(i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        
        // Get property name and type
        NSString* propName = [NSString stringWithUTF8String:property_getName(property)];
        const char *type = property_getAttributes(property);
        NSString *typeString = [NSString stringWithUTF8String:type];
        
        // Break down the attributes of the properties
        NSArray *attributes = [typeString componentsSeparatedByString:@","];
        NSString *typeAttribute = [attributes objectAtIndex:0];
        
        // If the first attribute says the property is a class...
        if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 3)
        {
            NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
            Class typeClass = NSClassFromString(typeClassName);
            //if(!self.propertyClasses)
            //    self.propertyClasses = [[NSMutableDictionary alloc] init];
            //[self.propertyClasses setObject:typeClass forKey:propName];
        }
        [gather addObject:propName];
    }
    free(properties);
    if([objectClass superclass] && [objectClass superclass] != [NSObject class])
        [gather addObjectsFromArray:[self getPropertiesOfClass:[objectClass superclass]]];
    return gather;
}

+(NSString*)convertToJsonName:(NSString*)propName start:(NSInteger)start
{
    NSRange range = [propName rangeOfString:@"[a-z.-][^a-z .-]" options:NSRegularExpressionSearch range:NSMakeRange(start, propName.length-start)];
    if(range.location != NSNotFound && range.location < propName.length)
    {
        unichar c = [propName characterAtIndex:range.location+1];
        propName = [propName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c",c]
                                                       withString:[[NSString stringWithFormat:@"_%c",c] lowercaseString]
                                                          options:0 range:NSMakeRange(start, propName.length-start)];
        return [self convertToJsonName:propName start:range.location+1];
    }
    return propName;
}

@end

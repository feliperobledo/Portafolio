//
//  CDataInitializer.m
//  CS562
//
//  Created by Felipe Robledo on 9/23/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "CDataInitializer.h"

@implementation CDataInitializer

+(GLKVector2) getVec2FromArray:(NSArray*)data {
    GLKVector2 temp;
    temp.x = [[data objectAtIndex:0] floatValue];
    temp.y = [[data objectAtIndex:1] floatValue];
    return temp;
}

+(GLKVector2) getVec2FromDictionary:(NSDictionary*)data {
    GLKVector2 temp;
    temp.x = [[data objectForKey:@"x"] floatValue];
    temp.y = [[data objectForKey:@"y"] floatValue];
    return temp;
}

+(GLKVector3) getVec3FromArray:(NSArray*)data {
    GLKVector3 temp;
    temp.x = [[data objectAtIndex:0] floatValue];
    temp.y = [[data objectAtIndex:1] floatValue];
    temp.z = [[data objectAtIndex:2] floatValue];
    return temp;
}

+(GLKVector3) getVec3FromDictionary:(NSDictionary*)data {
    GLKVector3 temp;
    temp.x = [[data objectForKey:@"x"] floatValue];
    temp.y = [[data objectForKey:@"y"] floatValue];
    temp.z = [[data objectForKey:@"z"] floatValue];
    return temp;
}

+(GLKVector3) getVec3ColorFromDictionary:(NSDictionary*)data {
    GLKVector3 temp;
    temp.x = [[data objectForKey:@"r"] floatValue];
    temp.y = [[data objectForKey:@"g"] floatValue];
    temp.z = [[data objectForKey:@"b"] floatValue];
    return temp;
}

+(GLKVector4) getVec4FromArray:(NSArray*)data {
    GLKVector4 temp;
    temp.x = [[data objectAtIndex:0] floatValue];
    temp.y = [[data objectAtIndex:1] floatValue];
    temp.z = [[data objectAtIndex:2] floatValue];
    temp.w = [[data objectAtIndex:3] floatValue];
    return temp;
}

+(GLKVector4) getVec4FromDictionary:(NSDictionary*)data {
    GLKVector4 temp;
    temp.x = [[data objectForKey:@"x"] floatValue];
    temp.y = [[data objectForKey:@"y"] floatValue];
    temp.z = [[data objectForKey:@"z"] floatValue];
    temp.w = [[data objectForKey:@"w"] floatValue];
    return temp;
}

+(GLKVector4) getVec4ColorFromDictionary:(NSDictionary*)data {
    GLKVector4 temp;
    temp.x = [[data objectForKey:@"r"] floatValue];
    temp.y = [[data objectForKey:@"g"] floatValue];
    temp.z = [[data objectForKey:@"b"] floatValue];
    temp.w = [[data objectForKey:@"a"] floatValue];
    return temp;
}

+(GLKQuaternion) getQuaternionFromArray:(NSArray*)data {
    GLKVector4 temp = [CDataInitializer getVec4FromArray:data];
    return GLKQuaternionMake(temp.x, temp.y, temp.z, temp.w);
}

+(GLKQuaternion) getQuaternionFromDictionary:(NSDictionary*)data {
    GLKVector4 temp = [CDataInitializer getVec4FromDictionary:data];
    return GLKQuaternionMake(temp.x, temp.y, temp.z, temp.w);
}

@end

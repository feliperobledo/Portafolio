//
//  CDataInitializer.h
//  CS562
//
//  Created by Felipe Robledo on 9/23/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface CDataInitializer : NSObject

+(GLKVector2) getVec2FromArray:(NSArray*)data;
+(GLKVector2) getVec2FromDictionary:(NSDictionary*)data;
+(GLKVector3) getVec3FromArray:(NSArray*)data;
+(GLKVector3) getVec3FromDictionary:(NSDictionary*)data;
+(GLKVector4) getVec4FromArray:(NSArray*)data;
+(GLKVector4) getVec4FromDictionary:(NSDictionary*)data;
+(GLKQuaternion) getQuaternionFromArray:(NSArray*)data;
+(GLKQuaternion) getQuaternionFromDictionary:(NSDictionary*)data;


@end

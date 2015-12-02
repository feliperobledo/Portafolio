//
//  PointLight.h
//  CS562
//
//  Created by Felipe Robledo on 9/28/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>
#import <GLKit/GLKVector4.h>

@interface PointLight : IModel

@property GLKVector4* color;
@property NSNumber* range;
@property NSNumber* attenuation;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

SPECIAL_SETTOR_DECLARE(PointLight);

//special setters
-(void) specialSetterColor:(NSData*)data;

@end

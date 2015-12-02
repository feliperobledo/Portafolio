//
//  DirectionalLight.h
//  CS562
//
//  Created by Felipe Robledo on 10/20/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>
#import <GLKit/GLKVector4.h>
#import <GLKit/GLKVector3.h>

@interface DirectionalLight : IModel

@property GLKVector4* color;
@property GLKVector3* direction;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

SPECIAL_SETTOR_DECLARE(DirectionalLight);

//special setters
-(void) specialSetterColor:(NSData*)data;
-(void) specialSetterDirection:(NSData*)data;

@end

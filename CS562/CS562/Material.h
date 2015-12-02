//
//  Material.h
//  CS562
//
//  Created by Felipe Robledo on 9/28/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>
#import <GLKit/GLKVector4.h>

@interface Material : IModel

@property NSNumber* specularity;
@property GLKVector4* diffuse;
@property GLKVector4* emissive;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

SPECIAL_SETTOR_DECLARE(Material);

// special setters
-(void) specialSetterDiffuse:(NSDictionary*)data;
-(void) specialSetterEmissive:(NSDictionary*)data;

@end

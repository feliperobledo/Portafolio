//
//  World.h
//  CS562
//
//  Created by Felipe Robledo on 9/24/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>

@interface World : IModel

@property (strong,nonatomic) NSNumber* skydome;
@property (strong,nonatomic) NSMutableArray* gameObjects;
@property (strong,nonatomic) NSMutableDictionary* lights;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

-(NSArray*) getWorldObjects;
-(NSNumber*) getEntityWithName:(NSString*)entityName;

SPECIAL_SETTOR_DECLARE(World);
-(void) gameObjectsSpecialSetter:(NSObject*)data;
-(void) lightsSpecialSetter:(NSObject*)data;

@end

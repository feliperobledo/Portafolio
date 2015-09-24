//
//  Model.h
//  CS562
//
//  Created by Felipe Robledo on 9/22/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>
#import <CS562Core/Connector.h>

@interface Model3D : IModel

@property NSMutableString* meshSource;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

SPECIAL_SETTOR_DECLARE(Model3D);

// Special Setters
-(void)meshSourceSpecialSetter:(NSObject*)data;

@end

//
//  PerspectiveView.h
//  CS562
//
//  Created by Felipe Robledo on 9/30/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>
#import <GLKit/GLKMatrix4.h>

@interface PerspectiveView : IModel

@property NSNumber* near;
@property NSNumber* far;
@property NSNumber* fov;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

-(GLKMatrix4) makeTransformWithWidth:(GLfloat)width andHeight:(GLfloat)height;

SPECIAL_SETTOR_DECLARE(PerspectiveView);

@end

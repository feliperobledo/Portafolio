//
//  Transform.h
//  CS562
//
//  Created by Felipe Robledo on 9/22/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>
#import <GLKit/GLKit.h>

struct TransformData {
    GLKVector3 position, scale, rotation;
};

typedef struct TransformData TransformData;

@interface Transform : IModel

@property TransformData* data;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

-(GLKMatrix4) transformation;
-(GLKVector3) position;
-(GLKVector3) scale;
-(GLKMatrix4) rotation;

-(void) setPosition:(GLKVector3)pos;

-(void) translateBy:(GLKVector3)translation;

-(void) setForward:(GLKVector3)forward;
-(GLKVector3) forward;
-(GLKVector3) right;
-(GLKVector3) up;
-(void) rotateOnAxis:(GLKVector3)axis byAngle:(GLfloat)radians;

SPECIAL_SETTOR_DECLARE(Transform);

-(void) specialSetterData:(NSObject*)data;
-(void) specialSetterTranslation:(NSObject*)data;
-(void) specialSetterScale:(NSObject*)data;
-(void) specialSetterRotation:(NSObject*)data;


@end

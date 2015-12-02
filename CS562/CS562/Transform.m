//
//  Transform.m
//  CS562
//
//  Created by Felipe Robledo on 9/22/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <Transform.h>
#import <CDataInitializer.h>

@implementation Transform
{
    GLKVector3 forward, up, right;
}

START_SPECIAL_SETTORS(Transform)

    ADD_SPECIAL_SETTER(@"data", @"specialSetterData:")

    ADD_SPECIAL_SETTER(@"translation", @"specialSetterTranslation:")
    ADD_SPECIAL_SETTER(@"scale", @"specialSetterScale:")
    ADD_SPECIAL_SETTER(@"rotation", @"specialSetterRotation:")

END_SPECIAL_SETTORS

-(id) init {
    if ((self = [super init])) {
        _data = (TransformData*)malloc(sizeof(TransformData));
        
        forward = GLKVector3Make(0,0,1);
        up = GLKVector3Make(0,1,0);
        right = GLKVector3Normalize( GLKVector3CrossProduct(forward, up) );
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if ((self = [super initWithOwner:owner])) {
        _data = (TransformData*)malloc(sizeof(TransformData));
        
        forward = GLKVector3Make(0,0,1);
        up = GLKVector3Make(0,1,0);
        right = GLKVector3Normalize( GLKVector3CrossProduct(forward, up) );
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser {
    if ((self = [super initWithOwner:owner usingSerializer:ser])) {
        
    }
    return self;
}

-(id) initWithDictionary:(NSDictionary*)dict {
    if ((self = [super initWithDictionary:dict])) {
        
    }
    return self;
}

-(void) serializeWith:(NSObject*)ser {
    
}

-(void) postInit {
    
}

-(GLKMatrix4) transformation {
    GLKMatrix4 translation, rotation, scale;
    
    scale       = GLKMatrix4MakeScale(_data->scale.x, _data->scale.y, _data->scale.z);
    rotation    = [self rotation];
    translation = GLKMatrix4MakeTranslation(_data->position.x, _data->position.y, _data->position.z);
    
    return GLKMatrix4Multiply(translation,GLKMatrix4Multiply(rotation, scale));
}

-(GLKVector3) position {
    return _data->position;
}

-(void) setPosition:(GLKVector3)pos {
    _data->position = pos;
}

-(GLKVector3) scale {
    return _data->scale;
}

-(GLKMatrix4) rotation {
    /*
    float yaw = _data->rotation.x,
          pitch = _data->rotation.y,
          roll = _data->rotation.z;
    GLKQuaternion q = GLKQuaternionMake(yaw, pitch, roll, 1);
    return GLKMatrix4MakeWithQuaternion(q);
     */
    
    GLKVector4 c1 = GLKVector4MakeWithVector3(right, 0),
               c2 = GLKVector4MakeWithVector3(up, 0),
               c3 = GLKVector4MakeWithVector3(forward, 0),
               c4 = GLKVector4Make(0, 0, 0, 1);
    
    return GLKMatrix4MakeWithColumns(c1, c2, c3, c4);
}

-(void) setForward:(GLKVector3)f {
    f = GLKVector3Normalize(f);
    
    // This function should figure out how to find the change in
    //    yaw and pitch that is required to align the basis
    //    of the transform with the forward direction of the basis
    //    with the forward direction we want.
}

-(GLKVector3) forward {
    return forward;
}

-(GLKVector3) right {
    return right;
}

-(GLKVector3) up {
    return up;
}

-(void) rotateOnAxis:(GLKVector3)axis byAngle:(GLfloat)radians {
    GLKQuaternion q = GLKQuaternionMakeWithAngleAndVector3Axis(radians, axis);
    up = GLKQuaternionRotateVector3(q, up);
    forward = GLKQuaternionRotateVector3(q, forward);
    right = GLKQuaternionRotateVector3(q, right);
}

-(void) translateBy:(GLKVector3)translation {
    _data->position = GLKVector3Add(_data->position, translation);
}


// Special setters
-(void) specialSetterData:(NSObject*)data {
    NSLog(@"specialSetterData");
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    
    if([dict valueForKey:@"translation"] != nil) {
        [self specialSetterTranslation:[dict valueForKey:@"translation"]];
    }
    if([dict valueForKey:@"scale"] != nil) {
        [self specialSetterScale:[dict valueForKey:@"scale"]];
    }
    if([dict valueForKey:@"rotation"] != nil) {
        [self specialSetterRotation:[dict valueForKey:@"rotation"]];
    }
}

-(void) specialSetterTranslation:(NSObject*)data {
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    
    [self data]->position = [CDataInitializer getVec3FromDictionary:dict];
}

-(void) specialSetterScale:(NSObject*)data {
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    
    [self data]->scale = [CDataInitializer getVec3FromDictionary:dict];
}

-(void) specialSetterRotation:(NSObject*)data {
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    
    [self data]->rotation = [CDataInitializer getVec3FromDictionary:dict];
    float yaw = _data->rotation.x,
          pitch = _data->rotation.y,
          roll = _data->rotation.z;
    
    // perform jaw rotation on axes
    [self rotateOnAxis:right   byAngle:yaw];
    [self rotateOnAxis:up      byAngle:pitch];
    [self rotateOnAxis:forward byAngle:roll];
}

@end

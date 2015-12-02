//
//  LinearTrackBall.m
//  CS562
//
//  Created by Felipe Robledo on 11/11/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "LinearTrackBall.h"
#import <Transform.h>
#import <ShadowCastingLight.h>
#import <CDataInitializer.h>

@interface LinearTrackBall(PrivateMethods)

-(BOOL) overMaxDistance:(Transform*)transform;
-(void) changeDirection;
-(void) updateLookAtDirection:(Transform*)transform;

@end

@implementation LinearTrackBall
{
    int direction;
    BOOL active;
}

START_SPECIAL_SETTORS(LinearTrackBall)

    ADD_SPECIAL_SETTER(@"lookAt", @"specialSetterLookAt:")

END_SPECIAL_SETTORS

-(id) init {
    if(self = [super init]) {
        _distance = [[NSNumber alloc] init];;
        _speed = [[NSNumber alloc] init];
        _lookAt = (GLKVector3*)malloc(sizeof(GLKVector3));
        active = false;
        memset(_lookAt, 0, sizeof(GLKVector3));
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if(self = [super initWithOwner:owner]){
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser {
    if(self = [super initWithOwner:owner usingSerializer:ser]){
        
    }
    return self;
}

-(void) postInit {
    // Align this object at the same z value of the lookat
    Transform *transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    
    // Move this object's x by distance variable
    GLKVector3 pos = [transform position];
    pos.x = 0.0f;
    pos.z = (*_lookAt).z;
    pos.x += [_distance floatValue];
    direction = -1;
    [transform setPosition:pos];
    
    [self updateLookAtDirection:transform];
}

/* Mimic dictionary interface.
 * Required for component initialization
 */
-(id) initWithDictionary:(NSDictionary*)dict {
    
    return self;
}

-(void) serializeWith:(NSObject*)ser {
    // ..get data from object
}

-(void) initControllerBindings {
    [self connect:@selector(toggleActive) toSignal:@"lightMove" from:nil];
}

-(void) update:(Float32)dt {
    if(!active) return;
    
    Transform *transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    
    // Move
    GLKVector3 pos = [transform position];
    pos.x += direction * [_speed floatValue] * dt;
    [transform setPosition:pos];
    
    if([self overMaxDistance:transform]) {
        [self changeDirection];
    }
    
    [self updateLookAtDirection:transform];
}

// Private Methods
-(BOOL) overMaxDistance:(Transform*)transform; {
    // Move this object's x by distance variable
    GLKVector3 pos = [transform position];
    GLfloat origin = (*_lookAt).x,
            dist = [_distance floatValue];
    if(direction > 0 &&
       pos.x > (origin + dist) ) {
        return YES;
    } else if(direction < 0 &&
       pos.x < (origin - dist) ) {
        return YES;
    }
    return NO;
}

-(void) changeDirection {
    direction *= -1;
}

-(void) toggleActive {
    active = !active;
}

-(void) updateLookAtDirection:(Transform*)transform {
    GLKVector3 pos = [transform position];
    GLKVector3 newLookAtDir = GLKVector3Normalize(GLKVector3Subtract((*_lookAt), pos));
    
    ShadowCastingLight *shadowCast = (ShadowCastingLight*)[[self Owner] getViewWithName:@"ShadowCastingLight"];
    
    [shadowCast setDirection:newLookAtDir];
}

// Special setters
-(void) specialSetterLookAt:(NSObject*)data {
    NSLog(@"specialSetterLookAt");
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    *(_lookAt) = [CDataInitializer getVec3FromDictionary:dict];
}

@end

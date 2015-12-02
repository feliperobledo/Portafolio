//
//  LinearTrackBall.h
//  CS562
//
//  Created by Felipe Robledo on 11/11/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>
#import <GLKit/GLKVector3.h>

@interface LinearTrackBall : IController

@property NSNumber* distance;
@property NSNumber* speed;
@property GLKVector3* lookAt;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

// controller only methods
-(void) initControllerBindings;
-(void) update:(Float32)dt;

SPECIAL_SETTOR_DECLARE(LinearTrackBall);

-(void) specialSetterLookAt:(NSObject*)data;

@end

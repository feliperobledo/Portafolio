//
//  FirstPersonControls.h
//  CS562
//
//  Created by Felipe Robledo on 9/24/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>

@interface FirstPersonControls : IController

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

// controller only methods
-(void) initControllerBindings;
-(void) update:(Float32)dt;

-(void) reactRightMouseDown:(NSDictionary*)data;

-(void)zAxisMoveForward;
-(void)zAxisMoveBack;
-(void)moveUp;
-(void)moveDown;
-(void)moveLeft;
-(void)moveRight;
-(void)moveBack;
-(void)moveForward;
-(void)turnRight;
-(void)turnLeft;
@end

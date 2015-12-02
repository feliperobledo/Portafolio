//
//  FirstPersonControls.m
//  CS562
//
//  Created by Felipe Robledo on 9/24/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <FirstPersonControls.h>
#import <Transform.h>
#import <CS562Core/CS562Core.h>

// Privates
@interface FirstPersonControls(PrivateMethods)
@end


// TODO: Change camera rotation by using basis a basis
@implementation FirstPersonControls
{
    
}

-(id) init {
    if(self = [super init]) {

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
    // do some bindings to some messages
    [self connect:@selector(reactRightMouseDown:) toSignal:@"rightMousePressed" from:nil];
    
    [self connect:@selector(moveLeft)   toSignal:@"moveLeft"   from:nil];
    [self connect:@selector(moveRight)  toSignal:@"moveRight"   from:nil];
    [self connect:@selector(moveUp)     toSignal:@"moveUp"
        from:nil];
    [self connect:@selector(moveDown)    toSignal:@"moveDown"   from:nil];
    [self connect:@selector(moveBack)    toSignal:@"moveBack"   from:nil];
    [self connect:@selector(moveForward) toSignal:@"moveForward"   from:nil];
    [self connect:@selector(turnRight)   toSignal:@"turnRight"   from:nil];
    [self connect:@selector(turnLeft)    toSignal:@"turnLeft"   from:nil];
    [self connect:@selector(lookUp)      toSignal:@"lookUp"   from:nil];
    [self connect:@selector(lookDown)    toSignal:@"lookDown"   from:nil];
}

-(void) update:(Float32)dt {
    // do some sort of update
}

//------------------------------------------------------------------------------
-(void) reactRightMouseDown:(NSDictionary*)data {
    //NSEvent* theEvent = [data valueForKey:@"Event"];
    //NSLog(@"%@",theEvent);
}

-(void)zAxisMoveForward {
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    GLKVector3 zAxis = GLKVector3Make(0, 0, 1);
    // rotate zAxis by same pitch as as forward vector
    //     this means that the transform component has to keep track of what
    //     pitch it has! How do I do this...
    //     Anyway, this is not part of the assignment, so I will worry about
    //     this problem later on.
    //     GOING TO TAKE A LITTLE BREAK!
    // move along that vector
}

-(void)zAxisMoveBack {
    
}

-(void)moveUp {
    GLKVector3 translation = GLKVector3Make(0, 1, 0);
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    [transform translateBy:translation];
}

-(void)moveDown {
    GLKVector3 translation = GLKVector3Make(0, -1, 0);
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    [transform translateBy:translation];
}

-(void)moveLeft {
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    GLKVector3 translation = GLKVector3MultiplyScalar([transform right], -1.5);
    [transform translateBy:translation];
}

-(void)moveRight {
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    GLKVector3 translation = GLKVector3MultiplyScalar([transform right], 1.5);
    [transform translateBy:translation];
    
}

-(void)moveBack {
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    GLKVector3 translation = GLKVector3MultiplyScalar([transform forward], -1.0);
    [transform translateBy:translation];
}

-(void)moveForward {
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    GLKVector3 translation = GLKVector3MultiplyScalar([transform forward], 1.0);
    [transform translateBy:translation];
}

-(void)turnRight {
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    GLKVector3 up = GLKVector3Make(0, 1, 0);
    [transform rotateOnAxis:up byAngle:0.05];
}

-(void)turnLeft {
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    GLKVector3 up = GLKVector3Make(0, 1, 0);
    [transform rotateOnAxis:up byAngle:-0.05];
    
}

-(void)lookUp {
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    [transform rotateOnAxis:[transform right] byAngle:-0.25];
}

-(void)lookDown {
    Transform* transform = (Transform*)[[self Owner] getModelWithName:@"Transform"];
    NSAssert(transform != nil,@"ERROR: Camera should have a Transform.");
    
    [transform rotateOnAxis:[transform right] byAngle:0.25];
    
}

//PRIVATE-----------------------------------------------------------------------



@end

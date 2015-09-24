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
    GLKVector3 position, scale;
    GLKQuaternion rotation;
};

typedef struct TransformData TransformData;

@interface Transform : IModel

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

SPECIAL_SETTOR_DECLARE(Transform);

@property TransformData* data;

-(void) specialSetterData:(NSObject*)data;

@end

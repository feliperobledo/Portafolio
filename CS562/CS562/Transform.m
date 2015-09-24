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

START_SPECIAL_SETTORS(Transform)

    ADD_SPECIAL_SETTER(@"data", @"specialSetterData:")

END_SPECIAL_SETTORS

-(id) init {
    if ((self = [super init])) {
        _data = (TransformData*)malloc(sizeof(TransformData));
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if ((self = [super initWithOwner:owner])) {
        
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


// Special setters
-(void) specialSetterData:(NSObject*)data {
    NSLog(@"specialSetterData");
    NSDictionary* dict = (NSDictionary*)data;
    if(dict == nil) {
        return;
    }
    
    [self data]->position = [CDataInitializer getVec3FromDictionary:[dict valueForKey:@"translation"]];
    [self data]->scale    = [CDataInitializer getVec3FromDictionary:[dict valueForKey:@"scale"]];
    [self data]->rotation = [CDataInitializer getQuaternionFromDictionary:[dict valueForKey:@"rotation"]];
}

@end

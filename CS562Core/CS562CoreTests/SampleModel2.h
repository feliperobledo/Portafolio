//
//  SampleModel2.h
//  CS562Core
//
//  Created by Felipe Robledo on 9/11/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "IModel.h"

/*
 "radius" : 1.0005,
 "position" : {
    "x" : 1,
    "y" : 0,
    "z" : 0,
 },
 */

@interface SampleModel2 : IModel

@property NSNumber* radius;
@property NSMutableDictionary* position;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;

@end

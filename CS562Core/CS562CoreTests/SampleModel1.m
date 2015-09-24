//
//  SampleModel1.m
//  CS562Core
//
//  Created by Felipe Robledo on 9/11/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "SampleModel1.h"

@implementation SampleModel1

START_SPECIAL_SETTORS(SampleModel1)

    ADD_SPECIAL_SETTER(@"source", @"sourceSpecialSetter:")

END_SPECIAL_SETTORS

-(id) init {
    if(self == [super init]){

    }
    return self;
}

-(void) sourceSpecialSetter:(NSObject*)data {
    NSLog(@"Something");
}

@end

//
//  SampleModel1.h
//  CS562Core
//
//  Created by Felipe Robledo on 9/11/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "IModel.h"

/*
 "age"  : 10,
 "name" : "Eily",
 "students" : ["Felipe","Someone"],
 "source" : {
     "Name:" : "foo",
     "Type:" : "bar",
 }
 */

@interface SampleModel1 : IModel

@property NSNumber* age;
@property NSString* name;
@property NSMutableArray* students;
@property NSString* source;

-(id) init;

SPECIAL_SETTOR_DECLARE(SampleModel1)
-(void) sourceSpecialSetter:(NSObject*)data;

@end

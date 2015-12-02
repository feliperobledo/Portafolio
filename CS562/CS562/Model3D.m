//
//  Model.m
//  CS562
//
//  Created by Felipe Robledo on 9/22/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <Model3D.h>

@implementation Model3D

START_SPECIAL_SETTORS(Model3D)

    ADD_SPECIAL_SETTER(@"meshSource", @"meshSourceSpecialSetter:")

END_SPECIAL_SETTORS

-(id) init {
    if ((self = [super init])) {
        _meshSource = [[NSString alloc] init];
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

// Special Setters
-(void)meshSourceSpecialSetter:(NSObject*)data {
    NSLog(@"meshSourceSpecialSetter");
    NSDictionary* dict = (NSDictionary*)data;
    if(dict != nil) {
        // concatenate the parts of the file source name
        _meshSource = [NSMutableString stringWithString:[dict objectForKey:@"Name"]];
        [_meshSource appendString:@"."];
        [_meshSource appendString:[NSMutableString stringWithString:[dict objectForKey:@"Type"]]];
    }
}

@end

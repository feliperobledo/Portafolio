//
//  nsobject-extensions.m
//  CS562Core
//
//  Created by Felipe Robledo on 9/13/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "nsobject-extensions.h"

@implementation NSObject(MVCExtension)

-(void) connect:(SEL)method toSignal:(NSString*)signal from:(NSObject*)caster {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:method
                                                 name:signal
                                               object:caster];
    
    /*
     Be sure to invoke removeObserver:name:object: before notificationObserver or any object specified in addObserver:selector:name:object: is deallocated.
     */
}

-(void) disconnect:(NSString*)signalName {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:signalName object:nil];
}

-(void) disconnectionCompletely {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) emmit:(NSString*)signalName withData:(NSDictionary*)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:signalName object:self userInfo:data];
}

@end

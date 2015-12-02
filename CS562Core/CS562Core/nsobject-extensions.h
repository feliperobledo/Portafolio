//
//  nsobject-extensions.h
//  CS562Core
//
//  Created by Felipe Robledo on 9/13/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#ifndef CS562Core_nsobject_extensions_h
#define CS562Core_nsobject_extensions_h

#import <Foundation/Foundation.h>

@interface NSObject (MVCExtension)

@property (strong,atomic) NSMutableDictionary* _aliases;

// Connect self to a signal from another object
-(void) connect:(SEL)method toSignal:(NSString*)signal from:(NSObject*)caster;

// Remove this connector from that signal
-(void) disconnect:(NSString*)signalName;

// Remove this connector from all signals it has been attached to
-(void) disconnectionCompletely;

// Have this connector emit a signal with specific data
-(void) emmit:(NSString*)signalName withData:(NSDictionary*)data;

-(BOOL) couldProperBeSetWithSpecialSetter:(NSString*)propName withData:(NSObject*)data;

@end 

#endif

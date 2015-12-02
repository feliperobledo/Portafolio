//
//  Skydome.h
//  CS562
//
//  Created by Felipe Robledo on 11/18/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>

@interface Skydome : IView

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

-(GLuint) getTargetHandle;
-(CGSize) getSize;
-(void) bindForWriting:(GLenum)textureTarget;
-(void) bindForReading;

@end

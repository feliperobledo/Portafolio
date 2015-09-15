//
//  MeshStore.h
//  CS562
//
//  Created by Felipe Robledo on 9/14/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>

typedef uint32 MeshID;

@interface MeshStore : IModel

@property NSArray* meshObjFiles;
@property (strong,nonatomic) NSMutableDictionary* filenameToIdMap;
@property (strong,nonatomic) NSMutableDictionary* meshData;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;
-(void) postInit;

@end

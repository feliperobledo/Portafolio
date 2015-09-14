//
//  EntityCreator.h
//  CS562Core
//
//  Created by Felipe Robledo on 8/28/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Entity;

#define CHUNK_SIZE 10
#define INVALID_ID 0

@interface EntityCreator : NSObject
{
    @private;
    
    // 64 bit identifiers for objects.
    // Upper 32 bits are Version Number. Lower 32 bits are Identifier Number.
    uint64 _idCounter;
    
}

// An array to arrays. Each entry has CHUNK_SIZE elements
@property (nonatomic, retain, strong) NSMutableArray* _objectTable;
// An array of unsigned long NSNumbers. 
@property (nonatomic, retain, strong) NSMutableArray* _freeList;

-(id) init;
-(uint64) newEmptyEntity:(Entity*)parent;
-(uint64) newEntity:(Entity*)parent fromJSONFile:(NSData*)fileData;

//------------------------------------------------------------------------------

-(Entity*) getEntity:(uint64)entityID;
-(NSException*) destroyEntity:(uint64)entityID;

//------------------------------------------------------------------------------

// Use upper 32 bits for id version
+(uint32) getObjectIdVersion:(Entity*)obj;

// Use lower 32 bits for index
+(uint32) getObjectIdIndex:(Entity*)obj;

+(uint32) getVersionFromID:(uint64)ID;
+(uint32) getIndexFromID:(uint64)ID;

@end


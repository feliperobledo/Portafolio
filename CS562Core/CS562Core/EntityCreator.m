//
//  EntityCreator.m
//  CS562Core
//
//  Created by Felipe Robledo on 8/29/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EntityCreator.h>
#import <Entity.h>

@implementation EntityCreator

@synthesize _freeList    = FreeList;
@synthesize _objectTable = OTable;

-(uint64) newEmptyEntity:(Entity*)parent {
    Entity* newEntity = nil;
    
    // there are no free id's to re-use, make more
    if([FreeList count] == 0) {
        NSMutableArray* chunk = [[NSMutableArray alloc] initWithCapacity:CHUNK_SIZE];
        for(int i = CHUNK_SIZE - 1; i >= 0; --i) {
            NSNumber* newID = [[NSNumber alloc] initWithLongLong:([OTable count] * CHUNK_SIZE + i)];
            newEntity = [[Entity alloc] initWithId:[newID longLongValue] andParent:parent];
            
            [chunk setObject:newEntity atIndexedSubscript:i];
            [FreeList addObject:newID];
        }
        [OTable addObject:chunk];
    }
    
    NSNumber* freeID = (NSNumber*)[FreeList objectAtIndex:[FreeList count] - 1];
    [FreeList removeObjectAtIndex:[FreeList count] - 1];
    
    //will use lower bits by using unsignedIntegerValue
    NSMutableArray* chunk = [OTable objectAtIndex:([freeID unsignedIntegerValue] / CHUNK_SIZE)];
    newEntity = (Entity*)[chunk objectAtIndex:[freeID unsignedIntegerValue] % CHUNK_SIZE];
    return [newEntity getID];
}

-(uint64) newEntity:(Entity*)parent fromJSONFile:(NSString*)filename {
    uint64 entityID = [self newEmptyEntity:parent];
    
    // .. do serialization calls here...
    
    return entityID;
}

//------------------------------------------------------------------------------

-(Entity*) getEntity:(uint64)entityID {
    uint32 entityIndex = [EntityCreator  getIndexFromID:entityID];
    
    NSMutableArray* chunk = [OTable objectAtIndex:(entityIndex / CHUNK_SIZE)];
    Entity* entity = (Entity*)[chunk objectAtIndex:(entityIndex % CHUNK_SIZE)];
    return [entity getID] != entityID ? nil: entity;
}

-(NSException*) destroyEntity:(uint64)entityID {
    Entity* entity = [self getEntity:entityID];
    if(entity == nil) {
       return [[NSException alloc] initWithName:@"DestroyEntityError" reason:@"May not destroy an Entity with an ID that does not exist." userInfo:nil];
    }
    
    uint64 newID = (entityID & 0xFFFFFFFF) | (((entityID >> 32) + 1) << 32);
    [entity setID:newID];
    [FreeList addObject:[[NSNumber alloc] initWithLongLong:newID]];
    
    return nil;
}

//------------------------------------------------------------------------------

// Use upper 32 bits for id version
+(uint32) getObjectIdVersion:(Entity*)obj {
    uint64 objID = [obj getID];
    return [EntityCreator getVersionFromID:objID];
}

// Use lower 32 bits for index
+(uint32) getObjectIdIndex:(Entity*)obj {
    uint64 objID = [obj getID];
    return [EntityCreator getIndexFromID:objID];
}

+(uint32) getVersionFromID:(uint64)ID {
    return (uint32)(ID >> 32);
}

+(uint32) getIndexFromID:(uint64)ID {
    return (uint32)(ID & 0xFFFFFFFF);
}

@end 

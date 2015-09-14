//
//  EntityCreator.m
//  CS562Core
//
//  Created by Felipe Robledo on 8/29/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <EntityCreator.h>
#import <Entity.h>
#import <Connector.h>
#import <malloc/malloc.h>

@implementation EntityCreator

@synthesize _freeList    = FreeList;
@synthesize _objectTable = OTable;

-(id) init {
    if (self == [super init]) {
        OTable = [[NSMutableArray alloc] init];
        FreeList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(uint64) newEmptyEntity:(Entity*)parent {
    Entity* newEntity = nil;
    
    // there are no free id's to re-use, make more
    if([FreeList count] == 0) {
        NSMutableArray* chunk = [[NSMutableArray alloc] initWithCapacity:CHUNK_SIZE];
        
        // adds new objects into the object list in reverse order of IDs
        for(unsigned i = 0; i < CHUNK_SIZE; ++i) {
            // We add 1 as a constant so id is never 0, which stands for INVALID_ID
            unsigned long t = [OTable count] * CHUNK_SIZE + i + 1;
            
            NSNumber* newID = [[NSNumber alloc] initWithUnsignedLong:t];
            
            newEntity = [[Entity alloc] initWithId:[newID unsignedLongValue] andParent:parent];
            
            [chunk addObject:newEntity];
            
            [FreeList addObject:newID];
        }
        
        [OTable addObject:chunk];
    }
    
    NSNumber* freeID = (NSNumber*)[FreeList objectAtIndex:[FreeList count] - 1];
    [FreeList removeObjectAtIndex:[FreeList count] - 1];
    
    newEntity = [self getEntity:[freeID unsignedLongValue]];
    
    return [newEntity getID] == [freeID unsignedLongValue] ? [freeID unsignedLongValue] : INVALID_ID;
}

-(uint64) newEntity:(Entity*)parent fromJSONFile:(NSData*)fileData {
    NSError* err = [NSError alloc];
    id obj = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&err];

    if (obj == nil) {
        NSLog(@"FileError: %@", [err localizedDescription]);
        return INVALID_ID;
    }
    
    if ([obj isKindOfClass:[NSDictionary class]] == NO) {
        NSLog(@"ERROR: Serialization files can only be dictionary objects");
        return INVALID_ID;
    }
    
    uint64 entityID = [self newEmptyEntity:parent];
    if (entityID == INVALID_ID) {
        NSLog(@"Could not create new empty Entity or there are no free ones.");
        return INVALID_ID;
    }
    
    Entity* entity = [self getEntity:entityID];
    NSDictionary* dict = (NSDictionary*)obj;
    [self serializeEntity:entity fromDictionary:dict];
    
    return entityID;
}

-(Entity*) newEntity:(Entity*)parent fromDict:(NSDictionary*)dict{
    uint64 entityID = [self newEmptyEntity:parent];
    if (entityID == INVALID_ID) {
        NSLog(@"Could not create a new empty entity or there are no free IDs");
        return nil;
    }
    
    Entity* entity = [self getEntity:entityID];
    if (entity == nil) {
        NSLog(@"Error finding entity for known ID. [EntityCreator getEntity] may be broken.");
        return nil;
    }
    
    [self serializeEntity:entity fromDictionary:dict];
    
    return entity;
}

-(void) serializeEntity:(Entity*)entity fromDictionary:(NSDictionary*)dict {
    for(NSString* key in dict) {
        if([key isEqualToString:@"Name"]) {
            
            [entity setName:[dict objectForKey:key]];
            
        } else if([key isEqualToString:@"Children"]) {
            
            // Add all children from here
            NSArray* children = (NSArray*)[dict objectForKey:key];
            for(NSDictionary* childData in children) {
                
                Entity* child = [self newEntity:entity fromDict:childData];
                if (child == nil) {
                    return;
                }
                
                [entity addChild:child];
            }
            
        } else {
            
            // key at this point is either Models, Controllers or Views
            NSDictionary* components = (NSDictionary*)[dict objectForKey:key];
            for(NSString* componentClassName in components) {
                // Get the class object from the current model, controller or view
                Class componentClass = objc_getClass([componentClassName UTF8String]);
                NSDictionary* componentData = [components objectForKey:componentClassName];
                
                id component = [[componentClass alloc] init];
                
                // Get all properties from current model, controller or view
                unsigned int count = 0;
                objc_property_t* propertyArray = class_copyPropertyList(componentClass, &count);
                
                for(int i = 0; i < count; ++i) {
                    objc_property_t prop = propertyArray[i];
                    
                    NSString* propName = [[NSString alloc] initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding] ;
                    
                    id data = [componentData valueForKey:propName];
                    if (data == nil) {
                        continue;
                    }
                    
                    [component setValue:data forKey:propName];
                }
                
                free(propertyArray);
                
                if([key isEqualToString:@"Models"]) {
                    [entity addModel:(IModel*)component];
                } else if([key isEqualToString:@"Views"]) {
                    [entity addView:(IView*)component];
                } else if([key isEqualToString:@"Controllers"]) {
                    [entity addController:(IController*)component];
                } else {
                    NSCAssert(false, @"ERROR: Name is not ");
                }

            }

        }
    }
}

//------------------------------------------------------------------------------

-(Entity*) getEntity:(uint64)entityID {
    uint32 entityIndex = [EntityCreator getIndexFromID:entityID];
    uint32 modifiedIndex = entityIndex - 1;
    
    NSMutableArray* chunk = [OTable objectAtIndex:(modifiedIndex / CHUNK_SIZE)];
    Entity* entity = (Entity*)[chunk objectAtIndex:(modifiedIndex % CHUNK_SIZE)];
    return [entity getID] != entityID ? nil: entity;
}

-(NSException*) destroyEntity:(uint64)entityID {
    Entity* entity = [self getEntity:entityID];
    
    if(entity == nil) {
       return [[NSException alloc] initWithName:@"DestroyEntityError" reason:@"May not destroy an Entity with an ID that does not exist." userInfo:nil];
    }
    
    // keeps index in lower bits but increases entity version
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

//
//  EntityCreatorTests.m
//  CS562Core
//
//  Created by Felipe Robledo on 8/29/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EntityCreator.h"
#import "Entity.h"
#import "SampleModel1.h"

@interface EntityCreatorTests : XCTestCase

@end

@implementation EntityCreatorTests

-(void) testThatEntityForIDCanBeObtained {
    EntityCreator* eCreator = [[EntityCreator alloc] init];
    
    uint64 ID = [eCreator newEmptyEntity:nil];
    XCTAssertNotNil([eCreator getEntity:ID],@"Cannot get Entity for real ID.");
}

-(void) testThatAllIDsAreUnique {
    EntityCreator* eCreator = [[EntityCreator alloc] init];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    for(int i = 0; i < 1000; ++i) {
        NSNumber* newEntityID = [NSNumber numberWithUnsignedLongLong:[eCreator newEmptyEntity:nil]];
        
        XCTAssertNotEqual([newEntityID unsignedLongValue], 0, @"Could not create a new entity");
        
        XCTAssertNil([dic objectForKey:newEntityID],
                     @"Entity with this key already exists");
            
        
        Entity* entity = [eCreator getEntity:[newEntityID unsignedLongLongValue]];
        XCTAssertNotNil(entity,@"Can't find Entity based on returned key");
        
        [dic setObject:entity forKey:newEntityID];
    }
    
    NSLog(@"PASS");
}

-(void) testThatFreeListIsEmptyIfAllEntitiesInUse {
    EntityCreator* eCreator = [[EntityCreator alloc] init];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    for(int i = 0; i < CHUNK_SIZE; ++i) {
        NSNumber* newEntityID = [NSNumber numberWithUnsignedLongLong:[eCreator newEmptyEntity:nil]];
        
        XCTAssertNil([dic objectForKey:newEntityID],
                     @"Entity with this key already exists");
        
        
        Entity* entity = [eCreator getEntity:[newEntityID unsignedLongLongValue]];
        XCTAssertNotNil(entity,@"Can't find Entity based on returned key");
        
        [dic setObject:entity forKey:newEntityID];
    }
    
    XCTAssertEqual([[eCreator _freeList] count], 0, @"ERROR: Free list is not supposed to have free IDs for use");
}

-(void) testThatDeadEntityCannotBeObtained {
    EntityCreator* eCreator = [[EntityCreator alloc] init];
    
    uint64 ID = [eCreator newEmptyEntity:nil];
    XCTAssertNotNil([eCreator getEntity:ID],@"ERROR! Entity creation code is broken. Entity for specified id does not exist");
    
    [eCreator destroyEntity:ID];
    XCTAssertNil([eCreator getEntity:ID],@"ERROR! Entity is not properly destroyed");
}

-(void) testThatEntityIsSerializedCorrectly {
    EntityCreator* eCreator = [[EntityCreator alloc] init];
    
    // global call to create special settors
    [SampleModel1 addSpecialSettors];
    
    // Need to acquire a file in a test in the following way
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:@"Data" ofType:@"json"];
    NSData* objData = [NSData dataWithContentsOfFile:path];
    
    uint64 entityID = [eCreator newEntity:nil fromJSONFile:objData];
    XCTAssertNotEqual(entityID,0,@"ERROR: Entity not properly serialized from json file");
    
    // Get the dictionary we used to serialize the new entity
    NSError* err = [NSError alloc];
    id obj = [NSJSONSerialization JSONObjectWithData:objData options:NSJSONReadingAllowFragments error:&err];
    
    Entity* entity = [eCreator getEntity:entityID];
    XCTAssertNotNil(entity,@"ERROR: Entity not found for created id.");
    
    [self checkEntity:entity equalDictionary:obj];
}

// -----------------------------------------------------------------------------
//                                  HELPERS
// -----------------------------------------------------------------------------

-(void)checkEntity:(Entity*)entity equalDictionary:(NSDictionary*)dict {
    for(NSString* key in dict) {
        if([key isEqualToString:@"Name"]) {
            
            NSString *entityName = [entity _name],
                     *nameInData = [dict valueForKey:key];
            XCTAssertEqual(entityName, nameInData,@"ERROR: Name disparity");
            
        } else if([key isEqualToString:@"Children"]) {
            
            // Add all children from here
            NSArray* childrenData = (NSArray*)[dict objectForKey:key];
            NSArray* children = [entity _children];
            for(int i = 0; i < [children count]; ++i) {
                Entity* e = [children objectAtIndex:i];
                NSDictionary* data = [childrenData objectAtIndex:i];
                
                [self checkEntity:e equalDictionary:data];
            }
            
        } else {

            NSDictionary* components = (NSDictionary*)[dict objectForKey:key];
            for(NSString* componentClassName in components) {
                
                // Get the component form the entity we need to verify
                id entityComponent = nil;
                if ([key isEqualToString:@"Models"]) {
                    
                    entityComponent = [entity getModelWithName:componentClassName];
                    
                } else if ([key isEqualToString:@"Views"]) {
                    
                    entityComponent = [entity getViewWithName:componentClassName];
                    
                } else {
                    
                    entityComponent = [entity getControllerName:componentClassName];
                    
                }
                
                // Get the data for the component
                NSDictionary* componentClassData = [components valueForKey:componentClassName];
                
                for (NSString* memberName in componentClassData) {
                    id member = [componentClassData valueForKey:memberName];
                    
                    id entityData = [entityComponent valueForKey:memberName];
                    
                    Class dataClass = [member class];
                    if (![entityData isKindOfClass:dataClass]) {
                        XCTAssert(NO,@"The two members should have the same class type");
                        continue;
                    }
                    
                    NSObject *t1 = (NSObject*)member,
                             *t2 = (NSObject*)entityData;
                    
                    XCTAssert([t1 isEqual:t2],@"Values are not the same!");
                        
                }
                
            }
        }
    }
}

@end

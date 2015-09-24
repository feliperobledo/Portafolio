//
//  MeshLoadTimes.m
//  CS562
//
//  Created by Felipe Robledo on 9/14/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "MeshStore.h"

@interface MeshLoadTimes : XCTestCase

@end

@implementation MeshLoadTimes

- (void)testBunnyLoadTime {
    MeshStore* newStore = [[MeshStore alloc] init];
    
    NSMutableDictionary* entry =[[NSMutableDictionary alloc] init];
    [entry setValue:@"bunny" forKey:@"Name"];
    [entry setValue:@"obj" forKey:@"Type"];
    
    NSArray* meshFiles = [[NSArray alloc] initWithObjects:entry, nil];
    [newStore setMeshObjFiles:meshFiles];
    
    [self measureBlock:^{
        [newStore loadAllMeshDataCreateHalfEdgeMesh];
    }];
}

- (void)testHorseLoadTime {
    MeshStore* newStore = [[MeshStore alloc] init];
    
    NSMutableDictionary* entry =[[NSMutableDictionary alloc] init];
    [entry setValue:@"horse" forKey:@"Name"];
    [entry setValue:@"obj" forKey:@"Type"];
    
    NSArray* meshFiles = [[NSArray alloc] initWithObjects:entry, nil];
    [newStore setMeshObjFiles:meshFiles];
    
    [self measureBlock:^{
        [newStore loadAllMeshDataCreateHalfEdgeMesh];
    }];
}

- (void)testDragonLoadTime {
    MeshStore* newStore = [[MeshStore alloc] init];
    
    NSMutableDictionary* entry =[[NSMutableDictionary alloc] init];
    [entry setValue:@"dragon" forKey:@"Name"];
    [entry setValue:@"obj" forKey:@"Type"];
    
    NSArray* meshFiles = [[NSArray alloc] initWithObjects:entry, nil];
    [newStore setMeshObjFiles:meshFiles];
    
    [self measureBlock:^{
        [newStore loadAllMeshDataCreateHalfEdgeMesh];
    }];
}
@end

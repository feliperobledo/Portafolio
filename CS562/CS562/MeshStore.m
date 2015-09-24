//
//  MeshStore.m
//  CS562
//
//  Created by Felipe Robledo on 9/14/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "MeshStore.h"
#import "Mesh.h"

@implementation MeshStore

-(id) init {
    if((self = [super init])) {
        //_meshObjFiles    = [[NSArray alloc] init];
        _filenameToIdMap = [[NSMutableDictionary alloc] init];
        _meshData        = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if((self = [super initWithOwner:owner])) {
        
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
    if ([self loadAllMeshDataCreateHalfEdgeMesh] == false) {
        return;
    }
    
    [self submitMeshDataToOpenGL];
}

-(BOOL) loadAllMeshDataCreateHalfEdgeMesh {
    // For every filename in our array, we are going to create all our meshes
    MeshID meshCount = 0;
    for (NSDictionary* fileData in [self meshObjFiles]) {
        Mesh* newMesh = [[Mesh alloc] initWithOwner:nil];
        
        NSString *filename = [fileData valueForKey:@"Name"],
                 *type     = [fileData valueForKey:@"Type"];
        
        NSBundle* bundle = [NSBundle bundleForClass:[self class]];
        NSString* path = [bundle pathForResource:filename ofType:type];
        NSData* objData = [NSData dataWithContentsOfFile:path];
        
        BOOL success = [newMesh createMeshDataFromFile:objData];
        if (!success) {
            NSLog(@"ERROR! Mesh from file %s could not be loaded",[path UTF8String]);
            return false;
        }
        
        NSString* fullFileName = [[NSString alloc] initWithString:[filename stringByAppendingString:type]];
        
        [newMesh setSourceFile:fullFileName];
        
        NSNumber* temp = [[NSNumber alloc] initWithUnsignedInt:meshCount];
        NSString* meshID = [[NSString alloc] initWithString:[temp stringValue]];
        
        [self.filenameToIdMap setObject:meshID  forKey:filename];
        [self.meshData        setObject:newMesh forKey:meshID];
        NSLog(@"SUCCESS: loaded mesh for %s", [fullFileName UTF8String]);
        meshCount++;
    }
    return true;
}

-(void) submitMeshDataToOpenGL {
    for (NSString* filename in [self filenameToIdMap]) {
        
        NSString* meshID = [_filenameToIdMap valueForKey:filename];
        Mesh* mesh = [_meshData valueForKey:meshID];
        
        [mesh createOpenGLInformation];
    }
}

@end

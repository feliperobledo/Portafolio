//
//  MeshStore.m
//  CS562
//
//  Created by Felipe Robledo on 9/14/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "MeshStore.h"
#import "Mesh.h"

struct Vertex3D {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector3 tangent;
    GLKVector3 bitangent;
    GLKVector2 texture;
    GLKVector4 color;
};

@interface MeshStore(PrivateMethods)
-(void) submitMeshDataToOpenGL;

-(NSString*) createMeshID:(MeshID)n;

// Creating own meshes
-(Mesh*) CreateSphereWitRadius:(float)radius slices:(unsigned)sliceCount stacks:(unsigned)stackCount;
-(Mesh*) CreateGeoSphere:(float)radius subDivisions:(unsigned)numSubdivisions;
@end

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

-(Mesh*)getMeshFromName:(NSString*)meshSource {
    NSString* ID = [_filenameToIdMap valueForKey:meshSource];
    return [_meshData valueForKey:ID];
}

-(BOOL) loadAllMeshDataCreateHalfEdgeMesh {
    // For every filename in our array, we are going to create all our meshes
    MeshID meshCount = 0;
    BOOL saveVertexNormals = NO;
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
        
        NSString* meshID = [self createMeshID:meshCount];
        
        filename = [filename stringByAppendingString:@"."];
        filename = [filename stringByAppendingString:type];
        
        [self.filenameToIdMap setObject:meshID  forKey:filename];
        [self.meshData        setObject:newMesh forKey:meshID];
        
        if(saveVertexNormals) {
            filename = [filename stringByAppendingString:@".normals"];
            [newMesh saveVertexNormalsToFile:filename];
        }
        
        NSLog(@"SUCCESS: loaded mesh for %s", [fullFileName UTF8String]);
        meshCount++;
    }
    
    // Create the skybox mesh by code
    Mesh* skybox = [self CreateSphereWitRadius:200.0f slices:10 stacks:10];
    //Mesh* skybox = [self getMeshFromName:@"sphere.obj"];
    NSString* name = @"skybox";
    NSString* skyBoxID = [self createMeshID:meshCount];
    
    [self.filenameToIdMap setObject:skyBoxID  forKey:name];
    [self.meshData        setObject:skybox forKey:skyBoxID];
    
    return true;
}

-(NSString*) createMeshID:(MeshID)n {
    NSNumber* temp = [[NSNumber alloc] initWithUnsignedInt:n];
    return[[NSString alloc] initWithString:[temp stringValue]];
}

-(void) submitMeshDataToOpenGL {
    for (NSString* filename in [self filenameToIdMap]) {
        
        NSString* meshID = [_filenameToIdMap valueForKey:filename];
        Mesh* mesh = [_meshData valueForKey:meshID];
        
        [mesh createOpenGLInformation];
    }
}

-(Mesh*) CreateSphereWitRadius:(float)radius slices:(unsigned)sliceCount stacks:(unsigned)stackCount {
    const float pi = 3.1415926;
    
    NSMutableArray *vertices = [[NSMutableArray alloc] init],
                   *indices  = [[NSMutableArray alloc] init];
    
    //
    // Compute the vertices stating at the top pole and moving down the stacks.
    //
    
    // Poles: note that there will be texture coordinate distortion as there is
    // not a unique point on the texture map to assign to the pole when mapping
    // a rectangular texture onto a sphere.
    Vertex topVertex3D = { {0.0f, +radius, 0.0f} ,      // pos
                                    {0.0f, +1.0f, 0.0f},         // normal
                                    {1.0f, 1.0f, 1.0f, 1.0f},    // WHITE
                                    {1.0f, 0.0f, 0.0f},          // tangent
                                    {0.0f, 0.0f, 0.0f},          // bitangent
                                    {0.0f, 0.0f} };                // uv
    
    Vertex bottomVertex3D = {  {0.0f, -radius, 0.0f},
                                        {0.0f, -1.0f, 0.0f},
                                        {0.0f, 0.0f, 0.0f, 0.0f},
                                        {1.0f, 0.0f, 0.0f},
                                        {0.0f, 0.0f, 0.0f},
                                        {0.0f, 1.0f}};//BLACK
    
    //ModelData.Vertices.push_back(topVertex3D);
    [vertices addObject:[NSValue valueWithPointer:&topVertex3D]];
    
    float phiStep = pi / (float)stackCount;
    float thetaStep = 2.0f * pi/ (float)sliceCount;
    

    GLKVector4 colorIncrement = GLKVector4MultiplyScalar(
                                  GLKVector4Subtract(bottomVertex3D.color,topVertex3D.color),
                                  1.0f/(float)sliceCount
                                );
    
    GLKVector4 ringcolor = GLKVector4Add(topVertex3D.color, colorIncrement);
    
    // Compute vertices for each stack ring (do not count the poles as rings).
    for (unsigned i = 1; i <= stackCount - 1; ++i)
    {
        float phi = i*phiStep;
        
        ringcolor = GLKVector4Add(ringcolor, colorIncrement);
        
        // Vertices of ring.
        for (unsigned j = 0; j <= sliceCount; ++j)
        {
            float theta = j*thetaStep;
            
            Vertex *v = (Vertex*)malloc(sizeof(Vertex));
            
            v->color = ringcolor;
            
            // spherical to cartesian
            v->pos.x = radius*sinf(phi)*cosf(theta);
            v->pos.y = radius*cosf(phi);
            v->pos.z = radius*sinf(phi)*sinf(theta);
            
            // Partial derivative of P with respect to theta
            v->tangent.x = -radius*sinf(phi)*sinf(theta);
            v->tangent.y = 0.0f;
            v->tangent.z = +radius*sinf(phi)*cosf(theta);
            
            GLKVector3Normalize(v->tangent);
            
            GLKVector3 p = v->pos;
            GLKVector3Normalize(p);
            v->normal = p;
            
            v->texture.x = theta / (2 * pi);
            v->texture.y = phi / pi;
            
            [vertices addObject:[NSValue valueWithPointer:v]];
        }
    }
    
    [vertices addObject:[NSValue valueWithPointer:&bottomVertex3D]];
    
    //
    // Compute indices for top stack.  The top stack was written first to the Vertex3D buffer
    // and connects the top pole to the first ring.
    //
    
    for (unsigned i = 1; i <= sliceCount; ++i)
    {
        [indices addObject:[[NSNumber alloc] initWithInt:0]];
        [indices addObject:[[NSNumber alloc] initWithInt:i+1]];
        [indices addObject:[[NSNumber alloc] initWithInt:i]];
    }
    
    //
    // Compute indices for inner stacks (not connected to poles).
    //
    
    // Offset the indices to the index of the first Vertex3D in the first ring.
    // This is just skipping the top pole Vertex3D.
    unsigned long baseIndex = 1;
    unsigned long ringVertex3DCount = sliceCount + 1;
    for (unsigned long i = 0; i < stackCount - 2; ++i)
    {
        for (unsigned long j = 0; j < sliceCount; ++j)
        {
            [indices addObject:[[NSNumber alloc] initWithInt:baseIndex + i*ringVertex3DCount + j]];
            [indices addObject:[[NSNumber alloc] initWithInt:baseIndex + i*ringVertex3DCount + j + 1]];
            [indices addObject:[[NSNumber alloc] initWithInt:baseIndex + (i + 1)*ringVertex3DCount + j]];
            
            
            [indices addObject:[[NSNumber alloc] initWithInt:baseIndex + (i + 1)*ringVertex3DCount + j]];
            [indices addObject:[[NSNumber alloc] initWithInt:baseIndex + i*ringVertex3DCount + j + 1]];
            [indices addObject:[[NSNumber alloc] initWithInt:baseIndex + (i + 1)*ringVertex3DCount + j + 1]];
        }
    }
    
    //
    // Compute indices for bottom stack.  The bottom stack was written last to the Vertex3D buffer
    // and connects the bottom pole to the bottom ring.
    //
    
    // South pole Vertex3D was added last.
    unsigned long southPoleIndex = [vertices count] - 1;
    
    // Offset the indices to the index of the first Vertex3D in the last ring.
    baseIndex = southPoleIndex - ringVertex3DCount;
    
    for (unsigned i = 0; i < sliceCount; ++i)
    {
        [indices addObject:[[NSNumber alloc] initWithInt:southPoleIndex]];
        [indices addObject:[[NSNumber alloc] initWithInt:baseIndex + i]];
        [indices addObject:[[NSNumber alloc] initWithInt:baseIndex + i + 1]];
    }
    
    return [[Mesh alloc] initWithVertices:vertices andFaces:indices];
}

-(Mesh*) CreateGeoSphere:(float)radius subDivisions:(unsigned)numSubdivisions {
    return nil;
}

@end

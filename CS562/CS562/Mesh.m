/*Start Header------------------------------------------------------------
 Copyright(C) 2013 DigiPen Institute of Technology Reproduction or
 disclosure of this file or its contents without the prior written
 consent of DigiPen Institute of Technology is prohibited.
 File Name: Wavefront.h
 Purpose: An object that holds all data for a wavefront file. The data
 should all be deallocated after sent to the GPU
 Platform: Mac OX X Version 10.9.5
 ms2012 (Compiler)
 Processor: Intel(R) Core(TM) i5 @ 2.40Hz
 Type: 64-bit OS
 RAM: 8 GB
 Hard-Drive: 250GB SSD
 Project: f.robledo_CS300_1
 Author: Felipe Robledo, f.robledo, 80002511
 Creation Date: 09/27/2014
 -End Header-------------------------------------------------------------*/

#import "Mesh.h"

@implementation Mesh

-(id) init {
    if ((self = [super init])) {
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if ((self = [super initWithOwner:owner])) {
        
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

// -----------------------------------------------------------------------------

-(void) placeIndicesFrom:(NSArray*)textData Into:(NSMutableArray*)container
{
    //Retrieve the data from the object file
    short currVertIndex = 0;
    for(NSString* currFace in textData)
    {
        if([currFace containsString:@"/"])
        {
            NSArray* faceparts = [currFace componentsSeparatedByString:@"/"];
            
            //Use the range of // to figure out
            NSRange range = [currFace rangeOfString:@"//"];
            bool hasTextureIndex = range.length == 0;
            
            //Place the data in the corresponding index of the position array
            NSNumber* vertIndex = [NSNumber numberWithInt:[[faceparts objectAtIndex:0] integerValue] - 1];
            [container addObject:vertIndex];
            
            //If we found a texture
            if(hasTextureIndex)
            {
                //store texture coordinates
            }
        }
        else
        {
            NSNumber* vertIndex = [NSNumber numberWithInt:[currFace integerValue] - 1];
            [container addObject:vertIndex];
        }
    }
}

-(NSString*) createMetaNameFromVert:(NSString*)v0 ToVert:(NSString*)v1
{
    const char* prefix  = "E";
    const char* divider = ":";
    
    NSString* meta = [[NSString alloc] init];
    meta = [meta stringByAppendingString:[NSString stringWithUTF8String:prefix]];
    meta = [meta stringByAppendingString:v0];
    meta = [meta stringByAppendingString:[NSString stringWithUTF8String:divider]];
    meta = [meta stringByAppendingString:v1];
    
    return meta;
}

-(NSMutableArray*) createMetaNamesForIndices:(NSMutableArray*)numberIndices
{
    //given numberIndices, create Fx:y, Fy:z, and Fz:x meta string names
    NSNumber* v0 = [numberIndices objectAtIndex:0];
    NSNumber* v1 = [numberIndices objectAtIndex:1];
    NSNumber* v2 = [numberIndices objectAtIndex:2];
    
    NSString* first  = [v0 stringValue];
    NSString* second = [v1 stringValue];
    NSString* third  = [v2 stringValue];
    
    //A name consists by prefix + NSString1 + divider + NSString2
    NSString* firstToSecond = [self createMetaNameFromVert:first ToVert:second];
    NSString* secondToThird = [self createMetaNameFromVert:second ToVert:third];
    NSString* thirdToFirst  = [self createMetaNameFromVert:third ToVert:first];
    
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    [ret addObject:firstToSecond];
    [ret addObject:secondToThird];
    [ret addObject:thirdToFirst];
    
    return ret;
}

-(HalfEdge*)createHalfEdgeFromMeta:(NSString*)halfEdgeMetaName fromEdgeMem:(HalfEdge*)newHalfEdge fromVertMem:(Vertex*)vertexMem
{
    //Set the twin pointer for both half edges. The newHalfEdge twin is next to it in memory
    HalfEdge* twin = newHalfEdge + 1;
    newHalfEdge->twin = twin;
    twin->twin = newHalfEdge;
    
    //indices:           0    1    2   3
    //meta name format:  E    x    :   y
    //Extract the vertex indices form the meta name
    int fromIndex = [[halfEdgeMetaName substringWithRange:NSMakeRange(1, 1)] integerValue];
    int toIndex   = [[halfEdgeMetaName substringWithRange:NSMakeRange(3, 3)] integerValue];
    
    //Init half-edge with the vertex it goes to
    //Set start index's out edge if it has not been set
    if(newHalfEdge->to == NULL)
    {
        newHalfEdge->to = &vertexMem[toIndex];
        if(vertexMem[fromIndex].outEdge == NULL)
        {
            vertexMem[fromIndex].outEdge = newHalfEdge;
        }
    }
    
    //set up the half edge's twin
    if(twin->to == NULL)
    {
        twin->to = &vertexMem[fromIndex];
        if(vertexMem[toIndex].outEdge == NULL)
        {
           vertexMem[toIndex].outEdge = twin;
        }
    }
    
    return newHalfEdge;
}

-(void) halfEdge:(HalfEdge*)v1 pointsTo:(HalfEdge*)v2
{
    v1->next = v2;
    v2->twin->next = v1->twin;
}

-(BOOL) initWithFile:(NSString*)filename
{
    //open the file
    self.m_VertCount = 0;
    self.m_FaceCount = 0;
    self.modelFileName = [[NSString alloc] initWithString:filename];
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:filename
                                                           ofType:@".obj"];
    NSData* objData = [NSData dataWithContentsOfFile:modelPath];
    if(objData)
    {
        //Create an array of string, each index being a line in the file
        NSString* file = [[NSString alloc] initWithData:objData encoding:NSUTF8StringEncoding];
        NSArray *lines = [file componentsSeparatedByString:@"\n"];
        self.halfEdgeDictionary = [[NSMutableDictionary alloc]init];
        
        //We want locality of reference for all data, so we parse once in order
        //to know how many faces and vertices should be allocated.
        for(NSString * line in lines)
        {
            if ([line hasPrefix:@"v"])
            {
                ++self.m_VertCount;
            }
            else if([line hasPrefix:@"f"])
            {
                ++self.m_FaceCount;
            }
        }
        
        Vertex* vertexData = (Vertex*)malloc(sizeof(Vertex) * self.m_VertCount);
        self.vertNormals = (GLKVector3*)malloc(sizeof(GLKVector3) * self.m_VertCount);
        NSAssert(vertexData != NULL, @"Ran out of memory. Too many VERTICES in model or OS fault");
        memset(vertexData, 0, sizeof(Vertex) * self.m_VertCount);
        
        Face* faceData = (Face*)malloc(sizeof(Face) * self.m_FaceCount);
        NSAssert(faceData != NULL, @"Ran out of memory. Too many FACES in model or OS fault");
        memset(faceData, 0, sizeof(Face) * self.m_FaceCount);
        
        GLuint edgesCount = self.m_FaceCount * 3;
        GLuint halfEdgesCount = self.m_HalfEdgeCount = edgesCount * 2;
        GLuint halfEdgeArrayByteSize = sizeof(HalfEdge) * halfEdgesCount;
        HalfEdge* halfEdges = (HalfEdge*)malloc(halfEdgeArrayByteSize);
        NSAssert(halfEdges != NULL, @"Ran out of memory. Too many EDGES in model or OS fault");
        memset(halfEdges, 0, halfEdgeArrayByteSize);
        
        int vertexIndex = 0, faceIndex = 0, halfEdgeIndex = 0;
        for(NSString * line in lines)
        {
            if ([line hasPrefix:@"v"])
            {
                GLKVector3* position = &(vertexData + vertexIndex)->pos;
                
                //Get a new string that starts after the prefix
                NSString *lineTrunc = [line substringFromIndex:2];
                
                //Convert line into an array of 3 entries, one for each element of the vertex
                NSArray *lineVertices = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                position[vertexIndex].x = [[lineVertices objectAtIndex:0] floatValue];
                position[vertexIndex].y = [[lineVertices objectAtIndex:1] floatValue];
                position[vertexIndex].z = [[lineVertices objectAtIndex:2] floatValue];
                ++vertexIndex;
            }
            else if([line hasPrefix:@"f"]) // we will now create the half edges
            {
                //Get a new string that starts after the prefix
                NSString* truncLine = [line substringFromIndex:2];
                
                //Convert line into an array of 3 entries, one for each element of the face
                NSArray* data = [truncLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                NSMutableArray* objFileVertIndices = [[NSMutableArray alloc]init];
                [self placeIndicesFrom:data Into:objFileVertIndices];
                
                //Store the meta names of the current Edges
                NSMutableArray* halfEdgesMetaNames = [self createMetaNamesForIndices:objFileVertIndices];
                
                //Get the integer values of the vertices so we know which ones we are accessing
                
                unsigned count = 0;
                HalfEdge* currEdges[3] = {0};
                for(NSString* halfEdgeName in halfEdgesMetaNames)
                {
                    /* Half Edge Creation Algorithm:
  
                       For every meta name created
                            If the edge's twin has not been set, the
                     */
                    
                    
                    NSAssert(halfEdgeIndex != halfEdgesCount,@"Accessing more half edge memory than allocated");
                    HalfEdge* currentMemory = halfEdges + halfEdgeIndex;
                    BOOL shouldAdd = NO;
                    if([self.halfEdgeDictionary objectForKey:halfEdgeName] == nil)
                    {
                        shouldAdd = YES;
                        currEdges[count] = [self createHalfEdgeFromMeta:halfEdgeName fromEdgeMem:currentMemory fromVertMem:vertexData];
                    }
                    else
                    {
                        //Since the edge already exists, we just need to keep track of it
                        //for the construction of this face.
                        [[self.halfEdgeDictionary objectForKey:halfEdgeName] getValue:currEdges[count]];
                    }
                    
                    //Update the next edge pointer dependent on current edge
                    if(count == 0)
                    {
                        faceData[faceIndex].start = currEdges[count];
                    }
                    else if(count > 0)
                    {
                        //previous edge now points to current one
                        [self halfEdge:currEdges[count - 1] pointsTo:currEdges[count]];
                        
                        if(count == 2)
                        {
                            //triangle wrap...
                            [self halfEdge:currEdges[count] pointsTo:currEdges[0]];
                        }
                    }
                    
                    currEdges[count]->face = &faceData[faceIndex];
                    ++count;
                    ++faceIndex;
                    
                    if(shouldAdd)
                    {
                        [self.halfEdgeDictionary setObject:[NSValue value:currEdges withObjCType:@encode(HalfEdge)] forKey:halfEdgeName];
                        halfEdgeIndex += 2;//only advance if we added a new edge
                    }
                }
            }
        }
        
        self.vertices = vertexData;
        self.edges = halfEdges;
        self.m_Faces = faceData;
        
        //At this point we have all the data we need, so now we have to compute the normals for
        //each face, and then for each vertex
        [self initFaceNormals];
        
        //Compute the vertex normal based on the faces that share that vertex
        [self initVertexNormals];

        return YES;
    }
    else
    {
        return NO;
    }
}

-(void) initFaceNormals
{
    //Go through every face. Compute side vectors for every face, and then
    //compute the cross product.
    for(GLuint i = 0; i < self.m_FaceCount; ++i)
    {
        //Get the vertex reference by the 3 indeces that a face constains
        Face* face = &self.m_Faces[i];
        NSAssert(face != NULL, @"A created Face has not been properly assigned");
        
        GLKVector3 vert1, vert2, vert3, vec1, vec2;
        vert1 = face->start->to->pos;
        vert2 = face->start->next->to->pos;
        vert3 = face->start->next->next->to->pos;
        
        //Get the two ccw vectors
        vec1 = GLKVector3Subtract(vert1,vert2);
        vec2 = GLKVector3Subtract(vert1,vert3);
        
        face->normal = GLKVector3CrossProduct(vec1, vec2);
    }
}

-(void) initVertexNormals
{
    for(GLuint i = 0; i < self.m_VertCount; ++i)
    {
        GLKVector3 vertNorm;
        
        Vertex* currVert = &self.vertices[i];
        NSAssert(currVert != NULL, @"A created Vertex is NULL at initVertexNormal");
        GLuint sharedFaceCount = 0;
        
        //Go through every face, figuring out if a face has the current
        //vertex
        for(GLuint f = 0; f < self.m_FaceCount; ++f)
        {
            Face* face = &self.m_Faces[i];
            NSAssert(face != NULL, @"A created Face is NULL at initVertexNormal");
            
            Vertex *vert1, *vert2, *vert3;
            vert1 = face->start->to;
            vert2 = face->start->to->outEdge->to;
            vert3 = face->start->to->outEdge->to->outEdge->to;
            
            //If our currVec has the same address as any of the vertices of the
            //current face, then the vertex shares the face
            if(vert1 == currVert || vert2 == currVert || vert3 == currVert)
            {
                ++sharedFaceCount;
                vertNorm = GLKVector3Add(vertNorm, face->normal);
            }
        }
        
        vertNorm.x /= sharedFaceCount;
        vertNorm.y /= sharedFaceCount;
        vertNorm.z /= sharedFaceCount;
        
        if(self.vertNormals != NULL)
            self.vertNormals[i] = GLKVector3Normalize(vertNorm);
    }
}

-(void) flushMemory
{
    if(self.edges)
    {
        free(self.edges);
        self.edges = NULL;
    }
    if(self.vertices)
    {
        free(self.vertices);
        self.vertices = NULL;
    }
    if(self.vertNormals)
    {
        free(self.vertNormals);
        self.vertNormals = NULL;
    }
    if(self.faces)
    {
        free(self.m_Faces);
        self.m_Faces = NULL;
    }
}

-(void) dealloc
{
    NSLog(@"Deallocating wavefront data");
    [self flushMemory];
     
}

@end

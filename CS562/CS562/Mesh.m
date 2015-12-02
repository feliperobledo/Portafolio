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

#import <Mesh.h>
#import <MacroCommons.h>
#include <OpenGLErrorHandling.h>



@implementation Mesh
{
    // The data of this variable will be initialized once createMeshDataFromFile:
    //     is called. It will hold the data required to create the OpenGL index
    //     array. Once createOpenGLInformation is called, this variable goes
    //     back to pointing nowhere.
    GLuint* persistantFaceData;
    
    GLuint elementArray;
}

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

-(id) initWithVertices:(NSArray*)vertices andFaces:(NSArray*)indices {
    // do something!
    if ((self = [super init])) {
        // Bad, bad, bad...
        self.m_VertCount = (GLuint)[vertices count];
        self.m_FaceCount = (GLuint)[indices count] / 3;
        
        // Copy over the indices of the faces
        persistantFaceData = (GLuint*)malloc(sizeof(GLuint) * [indices count]);
        for(int i = 0; i < [indices count]; ++i) {
            persistantFaceData[i] = [[indices objectAtIndex:i] unsignedIntValue];
        }
        
        // Copy over the vertex data
        // BAD, BAD, BAD!
        self.vertices = (Vertex*)malloc(sizeof(Vertex) * [vertices count]);
        for(int i = 0; i < self.m_VertCount; ++i) {
            NSValue *val   = [vertices objectAtIndex:i];
            Vertex *vertex = (Vertex*)[val pointerValue];
            Vertex *mem = &_vertices[i];
            memcpy(mem, vertex, sizeof(Vertex));
        }
    }
    return self;
}

-(void) serializeWith:(NSObject*)ser {
    
}

// -----------------------------------------------------------------------------
-(BOOL) createMeshDataFromFile:(NSData*)objData
{
    //open the file
    self.m_VertCount = 0;
    self.m_FaceCount = 0;
    
    BOOL shouldCalculateNormals = YES;
    if(objData)
    {
        //Create an array of string, each index being a line in the file
        NSString* file = [[NSString alloc] initWithData:objData encoding:NSUTF8StringEncoding];
        NSArray *lines = [file componentsSeparatedByString:@"\n"];
        
        // Get the number of vertices and faces from the first 10 lines
        for(NSString * line in lines)
        {
            if (![line hasPrefix:@"#"]) {
                continue;
            }
            
            if (![line containsString:@"Vertices"] &&
                ![line containsString:@"Faces"]) {
                continue;
            }
            
            // Intermediate
            NSString *numberString;
            
            NSScanner *scanner = [NSScanner scannerWithString:line];
            NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            
            // Throw away characters before the first number.
            [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
            
            // Collect numbers.
            [scanner scanCharactersFromSet:numbers intoString:&numberString];
            
            // Result.
            GLuint val = [numberString intValue];
            
            if ([line containsString:@"Vertices"])
            {
                self.m_VertCount = val;
            }
            else if([line containsString:@"Faces"])
            {
                self.m_FaceCount = val;
            }
        }

#ifdef USE_HALF_EDGE
        self.halfEdgeDictionary = [[NSMutableDictionary alloc]init];
        const GLuint indicesPerTriad = 3;
        GLuint edgesCount            = self.m_FaceCount * indicesPerTriad;
        GLuint halfEdgesCount        = self.m_HalfEdgeCount = edgesCount * 2;

        GLuint halfEdgeArrayByteSize = sizeof(HalfEdge) * halfEdgesCount;
#endif
        
        Vertex* vertexData  = (Vertex*)     malloc(sizeof(Vertex) * self.m_VertCount);
        Face* faceData      = (Face*)       malloc(sizeof(Face) * self.m_FaceCount);
        self.vertNormals    = (GLKVector3*) malloc(sizeof(GLKVector3) * self.m_VertCount);
        persistantFaceData  = (GLuint*)     malloc(sizeof(GLuint) * (self.m_FaceCount * 3));


        NSAssert(vertexData != NULL,
                 @"Ran out of memory. Too many VERTICES in model or OS fault");
        NSAssert(faceData != NULL,
                 @"Ran out of memory. Too many FACES in model or OS fault");
        NSAssert(persistantFaceData != NULL,
                 @"Ran out of memory. Too many VERTEX INDICES or OS fault");
        
        memset(vertexData, 0, sizeof(Vertex) * self.m_VertCount);
        memset(faceData,   0, sizeof(Face)   * self.m_FaceCount);
        memset(persistantFaceData, 0,sizeof(GLuint) * (self.m_FaceCount * 3));
        
#ifdef USE_HALF_EDGE
        HalfEdge* halfEdges = (HalfEdge*)   malloc(halfEdgeArrayByteSize);
        NSAssert(halfEdges != NULL,
                 @"Ran out of memory. Too many EDGES in model or OS fault");
        memset(halfEdges,  0, halfEdgeArrayByteSize);
#endif
        
        int vertexIndex = 0, faceIndex = 0, halfEdgeIndex = 0, vertexNormal = 0;
        for(NSString * line in lines)
        {
            if([line hasPrefix:@"vn"]) { // we will now create the half edges
                shouldCalculateNormals = NO;
                // HACK: assign the normal to the vertex as it is read.
                //PROPER: store in vertex normal array. When face data refers to it, store it
                //        in the face data
                Vertex *vert = &vertexData[vertexNormal];
                
                //Get a new string that starts after the prefix
                NSString *lineTrunc = [line substringFromIndex:3];
                
                //Convert line into an array of 3 entries, one for each element of the vertex
                NSArray *lineVertices = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                vert->normal.x = [[lineVertices objectAtIndex:0] floatValue];
                vert->normal.y = [[lineVertices objectAtIndex:1] floatValue];
                vert->normal.z = [[lineVertices objectAtIndex:2] floatValue];
                ++vertexNormal;
            } else if ([line hasPrefix:@"v"]) {
                Vertex *vert = &vertexData[vertexIndex];
                
                //Get a new string that starts after the prefix
                NSString *lineTrunc = [line substringFromIndex:2];
                
                //Convert line into an array of 3 entries, one for each element of the vertex
                NSArray *lineVertices = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                vert->pos.x = [[lineVertices objectAtIndex:0] floatValue];
                vert->pos.y = [[lineVertices objectAtIndex:1] floatValue];
                vert->pos.z = [[lineVertices objectAtIndex:2] floatValue];
                
                vert->index = vertexIndex;
                ++vertexIndex;
            } else if([line hasPrefix:@"f"]) {
                // Get a new string that starts after the prefix
                NSString* truncLine = [line substringFromIndex:2];
                
                // Convert line into an array of 3 entries, one for each element of the face
                NSArray* data = [truncLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                NSMutableArray* objFileVertIndices = [[NSMutableArray alloc]init];
                
                
                [self placeIndicesFrom:data Into:objFileVertIndices];
                
                // Store the meta names of the current Edges
                NSMutableArray* halfEdgesMetaNames = [self createMetaNamesForIndices:objFileVertIndices];
                
                // Save the indices of the face into our persitent data. OpenGL
                //     requires this data to draw.
                for(int i = 0; i < [objFileVertIndices count]; ++i) {
                    GLuint temp = (GLuint)[[objFileVertIndices objectAtIndex:i] unsignedIntValue];
                    int currIndex = faceIndex * 3 + i;
                    persistantFaceData[currIndex] = temp;
                }
                
#ifdef USE_HALF_EDGE
                unsigned count = 0;
                HalfEdge* currEdges[3] = {NULL};
                for(NSString* halfEdgeName in halfEdgesMetaNames)
                {
                    NSAssert(halfEdgeIndex <= halfEdgesCount,@"Accessing more half edge memory than allocated");
                    
                    // Get the memory for the new half-edge we will use
                    HalfEdge* currentMemory = &halfEdges[halfEdgeIndex];
                    BOOL shouldAdd = NO;
                    if([self.halfEdgeDictionary objectForKey:halfEdgeName] == nil) {
                        
                        // This meta-name does not have any memory attached to
                        // it, so we will assign it the new memory address.
                        shouldAdd = YES;
                        currEdges[count] = [self createHalfEdgeFromMeta:halfEdgeName fromEdgeMem:currentMemory fromVertMem:vertexData];
                        
                    } else {
                        // Since the edge already exists, we just need to keep track of it
                        // for the construction of this face.
                        NSValue* val = [self.halfEdgeDictionary objectForKey:halfEdgeName];
                        currEdges[count] = (HalfEdge*)[val pointerValue];
                    }
                    
                    //Update the next edge pointer dependent on current edge

                    if(count == 0) {
                        Face* f = &faceData[faceIndex];
                        f->start = currEdges[count];
                    } else if(count > 0) {
                        //previous edge now points to current one
                        [self halfEdge:currEdges[count - 1] pointsTo:currEdges[count]];
                        
                        if(count == 2){
                            //triangle wrap...
                            [self halfEdge:currEdges[count] pointsTo:currEdges[0]];
                        }
                        
                    }
                    
                    // Let the edge know which is its face
                    if(currEdges[count]->face == NULL) {
                       Face* f = &faceData[faceIndex];
                       currEdges[count]->face = f;
                    }
                    
                    if(shouldAdd)
                    {
                        [self.halfEdgeDictionary setObject:[NSValue valueWithPointer:currEdges[count]] forKey:halfEdgeName];
                        
                        // Adding the address of the half-edge. If encountered
                        // in the file, this will be fetched and completed.
                        NSString* halfEdgeTwinName = [self getTwinNameFromHalfEdgeName:halfEdgeName];
                        [self.halfEdgeDictionary setObject:[NSValue valueWithPointer:currEdges[count]->twin] forKey:halfEdgeTwinName];
                        
                        halfEdgeIndex += 2;//only advance if we added a new edge
                    }
                    
                    ++count;
                }
#else
                Face* f = &faceData[faceIndex];
                f->v1 = (GLuint)[[objFileVertIndices objectAtIndex:0] unsignedIntValue];;
                f->v2 = (GLuint)[[objFileVertIndices objectAtIndex:1] unsignedIntValue];;
                f->v3 = (GLuint)[[objFileVertIndices objectAtIndex:2] unsignedIntValue];;
#endif
                //Move on to the next face all edges will belong to
                ++faceIndex;
            }
        }
        
        self.vertices = vertexData;
#ifdef USE_HALF_EDGE
        self.edges = halfEdges;
#endif
        self.faces = faceData;
        
        if(shouldCalculateNormals) {
            //At this point we have all the data we need, so now we have to compute the normals for
            //each face, and then for each vertex
            [self initFaceNormals];
            
            //Compute the vertex normal based on the faces that share that vertex
            [self initVertexNormals];
        }
        
        return YES;
    } else {
        return NO;
    }
}

-(void)createOpenGLInformation {
    // HACK! Skydome does this differently and before
    if(_vertices == NULL) {
        return;
    }
    
    NSLog(@"\n\nOPENGL DATA: %s",[[self sourceName] UTF8String]);
    const GLuint vertStride = [Mesh getVertexStride];
    const GLuint vertSize   = [Mesh getVertexSize];
    const GLuint vertCount  = [self vertCount];
    const GLuint verticesFullByteSize = vertStride * vertCount;
    
    GLuint indicesByteSize = sizeof(GLuint)* ([self faceCount] * 3);
    
    const BOOL showDebugInfo = NO;

    GLfloat* rawData = (GLfloat*)malloc(verticesFullByteSize);
    memset(rawData,0,verticesFullByteSize);
    for(int i = 0; i < vertCount; ++i) {
        GLfloat* currVertex = (GLfloat*)(rawData + i * vertSize);
        Vertex* vertex = (_vertices + i);
        // The following two results of the conditional due the same thing, and
        //     the compiler might generate similar code for both of them.
        
        // setting the position
        currVertex[0] = vertex->pos.x;
        currVertex[1] = vertex->pos.y;
        currVertex[2] = vertex->pos.z;
        
        // setting the normal
        currVertex[3] = vertex->normal.x;
        currVertex[4] = vertex->normal.y;
        currVertex[5] = vertex->normal.z;
        
        // setting the color
        currVertex[6] = vertex->color.x;
        currVertex[7] = vertex->color.y;
        currVertex[8] = vertex->color.z;
        currVertex[9] = vertex->color.w;
        
        // setting the u & v
        currVertex[10] = vertex->texture.x;
        currVertex[11] = vertex->texture.y;
        
        // setting tanget
        currVertex[12] = vertex->tangent.y;
        currVertex[13] = vertex->tangent.y;
        currVertex[14] = vertex->tangent.y;
        
        // setting the bitangent
        currVertex[15] = vertex->bitangent.y;
        currVertex[16] = vertex->bitangent.y;
        currVertex[17] = vertex->bitangent.y;
        
        if(showDebugInfo) {
            printf("normal     [x,y,z] = [%.2f,%.2f,%.2f]\t",
                       *(currVertex + 0),*(currVertex + 1),*(currVertex + 2));
            printf("position   [x,y,z] = [%.2f,%.2f,%.2f]\n",
                       *(currVertex + 3),*(currVertex + 4),*(currVertex + 5));
        }
    }

    GLuint vao = 0;
    glGenVertexArrays (1, &vao);
    glBindVertexArray(vao);
    {
        GLsizei vertexDataComponents = 2;
        GLuint vboIDs[2] = {0};
        
        glGenBuffers(vertexDataComponents, vboIDs);
        
        glBindBuffer(GL_ARRAY_BUFFER, vboIDs[0]);
        glBufferData(GL_ARRAY_BUFFER,
                     verticesFullByteSize,
                     rawData,
                     GL_STATIC_DRAW);
        
        {
            GLuint64 offset = 0;
            glVertexAttribPointer(GLKVertexAttribPosition,
                                  POS_SIZE,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  vertStride,
                                  (const void*)offset);
            offset += sizeof(GLfloat) * POS_SIZE;
            CheckOpenGLError();
            
            glVertexAttribPointer(GLKVertexAttribNormal,
                                  NORM_SIZE,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  vertStride,
                                  (const void*)offset);
            offset += sizeof(GLfloat) * NORM_SIZE;
            CheckOpenGLError();
            
            // Will use this enum for a float2
            glVertexAttribPointer(GLKVertexAttribColor,
                                  COLOR_SIZE,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  vertStride,
                                  (const void*)offset);
            offset += sizeof(GLfloat) * COLOR_SIZE;
            CheckOpenGLError();
            
            // Will use this enum for a float2
            glVertexAttribPointer(GLKVertexAttribTexCoord0,
                                  1,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  vertStride,
                                  (const void*)offset);
            offset += sizeof(GLfloat);
            
            glVertexAttribPointer(GLKVertexAttribTexCoord1,
                                  1,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  vertStride,
                                  (const void*)offset);
            offset += sizeof(GLfloat);
            CheckOpenGLError();
            
            glVertexAttribPointer(GLKVertexAttribTangent,
                                  TANGENT_SIZE,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  vertStride,
                                  (const void*)offset);
            offset += sizeof(GLfloat) * TANGENT_SIZE;
            CheckOpenGLError();
            
            glVertexAttribPointer(GLKVertexAttribBinormal,
                                  BINORMAL_SIZE,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  vertStride,
                                  (const void*)offset);
            offset += sizeof(GLfloat) * BINORMAL_SIZE;
            CheckOpenGLError();
        }
            
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboIDs[1]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                     indicesByteSize,
                     persistantFaceData,
                     GL_STATIC_DRAW);
    
        elementArray = vboIDs[1];
    }
    glBindVertexArray(0);
    
    self.glData = (OpenGLMeshData*)malloc(sizeof(OpenGLMeshData));
    [self glData]->vao = vao;
    
    if (showDebugInfo) {
        for(int i = 0; i < [self faceCount]; ++i) {
            GLuint i1 = persistantFaceData[i * 3 + 0],
                   i2 = persistantFaceData[i * 3 + 1],
                   i3 = persistantFaceData[i * 3 + 2];
            printf("F %d: %u %u %u\n",i,i1,i2,i3);
        }
    }
    
    free(persistantFaceData); persistantFaceData = NULL;
    free(rawData);            rawData = NULL;
}

-(void) bindMesh {
    glBindVertexArray ([self glData]->vao);
}

-(void) placeIndicesFrom:(NSArray*)textData Into:(NSMutableArray*)container {
    //Retrieve the data from the object file
    for(NSString* currFace in textData)
    {
        if([currFace containsString:@"/"])
        {
            NSArray* faceparts = [currFace componentsSeparatedByString:@"/"];
            
            //Use the range of // to figure out
            NSRange range = [currFace rangeOfString:@"//"];
            bool hasTextureIndex = range.length == 0;
            
            //Place the data in the corresponding index of the position array
            NSNumber* vertIndex = [NSNumber numberWithUnsignedInt:(GLuint)[[faceparts objectAtIndex:0] integerValue] - 1];
            [container addObject:vertIndex];
            
            //If we found a texture
            if(hasTextureIndex)
            {
                //store texture coordinates
            }
        }
        else
        {
            NSNumber* vertIndex = [NSNumber numberWithInt:(int)([currFace integerValue] - 1)];
            [container addObject:vertIndex];
        }
    }
}

-(NSString*) createMetaNameFromVert:(NSString*)v0 ToVert:(NSString*)v1 {
    const char* prefix  = "E";
    const char* divider = ":";
    
    NSString* meta = [[NSString alloc] init];
    meta = [meta stringByAppendingString:[NSString stringWithUTF8String:prefix]];
    meta = [meta stringByAppendingString:v0];
    meta = [meta stringByAppendingString:[NSString stringWithUTF8String:divider]];
    meta = [meta stringByAppendingString:v1];
    
    return meta;
}

-(NSMutableArray*) createMetaNamesForIndices:(NSMutableArray*)numberIndices {
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

-(HalfEdge*)createHalfEdgeFromMeta:(NSString*)halfEdgeMetaName fromEdgeMem:(HalfEdge*)newHalfEdge fromVertMem:(Vertex*)vertexMem {
    // Set the twin pointer for both half edges. The newHalfEdge twin is next to it in memory
    HalfEdge* twin = newHalfEdge + 1;
    newHalfEdge->twin = twin;
    twin->twin = newHalfEdge;
    
    // indices:           0   ...   y   ...
    // meta name format:  E    x    :    y
    // Extract the vertex indices form the meta name
    NSString* subString = [halfEdgeMetaName substringFromIndex:1];
    NSArray* faceComponents = [subString componentsSeparatedByString:@":"];
    
    int fromIndex = (int)[[faceComponents objectAtIndex:0] integerValue];
    int toIndex   = (int)[[faceComponents objectAtIndex:1] integerValue];
    
    Vertex *source      = &vertexMem[fromIndex],
           *destination = &vertexMem[toIndex];
    
    // Init half-edge with the vertex it goes to
    // Set start index's out edge if it has not been set
    if(newHalfEdge->to == NULL) {
        
        newHalfEdge->to = destination;
        if(destination->outEdge == NULL) {
            destination->outEdge = newHalfEdge;
        }
        
    }
    
    // Set up the half edge's twin
    if(twin->to == NULL) {

        twin->to = source;
        if(source->outEdge == NULL) {
           source->outEdge = twin;
        }
        
    }
    
    return newHalfEdge;
}

-(NSString*) getTwinNameFromHalfEdgeName:(NSString*)halfEdgeName {
    NSString* subString = [halfEdgeName substringFromIndex:1];
    NSArray* faceComponents = [subString componentsSeparatedByString:@":"];
    
    NSMutableString* output = [[NSMutableString alloc] init];
    [output appendString:@"E"];
    [output appendString:[faceComponents objectAtIndex:1]];
    [output appendString:@":"];
    [output appendString:[faceComponents objectAtIndex:0]];
    
    return output;
}

-(void) halfEdge:(HalfEdge*)v1 pointsTo:(HalfEdge*)v2 {
    if(v1->next == NULL) {
        v1->next = v2;
    }
}

-(void) initFaceNormals
{
    //Go through every face. Compute side vectors for every face, and then
    //compute the cross product.
    BOOL debug = false;
    for(GLuint i = 0; i < self.m_FaceCount; ++i)
    {
        //Get the vertex reference by the 3 indeces that a face constains
        Face* face = &self.faces[i];
        NSAssert(face != NULL, @"A created Face has not been properly assigned");
        
        GLKVector3 vert1, vert2, vert3, vec1, vec2;
#ifdef USE_HALF_EDGE
        vert1 = face->start->to->pos;
        vert2 = face->start->next->to->pos;
        vert3 = face->start->next->next->to->pos;
#else
        vert1 = _vertices[face->v1].pos;
        vert2 = _vertices[face->v2].pos;
        vert3 = _vertices[face->v3].pos;
#endif
        
        if(debug) {
            printf("v1[%3.2f,%3.2f,%3.2f]\t",vert1.x,vert1.y,vert1.z);
            printf("v2[%3.2f,%3.2f,%3.2f]\t",vert2.x,vert2.y,vert2.z);
            printf("v3[%3.2f,%3.2f,%3.2f]\n",vert3.x,vert3.y,vert3.z);
        }
        
        //Get the two ccw vectors
        vec1 = GLKVector3Normalize(GLKVector3Subtract(vert3,vert1));
        vec2 = GLKVector3Normalize(GLKVector3Subtract(vert2,vert1));
        
        GLKVector3 cross = GLKVector3CrossProduct(vec2, vec1);
        GLKVector3 n = GLKVector3Normalize( cross );
        face->normal = n;
        
        if(debug) {
            printf("face %d normal [%.2f,%.2f,%.2f]\n\n",i, n.x,n.y,n.z);
        }
    }
}

-(void) initVertexNormals {

    for(GLuint i = 0; i < self.m_VertCount; ++i) {
        GLKVector3 vertNorm;
        
        Vertex* currVert = &self.vertices[i];
        NSAssert(currVert != NULL, @"A created Vertex is NULL at initVertexNormal");
        GLuint sharedFaceCount = 0;
        
        // Get the sum of all face normals that share this vertex
        for(GLuint f = 0; f < self.m_FaceCount; ++f)
        {
            Face* face = &self.faces[f];
            NSAssert(face != NULL, @"A created Face is NULL at initVertexNormal");
            
            Vertex *vert1, *vert2, *vert3;
#ifdef USE_HALF_EDGE
            vert1 = face->start->to;
            vert2 = face->start->next->to;
            vert3 = face->start->next->next->to;
#else
            vert1 = &_vertices[face->v1];
            vert2 = &_vertices[face->v2];
            vert3 = &_vertices[face->v3];
#endif
        
            //If our currVec has the same address as any of the vertices of the
            //current face, then the vertex shares the face
            if(vert1 == currVert || vert2 == currVert || vert3 == currVert) {
                ++sharedFaceCount;
                vertNorm = GLKVector3Add(vertNorm, face->normal);
            }
        }
        
        if (sharedFaceCount != 0) {
            vertNorm.x /= sharedFaceCount;
            vertNorm.y /= sharedFaceCount;
            vertNorm.z /= sharedFaceCount;
        }
        
        currVert->normal = GLKVector3Normalize(vertNorm);
        
        if(self.vertNormals != NULL)
            self.vertNormals[i] = GLKVector3Normalize(vertNorm);
    }
}

-(void) saveVertexNormalsToFile:(NSString*)filename {
    // create the filepaht to the file we will save to
    NSString* filePath = @"/Users/feliperobledo/normals/";
    filePath = [filePath stringByAppendingString:filename];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    NSString* str = [[NSString alloc] init];
    
    for(GLuint i = 0; i < self.m_VertCount; ++i) {
        Vertex* currVert = &self.vertices[i];
        GLKVector3 vertNorm = currVert->normal;
        NSNumber *x = [[NSNumber alloc] initWithFloat:vertNorm.x],
                 *y = [[NSNumber alloc] initWithFloat:vertNorm.y],
                 *z = [[NSNumber alloc] initWithFloat:vertNorm.z];
    
        str = [str stringByAppendingString:@"vn "];
        str = [str stringByAppendingString:[x stringValue]];
        str = [str stringByAppendingString:@" "];
        str = [str stringByAppendingString:[y stringValue]];
        str = [str stringByAppendingString:@" "];
        str = [str stringByAppendingString:[z stringValue]];
        str = [str stringByAppendingString:@"\n"];
    }
    
    NSError* error;
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        for(NSString* key in [error userInfo]) {
            NSString* errorDescription = [[error userInfo] valueForKey:key];
            NSLog(@"ERROR: %s",[errorDescription UTF8String]);
        }
    }
}

-(void) flushMemory {
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
        free(self.faces);
        self.faces = NULL;
    }
    if(self.glData)
    {
        free(self.glData);
        self.glData = NULL;
    }
}

-(void) dealloc {
    NSLog(@"Deallocating wavefront data");
    [self flushMemory];
     
}

// -----------------------------------------------------------------------------

+(GLuint) getVertexStride {
    const GLuint vertStride = (sizeof(GLfloat)*POS_SIZE  +
                               sizeof(GLfloat)*TEXTURE_SIZE +
                               sizeof(GLfloat)*NORM_SIZE +
                               sizeof(GLfloat)*COLOR_SIZE+
                               sizeof(GLfloat)*TANGENT_SIZE +
                               sizeof(GLfloat)*BINORMAL_SIZE);
    return vertStride;
}

+(GLuint) getVertexSize {
    const GLuint vertSize = POS_SIZE
                            + NORM_SIZE
                            + TEXTURE_SIZE
                            + COLOR_SIZE
                            + TANGENT_SIZE
                            + BINORMAL_SIZE;
    
    return vertSize;
}
@end

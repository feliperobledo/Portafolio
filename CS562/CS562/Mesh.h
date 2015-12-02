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

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGL/gltypes.h>
#import <CS562Core/IModel.h>

//#define USE_HALF_EDGE

@class Entity;

//------------------------------------------------------------------------------
struct Face;
struct Vertex;


struct HalfEdge
{
    struct Vertex* to;
    struct HalfEdge* twin;
    struct HalfEdge* next;
    struct Face* face;
};

typedef struct HalfEdge HalfEdge;


struct Vertex
{
    GLKVector3 pos;
    GLKVector3 normal;
    GLKVector4 color;
    GLKVector3 tangent;
    GLKVector3 bitangent;
    GLKVector2 texture;

    HalfEdge* outEdge;
#ifndef USE_HALF_EDGE
    GLuint face;
#endif
    
    GLuint index;
};

typedef struct Vertex Vertex;

struct Face
{
#ifdef USE_HALF_EDGE
    HalfEdge* start;
#else
    GLuint v1,v2,v3;
#endif
    
    GLKVector3 normal;
};

typedef struct Face Face;

struct OpenGLMeshData {
    GLuint vao;
};

typedef struct OpenGLMeshData OpenGLMeshData;

// Extend GLKVertexAttrib enum to contain more data that we add
//     to our vertices.
typedef enum {
    GLKVertexAttribTangent = GLKVertexAttribTexCoord1 + 1,
    GLKVertexAttribBinormal
} ExtendGLKVertexAttrib;

//------------------------------------------------------------------------------
@interface Mesh : IModel
    @property (getter=vertCount) GLuint m_VertCount;
    @property (getter=faceCount) GLuint m_FaceCount;
    @property (getter=halfEdgeCount) GLuint m_HalfEdgeCount;

    @property HalfEdge* edges;
    @property Vertex* vertices;
    @property Face* faces;

    @property OpenGLMeshData* glData;

    @property GLKVector3* vertNormals;
    @property (getter=sourceName,setter=setSourceFile:) NSString* modelFileName;
    @property (strong,nonatomic)  NSMutableDictionary* halfEdgeDictionary;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(id) initWithVertices:(NSArray*)vertices andFaces:(NSArray*)indices;
-(void) serializeWith:(NSObject*)ser;

-(BOOL) createMeshDataFromFile:(NSData*)objData;

// Creates the vertex vbo and index vbo and associates it with
//     a vao.
-(void) createOpenGLInformation;
-(void) bindMesh;

// Operation for initializing missing essential vertex data
-(void) initFaceNormals;
-(void) initVertexNormals;
-(void) saveVertexNormalsToFile:(NSString*)filename;

-(void) flushMemory;
-(void) dealloc;

+(GLuint) getVertexStride;
+(GLuint) getVertexSize;

@end

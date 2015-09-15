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

#import <CS562Core/IModel.h>

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
    GLKVector4 colors;
    GLKVector3 uv;
    GLKVector3 tangent;
    GLKVector3 binormal;
    HalfEdge* outEdge;
};

typedef struct Vertex Vertex;

struct Face
{
    HalfEdge* start;
    GLKVector3 normal;
};

typedef struct Face Face;


//------------------------------------------------------------------------------
@interface Mesh : IModel
    @property (getter=vertCount) GLuint m_VertCount;
    @property (getter=faceCount) GLuint m_FaceCount;
    @property (getter=halfEdgeCount) GLuint m_HalfEdgeCount;

    @property HalfEdge* edges;
    @property Vertex* vertices;
    @property Face* faces;
    @property GLKVector3* vertNormals;
    @property (getter=sourceName,setter=setSourceFile:) NSString* modelFileName;
    @property (strong,nonatomic)  NSMutableDictionary* halfEdgeDictionary;

-(id) init;
-(id) initWithOwner:(Entity*)owner;
-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser;
-(id) initWithDictionary:(NSDictionary*)dict;
-(void) serializeWith:(NSObject*)ser;

-(BOOL) createMeshDataFromFile:(NSData*)objData;
-(void) initFaceNormals;
-(void) initVertexNormals;
-(void) flushMemory;
-(void) dealloc;
@end

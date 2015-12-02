//
//  PrimitiveCreation.h
//  CS562
//
//  Created by Felipe Robledo on 11/17/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#include <OpenGL/gltypes.h>

#ifndef PrimitiveCreation_h
#define PrimitiveCreation_h

struct ModelData{
    GLint vertCount, faceCount;
    GLfloat* Vertices;
    GLfloat* Indices;
};

///<summary>
/// Creates a sphere centered at the origin with the given radius.  The
/// slices and stacks parameters control the degree of tessellation.
///</summary>
void CreateSphere(float radius, unsigned sliceCount, unsigned stackCount, struct ModelData** md);

///<summary>
/// Creates a geosphere centered at the origin with the given radius.  The
/// depth controls the level of tessellation.
///</summary>
void CreateGeosphere(float radius, unsigned numSubdivisions,struct ModelData** ModelData);

#endif /* PrimitiveCreation_h */

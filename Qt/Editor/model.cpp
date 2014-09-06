#include "model.h"
#include "BypassGL.h"
#include "mymodelserializer.h"
#include "externalinitializer.h"
#include "mymodelserializer.h"
#include <QDebug>
#include <QVector>

struct GLData
{
    bool m_validVBOs;
    unsigned m_vertCount;
    unsigned m_indicesCount;
    GLuint m_vboIDs[VBO_ID_COUNT];
    QVector<GLfloat> m_VertData;
    QVector<GLuint> m_Indices;
};

// -----------------------------------------------------------------------------

Model::Model() : IComponent(),
                 m_ModelFile(""),
                 m_glData(new GLData),
                 m_glMethods(NULL)

{
    //init the gl data
    m_glData->m_validVBOs = false;
    m_glData->m_vertCount = 0;
    m_glData->m_indicesCount = 0;
}

void Model::Initialize(const char*)
{
    //m_glData->m_Indices = serializer.

    //The vertices of our 3D cube in model space
    GLint numOfVerts = 8;
    GLfloat vertexData[56] =
    {
         //model space vertex |       color
           0.5f, 0.5f, 0.5f,    1.0f,0.0f,0.0f,1.0f, //[0]
          -0.5f, 0.5f, 0.5f,    0.0f,1.0f,0.0f,1.0f, //1
          -0.5f,-0.5f, 0.5f,    0.0f,0.0f,1.0f,1.0f, //2
           0.5f,-0.5f, 0.5f,    1.0f,0.0f,0.0f,1.0f, //3
           0.5f,-0.5f,-0.5f,    1.0f,0.0f,0.0f,1.0f, //4
           0.5f, 0.5f,-0.5f,    1.0f,0.0f,0.0f,1.0f, //5
          -0.5f, 0.5f,-0.5f,    1.0f,0.0f,0.0f,1.0f, //6
          -0.5f,-0.5f,-0.5f,    1.0f,0.0f,0.0f,1.0f  //[7]
    };

    m_glData->m_vertCount = numOfVerts;
    for(int i = 0; i < 56; ++i)
        m_glData->m_VertData.push_back(vertexData[i]);

    //Define how each face is defined
    GLuint numOfIndeces = 36;
    GLushort indices[36] =
    {
        0,1,2,    0,2,3, //front
        0,3,4,    0,4,5, //right
        5,1,0,    5,6,1, //top
        5,4,7,    5,7,6, //back
        6,7,2,    6,2,1, //left
        7,3,2,    7,4,3  //bottom
    };

    m_glData->m_indicesCount = numOfIndeces;
    for(int i = 0; i < 36; ++i)
        m_glData->m_Indices.push_back(indices[i]);

    //going to have to implement the bridge pattern here
    ExternalInitializer bridge;
    bridge.SerializeData(this,":/modelResources/Models/mod_sample_cube.mod");

}

void Model::Free()
{
    if(m_glData)
    {
        delete m_glData;
    }
}

Model::~Model()
{
}

void Model::DrawPrep()
{
    if(m_glMethods == NULL)
    {
        qDebug() << "Cannot draw model";
        return;
    }

    //Need to do some checking here from the generation
    GenerateVBOs();

    GLuint* vboIDs = m_glData->m_vboIDs;
    GLint vtxStride = sizeof(GLfloat) * VERTEX_POS_SIZE +
                      sizeof(GLfloat) * VERTEX_COLOR_SIZE;

    //Bind buffers and set their data
    m_glMethods->glBindBuffer(GL_ARRAY_BUFFER,vboIDs[0]);
    m_glMethods->glBufferData(GL_ARRAY_BUFFER,
                 vtxStride * m_glData->m_vertCount,
                 &(m_glData->m_VertData[0]),
                 GL_STATIC_DRAW);

    m_glMethods->glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,vboIDs[1]);
    m_glMethods->glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                 m_glData->m_indicesCount * sizeof(GLushort),
                 &(m_glData->m_Indices[0]),
                 GL_STATIC_DRAW);
}

void Model::Draw()
{
    glDrawElements(GL_TRIANGLES,
                   m_glData->m_indicesCount,
                   GL_UNSIGNED_SHORT,
                   0);
}

void Model::PostDraw()
{
    CloseVBOs();
}

void Model::ReceiveGL(QOpenGLFunctions *glMethods)
{
    m_glMethods = glMethods;
}

// -----------------------------------------------------------------------------

void Model::LoadModel(const void* dataObject)
{
    using namespace SampleModelSerializer;
    typedef MyModelSerializer::MyDataHolder DataStore;

    const DataStore* dataStore =
            static_cast<const MyModelSerializer::MyDataHolder*>(dataObject);

    const DataStore::VertexData* dataModel =
            static_cast<const DataStore::VertexData*>(dataStore->GetDataStore());

    dataModel->m_vertices;
    //QVector<QVariant>::iterator iter = modData->
}

// -----------------------------------------------------------------------------

void Model::GenerateVBOs()
{
    if(!m_glData->m_validVBOs)
    {
        m_glMethods->glGenBuffers(VBO_ID_COUNT,m_glData->m_vboIDs);
        m_glData->m_validVBOs = true;
    }
}

void Model::CloseVBOs()
{
    if(m_glData->m_validVBOs)
    {
        m_glMethods->glDeleteBuffers(VBO_ID_COUNT,m_glData->m_vboIDs);
        m_glData->m_validVBOs = false;
    }
}

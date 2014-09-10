#include "model.h"
#include "BypassGL.h"
#include "mymodelserializer.h"
#include "externalinitializer.h"
#include "mymodelserializer.h"
#include <QDebug>
#include <QVector>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>

struct GLData
{
    bool m_validVBOs;
    unsigned m_vertCount;
    unsigned m_indicesCount;
    GLuint m_vboIDs[VBO_ID_COUNT];
    QVector<GLfloat> m_VertData;
    QVector<GLushort> m_Indices;
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
    //going to have to implement the bridge pattern here
    ExternalInitializer bridge;
    bridge.SerializeData(this,":/Resources/Models/cube.json");
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
                 (m_glData->m_VertData.data()),
                 GL_STATIC_DRAW);

    m_glMethods->glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,vboIDs[1]);
    m_glMethods->glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                 m_glData->m_Indices.size() * sizeof(GLushort),
                 (m_glData->m_Indices.data()),
                 GL_STATIC_DRAW);
}

void Model::Draw()
{
    glDrawElements(GL_TRIANGLES,
                   m_glData->m_Indices.size(),
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

void Model::LoadModel(const QJsonDocument &jsonDocument)
{
    QJsonObject obj = jsonDocument.object();

    //Get the two main objects of the json file
    QJsonObject indices = obj["indices"].toObject();
    QJsonObject vertices = obj["vertices"].toObject();

    //Initialize the vertices
    m_glData->m_vertCount = vertices["vertCount"].toInt();
    unsigned fieldPerVert = vertices["fieldPerVert"].toInt();
    QJsonArray array = vertices["vertData"].toArray();

    for(unsigned i = 0; i < m_glData->m_vertCount * fieldPerVert; ++i)
    {
        m_glData->m_VertData.push_back(array[i].toDouble());
    }

    //Initialie the indices
    m_glData->m_indicesCount = indices["count"].toInt();
    array = indices["indexData"].toArray();
    for(unsigned i = 0; i < m_glData->m_indicesCount; ++i)
    {
        m_glData->m_Indices.push_back(GLushort(array[i].toDouble()));
    }
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

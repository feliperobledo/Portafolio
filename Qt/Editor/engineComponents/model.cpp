#include "model.h"
#include "../glMVC/BypassGL.h"
#include "transform.h"
#include "../core/composite.h"
#include <QMatrix4x4>
#include <QFile>
#include <QDebug>
#include <QVector>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <QOpenGLShaderProgram>

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

Model::Model(QObject *parent) : EngineComponent(parent),
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
    QFile loadFile( ":/Resources/Models/cube.json" );

    if(!loadFile.open(QIODevice::ReadOnly))
    {
        qWarning("Couldn't open model file");
        return;
    }

    QByteArray data = loadFile.readAll();

    QJsonDocument doc(QJsonDocument::fromJson(data));
    //doc = QJsonDocument::fromJson(filepath.toLocal8Bit());

    //Pass to model the data for initialization
    LoadModel(doc);

    //Init shader program for this shader. This should depend on the init file
    //or the archetype
    InitShaderProgram();
}

void Model::Free()
{
    if(m_glData)
    {
        delete m_glData;
    }
}

void Model::ChangeData(const QString& member, const QVariant& data)
{
    //do stuff...
    Q_UNUSED(member); Q_UNUSED(data);
}

Model::~Model()
{
}

void Model::DrawPrep(const QMatrix4x4& worldView,const QMatrix4x4 viewPerspective)
{
    m_SProgram->bind();

    //Setting matrix data
    const Composite* owner = dynamic_cast<const Composite*>(parent());
    const Transform* transform =
            dynamic_cast<const Transform*>( owner->GetComponent("Transform",Composite::engine_component()) );
    QMatrix4x4 modelToWorld( transform->GetMatrix() );

    QMatrix4x4 modelToPersp( viewPerspective * (worldView * modelToWorld) );
    m_SProgram->setUniformValue(m_modelToPerspUni,modelToPersp);

    //Need to do some checking here from the generation
    GenerateVBOs();

    //Enable the vertex attribute array
    glEnableVertexAttribArray(m_posAttr);
    glEnableVertexAttribArray(m_colAttr);

    //Load the vertex data to specific indexes in the shader program
    GLint vtxStride = sizeof(GLfloat) * VERTEX_POS_SIZE +
                      sizeof(GLfloat) * VERTEX_COLOR_SIZE;
    GLuint offset = 0;

    //Tells GL how to interpret the data in the vertex buffer
    glVertexAttribPointer(m_posAttr,
                          VERTEX_POS_SIZE,
                          GL_FLOAT,
                          GL_FALSE,
                          vtxStride,
                          (const void*)offset);
    offset += VERTEX_POS_SIZE * sizeof(GLfloat);

    glVertexAttribPointer(m_colAttr,
                          VERTEX_COLOR_SIZE,
                          GL_FLOAT,
                          GL_FALSE,
                          vtxStride,
                          (const void*)offset);
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
    //Disable arrays
    glDisableVertexAttribArray(m_colAttr);
    glDisableVertexAttribArray(m_posAttr);

    CloseVBOs();

    m_SProgram->release();
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
}

void Model::CloseVBOs()
{
    if(m_glData->m_validVBOs)
    {
        m_glMethods->glDeleteBuffers(VBO_ID_COUNT,m_glData->m_vboIDs);
        m_glData->m_validVBOs = false;
    }
}

void Model::InitShaderProgram()
{
    m_SProgram = new QOpenGLShaderProgram(this);

    bool success = false;
    success = m_SProgram->addShaderFromSourceFile(QOpenGLShader::Vertex,
                                        QString(":/Resources/Shaders/vs_sample.vsh"));

    if(!success) qDebug() << "vertex shader problem";

    success = m_SProgram->addShaderFromSourceFile(QOpenGLShader::Fragment,
                                        QString(":/Resources/Shaders/sample.fsh"));

    if(!success) qDebug() << "fragment shader problem";

    //Linking occurs once all shaders have been attahced
    if(!m_SProgram->link())
    {
        qDebug() << QString("could not link");
    }

    m_posAttr = m_SProgram->attributeLocation("aPosition");
    qDebug() << m_posAttr;
    m_colAttr = m_SProgram->attributeLocation("aColor");
    qDebug() << m_colAttr;
    m_modelToPerspUni = m_SProgram->uniformLocation("u_modelPersp_matrix");
    qDebug() << m_modelToPerspUni;
}

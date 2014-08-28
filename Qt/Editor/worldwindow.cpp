// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  An OpenGL ES 2.0 window. This object is in charge of rendering all data
//  that is in the game world.
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
//
//  CURRENT NOTES:
//  - When going to full screen, the editor cannot close
//  - Think about adding code that detects for online shader compilation, and
//      create shader objects accordingly to the machine's specs.
//
//
//
//
// -----------------------------------------------------------------------------

#include "worldwindow.h"
#include <QCoreApplication>
#include <QScreen>
#include <QPainter>
#include <qopengl.h>
#include <QOpenGLContext>
#include <QOpenGLPaintDevice>
#include <QEvent>
#include <QExposeEvent>
#include <QOpenGLShaderProgram>
#include <QMatrix>

// -----------------------------------------------------------------------------
WorldWindow::WorldWindow(QWindow *parent) :
    QWindow(parent),
    QOpenGLFunctions(),
    m_UpdatePending(false),
    m_Animating(false),
    m_Context(0),
    m_PaintDevice(0),
    m_SProgram(0),
    m_yRot(0.0f)
{
    //The window needs to know that the context of painting is in OpenGL
    //This is so we don't use QPainter or QBackingStore to paint, only GL
    QWindow::setSurfaceType(QWindow::OpenGLSurface);
    this->create();

    QSurfaceFormat format;
    format.setSamples(16);

    setFormat(format);

    //init context
    m_Context = new QOpenGLContext(this);
    m_Context->setFormat(requestedFormat());
    m_Context->create();


}

WorldWindow::~WorldWindow()
{

}

// -----------------------------------------------------------------------------
void WorldWindow::initialize()
{
    //init the gl functions
    m_Context->makeCurrent(this);
    initializeOpenGLFunctions();

    //Create shader program and load, attach and bind shaders
    m_SProgram = new QOpenGLShaderProgram(this);

    m_SProgram->addShaderFromSourceFile(QOpenGLShader::Vertex,
                                        QString(":/Resources/Shaders/vs_sample.vsh"));

    m_SProgram->addShaderFromSourceFile(QOpenGLShader::Fragment,
                                        QString(":/Resources/Shaders/sample.fsh"));

    //An optimization to the above would be to load shader in binary format with
    //  glShaderBinary();

    //Linking occurs once all shaders have been attahced
    if(!m_SProgram->link())
    {
        qDebug() << QString("could not link");
    }

    //To check if the program will work with the current state of the GL
    //state machine, use the following line on the shader program
    //glValidateProgram(m_SProgram->programId());
    //The documentation states that it is slow, so it should not be used
    //  during a release build. It should only be used during debugging
    //  stages.

    //Use this to check if this version of GL ES 2.0 supports online shader
    //  compilation
    //glGetBooleanv(GL_SHADER_COMPILER,);

    //Let's store the index of each of the program's attributes
    m_posAttr = m_SProgram->attributeLocation("aPosition");
    qDebug() << "aPosition = " << m_posAttr;
    m_colAttr = m_SProgram->attributeLocation("aColor");
    qDebug() << "aColor = " << m_colAttr;

    //Let's get each of the uniforms
    m_modelToPerspUni = m_SProgram->uniformLocation("u_modelPersp_matrix");
    qDebug() << "uModelToPerspMat = " << m_modelToPerspUni;

    //init the device where we will paint
    //For some reason, I need to initialize this here.
    // TODO: look into why laters
    m_PaintDevice = new QOpenGLPaintDevice();

    glClearColor(1.0f,1.0f,1.0f,1.0f);

    m_worldToView.setToIdentity();
    //qDebug() << m_worldToView;

    m_viewToPerps.perspective(60.0f, 4.0f/3.0f, 0.1f, 100.0f);
    //qDebug() << m_viewToPerps;

    glFrontFace(GL_CCW);
    glCullFace(GL_BACK);
}


void WorldWindow::render()
{
    qDebug() << "render()";

    //make this the current context
    m_Context->makeCurrent(this);

    //Clear the screen before any rendering
    glClear(GL_COLOR_BUFFER_BIT |
            GL_DEPTH_BUFFER_BIT |
            GL_STENCIL_BUFFER_BIT);

    //Make sure the device is as big as the screen
    //Set the viewport
    m_PaintDevice->setSize(this->size());

    //Set coordinate plane to upper left hand
    //glViewport(this->size().width(), this->size().height(),
    //           this->size().width(), this->size().height());

    //Make the painter to draw on the surface
    QPainter painter(m_PaintDevice);
    render(&painter);

    m_Context->swapBuffers(this);
}

void WorldWindow::render(QPainter*)
{
    qDebug() << "render(QPainter*)";

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

    GLuint offset = 0;
    GLuint vboIDs[2] = {0};

    m_SProgram->bind();


//-----------------------------------------------------------------------------

    //Setting matrix data
    m_modelToWorld.setToIdentity();
    m_modelToWorld.translate(0.0f,0.0f,-10.0);
    m_modelToWorld.rotate(m_yRot,QVector3D(0.0f,1.0f,0.0f));
    m_modelToWorld.rotate(m_yRot,QVector3D(1.0f,0.0f,0.0f));
    m_modelToWorld.scale(3);
    //qDebug() << m_modelToWorld;

    m_yRot += 0.5f;

    m_modelToPersp = m_viewToPerps * (m_worldToView * m_modelToWorld);

    //Update uniform values
    m_SProgram->setUniformValue(m_modelToPerspUni,m_modelToPersp);

//-----------------------------------------------------------------------------
    //Generate vertex buffer object names
    glGenBuffers(2,vboIDs);

    GLint vtxStride = sizeof(GLfloat) * VERTEX_POS_SIZE +
                      sizeof(GLfloat) * VERTEX_COLOR_SIZE;

    //Bind buffers and set their data
    glBindBuffer(GL_ARRAY_BUFFER,vboIDs[0]);
    glBufferData(GL_ARRAY_BUFFER,
                 vtxStride * numOfVerts,
                 vertexData,
                 GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,vboIDs[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                 numOfIndeces * sizeof(GLushort),
                 indices,
                 GL_STATIC_DRAW);

//-----------------------------------------------------------------------------
    //Enable the vertex attribute array
    glEnableVertexAttribArray(m_posAttr);
    glEnableVertexAttribArray(m_colAttr);

    //Load the vertex data to specific indexes in the shader program
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
    //offset += VERTEX_COLOR_SIZE * sizeof(GLfloat);

    //m_SProgram->bindAttributeLocation("aPosition",VERTEX_POS_INDX);
    //m_SProgram->bindAttributeLocation("aColor",VERTEX_COLOR_INDX);

//-----------------------------------------------------------------------------
    //Have graphics card draw what is attached to the VBOs
    glEnable(GL_CULL_FACE);

    glDrawElements(GL_TRIANGLES,
                   numOfIndeces,
                   GL_UNSIGNED_SHORT,
                   0);

    //Disable arrays
    glDisableVertexAttribArray(m_colAttr);
    glDisableVertexAttribArray(m_posAttr);

    glDeleteBuffers(2,vboIDs);

    m_SProgram->release();
}

void WorldWindow::setAnimating(bool animating)
{
    m_Animating = animating;

    if(animating == true)
    {
        this->renderLater();
    }
}

// -----------------------------------------------------------------------------

void WorldWindow::renderLater()
{
    if(m_UpdatePending == false)
    {
        m_UpdatePending = true;
        QCoreApplication::postEvent(this,new QEvent(QEvent::UpdateRequest));
    }
}

void WorldWindow::renderNow()
{
    qDebug() << "renderNow";

    if (!isExposed())
        return;

    render();

    if (m_Animating)
    {
        renderLater();
    }
}

// -----------------------------------------------------------------------------

bool WorldWindow::event(QEvent * event)
{
    switch(event->type())
    {
        case QEvent::UpdateRequest:
        {
            qDebug() << "event(QEvent::UpdateRequested)";
            m_UpdatePending = false;
            renderNow();            
            return true;
        }
        default:
        {
            return QWindow::event(event);
        }

    }
}

void WorldWindow::exposeEvent(QExposeEvent *)
{
    //Only render if the editor is exposed
    if(this->isExposed())
    {
        renderNow();
    }
}

// -----------------------------------------------------------------------------

void Debug_QueryShaderCompiler()
{
    GLboolean shaderCompiler;
    GLint numBinaryFormats;
    GLint *formats;

    /*
    //Determine if a shader compiler is available
    glGetBooleanv(GL_SHADER_COMPILER,&shaderCompiler);

    //Determine binary format available
    glGetIntegerv(GL_NUM_SHADER_BINARY_FORMATS,&numBinaryFormats);
    formats = new int[numBinaryFormats];

    glGetIntegerv(GL_SHADER_BINARY_FORMATS,formats);

    qDebug() << formats;

    delete [] formats;
    */
}



// -----------------------------------------------------------------------------

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
#include "model.h"
#include "composite.h"
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
#include <QVector>

// -----------------------------------------------------------------------------
WorldWindow::WorldWindow(QWindow *parent) :
    QWindow(parent),
    QOpenGLFunctions(),
    m_SelfMethods(NULL),
    m_UpdatePending(false),
    m_Animating(false),
    m_Context(0),
    m_PaintDevice(0),
    m_SProgram(0),
    m_yRot(0.0f),
    m_glMask(),
    m_WorldObjects(NULL)
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
    m_Context->makeCurrent(this);
    initializeOpenGLFunctions();
    m_glMask.m_gl.initializeOpenGLFunctions();

    m_SProgram = new QOpenGLShaderProgram(this);

    m_SProgram->addShaderFromSourceFile(QOpenGLShader::Vertex,
                                        QString(":/Resources/Shaders/vs_sample.vsh"));

    m_SProgram->addShaderFromSourceFile(QOpenGLShader::Fragment,
                                        QString(":/Resources/Shaders/sample.fsh"));

    //Linking occurs once all shaders have been attahced
    if(!m_SProgram->link())
    {
        qDebug() << QString("could not link");
    }

    m_posAttr = m_SProgram->attributeLocation("aPosition");
    m_colAttr = m_SProgram->attributeLocation("aColor");
    m_modelToPerspUni = m_SProgram->uniformLocation("u_modelPersp_matrix");
    qDebug() << "uModelToPerspMat = " << m_modelToPerspUni;

    //init the device where we will paint
    //For some reason, I need to initialize this here.
    // TODO: look into why laters
    m_PaintDevice = new QOpenGLPaintDevice();

    glClearColor(1.0f,1.0f,1.0f,1.0f);

    m_worldToView.setToIdentity();
    m_viewToPerps.perspective(60.0f, 4.0f/3.0f, 0.1f, 100.0f);

    glFrontFace(GL_CCW);
    glCullFace(GL_BACK);

    m_SelfMethods = dynamic_cast<QOpenGLFunctions*>(this);
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

    m_PaintDevice->setSize(this->size());

    //Make the painter to draw on the surface
    QPainter painter(m_PaintDevice);
    render(&painter);

    m_Context->swapBuffers(this);
}

void WorldWindow::render(QPainter*)
{
    qDebug() << "render(QPainter*)";

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

    //Do the above for ALL models
    if(m_WorldObjects)
    {
        int objectsSize = (*m_WorldObjects).size();
        Model* model = NULL;
        for(int i = 0; i < objectsSize; ++i)
        {
            model = dynamic_cast<Model*>(((*m_WorldObjects)[i])->GetComponent("Model"));
            if(model)
            {
                model->ReceiveGL(m_SelfMethods);
                model->DrawPrep();
            }
        }
    }

//-----------------------------------------------------------------------------
    //Enable the vertex attribute array
    glEnableVertexAttribArray(m_posAttr);
    glEnableVertexAttribArray(m_colAttr);

    //Load the vertex data to specific indexes in the shader program
    GLint vtxStride = sizeof(GLfloat) * VERTEX_POS_SIZE +
                      sizeof(GLfloat) * VERTEX_COLOR_SIZE;
    GLuint offset = 0;
    GLuint numOfIndeces = 36;

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

//-----------------------------------------------------------------------------
    //Have graphics card draw what is attached to the VBOs
    glEnable(GL_CULL_FACE);

    if(m_WorldObjects)
    {
        int objectsSize = (*m_WorldObjects).size();
        Model* model = NULL;
        for(int i = 0; i < objectsSize; ++i)
        {
            model = dynamic_cast<Model*>(((*m_WorldObjects)[i])->GetComponent("Model"));
            if(model)
            {
                model->Draw();
            }
        }
    }

    //Disable arrays
    glDisableVertexAttribArray(m_colAttr);
    glDisableVertexAttribArray(m_posAttr);

    if(m_WorldObjects)
    {
        int objectsSize = (*m_WorldObjects).size();
        Model* model = NULL;
        for(int i = 0; i < objectsSize; ++i)
        {
            model = dynamic_cast<Model*>(((*m_WorldObjects)[i])->GetComponent("Model"));
            if(model)
            {
                model->PostDraw();
            }
        }
    }

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

            //emit the signal that requests the world data
            emit requestWorldData();

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

void WorldWindow::Debug_QueryShaderCompiler()
{
    //GLboolean shaderCompiler;
    //GLint numBinaryFormats;
    //GLint *formats;

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

void WorldWindow::receiveWorldData(QVector<Composite *>* worldObjects)
{
    //store the world objects
    m_WorldObjects = worldObjects;
}

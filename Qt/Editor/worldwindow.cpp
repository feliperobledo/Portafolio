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
#include "component.h"
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

    //init the device where we will paint
    //For some reason, I need to initialize this here.
    // TODO: look into why laters
    m_PaintDevice = new QOpenGLPaintDevice();

    glClearColor(1.0f,1.0f,1.0f,1.0f);

    m_worldToView.setToIdentity();
    m_viewToPerps.perspective(60.0f, 4.0f/3.0f, 0.1f, 100.0f);

    glFrontFace(GL_CCW);
    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);

    m_SelfMethods = dynamic_cast<QOpenGLFunctions*>(this);//??
}


void WorldWindow::render()
{
    //qDebug() << "render()";

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
    //qDebug() << "render(QPainter*)";
    if(m_WorldObjects)
    {
        int objectsSize = (*m_WorldObjects).size();
        Model* model = NULL;
        for(int i = 0; i < objectsSize; ++i)
        {
            model = dynamic_cast<Model*>( ( (*m_WorldObjects)[i] )->
                    GetComponent("Model",Composite::engine_component()));
            if(model)
            {
                model->ReceiveGL(m_SelfMethods);
                model->DrawPrep(m_worldToView,m_viewToPerps);
                model->Draw();
                model->PostDraw();
            }
        }
    }  
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
    //qDebug() << "renderNow";

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
            //qDebug() << "event(QEvent::UpdateRequested)";
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

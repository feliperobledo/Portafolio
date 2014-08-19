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
// -----------------------------------------------------------------------------

#include "worldwindow.h"
#include <QCoreApplication>
#include <QPainter>
#include <QOpenGLContext>
#include <QOpenGLPaintDevice>
#include <QEvent>
#include <QExposeEvent>


// -----------------------------------------------------------------------------
WorldWindow::WorldWindow(QWindow *parent) :
    QWindow(parent),
    QOpenGLFunctions(),
    m_UpdatePending(false),
    m_Animating(false),
    m_Context(0),
    m_PaintDevice(0)
{
    //The window needs to know that the context of painting is in OpenGL
    //This is so we don't use QPainter or QBackingStore to paint, only GL
    QWindow::setSurfaceType(QWindow::OpenGLSurface);
}

WorldWindow::~WorldWindow()
{

}

// -----------------------------------------------------------------------------
void WorldWindow::initialize()
{
    this->glClearColor(0.2,0.2,0.2,1);
}


void WorldWindow::render()
{
    if(m_PaintDevice == 0)
    {
        m_PaintDevice = new QOpenGLPaintDevice;
    }

    //Clear the screen before any rendering
    glClear(GL_COLOR_BUFFER_BIT |
            GL_DEPTH_BUFFER_BIT |
            GL_STENCIL_BUFFER_BIT);

    //Make sure the device is as big as the screen
    m_PaintDevice->setSize(this->size());

    //Make the painter to draw on the surface
    QPainter painter(m_PaintDevice);
    render(&painter);
}

void WorldWindow::render(QPainter*)
{

    glBegin(GL_TRIANGLES);
        glColor3f(1,0,0);
        glVertex3f( 0.0,  0.5,  0.0);
        glColor3f(0,1,0);
        glVertex3f(-0.5, -0.5,  0.0);
        glColor3f(0,0,1);
        glVertex3f( 0.5, -0.5,  0.0);
    glEnd();
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
    if (!isExposed())
        return;

    bool needsInitialize = false;

    if (!m_Context)
    {
        m_Context = new QOpenGLContext(this);
        m_Context->setFormat(requestedFormat());
        m_Context->create();

        needsInitialize = true;
    }

    m_Context->makeCurrent(this);

    if (needsInitialize)
    {
        initializeOpenGLFunctions();
        initialize();
    }

    render();

    m_Context->swapBuffers(this);

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

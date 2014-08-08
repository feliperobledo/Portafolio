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
    m_GLFunctions(),
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
    if(m_PaintDevice != 0)
    {
        delete m_PaintDevice;
    }
}

// -----------------------------------------------------------------------------
void WorldWindow::initialize()
{
    if(m_PaintDevice == 0)
    {
        m_PaintDevice = new QOpenGLPaintDevice;
    }

    if(m_Context == 0)
    {
        m_Context = new QOpenGLContext;
    }
}


void WorldWindow::render()
{
    //Clear the screen before any rendering
    m_GLFunctions.glClear(GL_COLOR_BUFFER_BIT |
                          GL_DEPTH_BUFFER_BIT |
                          GL_STENCIL_BUFFER_BIT);

    //Make sure the device is as big as the screen
    m_PaintDevice->setSize(this->size());

    //Make the painter to draw on the surface
    QPainter painter(m_PaintDevice);
    render(&painter);
}

void WorldWindow::render(QPainter* painter)
{

}

void WorldWindow::setAnimating(bool animating)
{

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

}

// -----------------------------------------------------------------------------

bool WorldWindow::event(QEvent *)
{
    return false;
}

void WorldWindow::exposeEvent(QExposeEvent *)
{

}

// -----------------------------------------------------------------------------

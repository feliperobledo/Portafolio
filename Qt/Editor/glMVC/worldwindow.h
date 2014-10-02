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

#ifndef WORLDWINDOW_H
#define WORLDWINDOW_H

#include <QWindow>
#include <QOpenGLFunctions>
#include <QVector>
#include <QMatrix4x4>
#include "BypassGL.h"

// -----------------------------------------------------------------------------

class QPainter;
class QOpenGLContext;
class QOpenGLPaintDevice;
class QOpenGLShaderProgram;
class QEvent;
class QExposeEvent;

// -----------------------------------------------------------------------------

class Composite;
class Model;

// -----------------------------------------------------------------------------

#define VERTEX_POS_SIZE 3      //x,y,z
#define VERTEX_COLOR_SIZE 4    //r,g,b,a

#define VERTEX_POS_INDX 0
#define VERTEX_COLOR_INDX 3

// -----------------------------------------------------------------------------

class WorldWindow : public QWindow, protected QOpenGLFunctions
{
    Q_OBJECT

public:
    explicit WorldWindow(QWindow* parent = 0);
    ~WorldWindow();

    /*Virtual dependencies*/
    virtual void initialize();
    virtual void render();
    virtual void render(QPainter* painter);

    void setAnimating(bool animating);

public slots:
    void renderLater();
    void renderNow();

signals:

protected:
    bool event(QEvent *);
    void exposeEvent(QExposeEvent *);

private:
    QOpenGLFunctions* m_SelfMethods;
    bool m_UpdatePending;
    bool m_Animating;

    QOpenGLContext*    m_Context;
    QOpenGLPaintDevice* m_PaintDevice;

    QMatrix4x4 m_worldToView;
    QMatrix4x4 m_viewToPerps;
    QMatrix4x4 m_modelToPersp;

    QOpenGL_ m_glMask;

    QVector<Model*> m_Models;

    QVector<Composite *>* m_WorldObjects;

public slots:
    void receiveWorldData(QVector<Composite *>*);

signals:
    void requestWorldData();

private:
    void Debug_QueryShaderCompiler();
};

#endif // WORLDWINDOW_H

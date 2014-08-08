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

class QPainter;
class QOpenGLContext;
class QOpenGLPaintDevice;
class QEvent;
class QExposeEvent;

class WorldWindow : public QWindow
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
    bool m_UpdatePending;
    bool m_Animating;

    QOpenGLFunctions   m_GLFunctions;
    QOpenGLContext*    m_Context;
    QOpenGLPaintDevice* m_PaintDevice;

};

#endif // WORLDWINDOW_H

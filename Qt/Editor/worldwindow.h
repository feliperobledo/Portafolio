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
#include <vector>


class QPainter;
class QOpenGLContext;
class QOpenGLPaintDevice;
class QOpenGLShaderProgram;
class QEvent;
class QExposeEvent;

// -----------------------------------------------------------------------------

#define VERTEX_POS_SIZE 3
#define VERTEX_NORMAL_SIZE 3
#define VERTEX_TEXCOORD0_SIZE 2
#define VERTEX_TEXCOORD1_SIZE 2

// x, y and z // x, y and z // s and t
// s and t
#define VERTEX_POS_INDX 0
#define VERTEX_NORMAL_INDX 1
#define VERTEX_TEXCOORD0_INDX 2
#define VERTEX_TEXCOORD1_INDX 3

// the following 4 defines are used to determine location of various array
// attributes if vertex data is are stored as an array of structures
#define VERTEX_POS_OFFSET 0
#define VERTEX_NORMAL_OFFSET 3
#define VERTEX_TEXCOORD0_OFFSET 6
#define VERTEX_TEXCOORD1_OFFSET 8

#define VERTEX_ATTRIB_SIZE VERTEX_POS_SIZE + \ VERTEX_NORMAL_SIZE + \
VERTEX_TEXCOORD0_SIZE + \ VERTEX_TEXCOORD1_SIZE

//Here we use the Array of structures model, where all data is stored in one
//array.
struct VertexAttributes
{
    //use GL_HALF_FLOAT_OES for normals, binormals, tangent vectors, UV
    //  note that the above may not be possible
    //use GL_UNSIGNED_BYTE for color
    //can use GL_FIXED for vertex positions
    std::vector<float> m_VertData;
};

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
    bool m_UpdatePending;
    bool m_Animating;

    QOpenGLContext*    m_Context;
    QOpenGLPaintDevice* m_PaintDevice;
    QOpenGLShaderProgram* m_SProgram;
    GLuint m_ProgramObject;

    GLint m_posAttr;
    GLint m_colAttr;
    GLint m_matrixUniform;

private:
    void Debug_QueryShaderCompiler();

};

#endif // WORLDWINDOW_H

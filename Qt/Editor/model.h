#ifndef MODEL_H
#define MODEL_H

#include "IComponent.h"
#include <QString>
#include <QJsonDocument>

#define VERTEX_POS_SIZE 3      //x,y,z
#define VERTEX_COLOR_SIZE 4    //r,g,b,a

#define VERTEX_POS_INDX 0
#define VERTEX_COLOR_INDX 3

#define VBO_ID_COUNT 2

struct QOpenGL_;
struct GLData;
class QOpenGLFunctions;

class Model : public IComponent
{
public:
    Model();
    virtual void Initialize(const char*);
    virtual void Free();
    virtual ~Model();

    void DrawPrep();
    void Draw();
    void PostDraw();
    void ReceiveGL(QOpenGLFunctions *glMethods);

    void LoadModel(const QJsonDocument& jsonDocument);

private:
    QString m_ModelFile;
    GLData* m_glData;
    QOpenGLFunctions * m_glMethods;

private:
    void GenerateVBOs();
    void CloseVBOs();
};

#endif // MODEL_H

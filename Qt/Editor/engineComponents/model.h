#ifndef MODEL_H
#define MODEL_H

#include "../core/EngineComponent.h"
#include <QString>
#include <QJsonDocument>
#include <QOpenGLFunctions>

#define VERTEX_POS_SIZE 3      //x,y,z
#define VERTEX_COLOR_SIZE 4    //r,g,b,a

#define VERTEX_POS_INDX 0
#define VERTEX_COLOR_INDX 3

#define VBO_ID_COUNT 2

struct QOpenGL_;
struct GLData;
class QOpenGLShaderProgram;

class Model : public EngineComponent
{
    Q_OBJECT

public:
    explicit Model(QObject* parent = NULL);
    virtual void Initialize(const char*);
    virtual void Free();
    virtual void ChangeData(const QString& member, const QVariant& data);
    virtual ~Model();

    void DrawPrep(const QMatrix4x4 &worldView, const QMatrix4x4 viewPerspective);
    void Draw();
    void PostDraw();
    void ReceiveGL(QOpenGLFunctions *glMethods);

    void LoadModel(const QJsonDocument& jsonDocument);


private:
    QString m_ModelFile;
    GLData* m_glData;
    QOpenGLFunctions * m_glMethods;

    GLint m_posAttr;
    GLint m_colAttr;
    GLint m_modelToPerspUni;

    QOpenGLShaderProgram* m_SProgram;
    GLuint m_ProgramObject;

private:
    void GenerateVBOs();
    void CloseVBOs();
    void InitShaderProgram();
};

#endif // MODEL_H

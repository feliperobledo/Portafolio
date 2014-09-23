#ifndef TRANSFORM_H
#define TRANSFORM_H

#include <QMatrix4x4>
#include <QVector3D>
#include "EngineComponent.h"
#include "component.h"

class Transform : public EngineComponent
{
    Q_OBJECT
public:
    explicit Transform(QObject* parent = NULL);

    virtual void Initialize(const char*);
    virtual void Free();
    virtual void ChangeData(const QString& member, const QVariant& data);
    virtual ~Transform();

    void Position (const QVector3D &);
    void Scale (const QVector3D &);
    void Rotation (const QVector3D &);

    const QVector3D &Position() const;
    const QVector3D    &Scale() const;
    const QVector3D &Rotation() const;

    QMatrix4x4 GetMatrix() const;

    void SetMember(QVector3D &member, const QVariant& data);
private:
    QVector3D m_pos;
    QVector3D  m_scale;
    QVector3D  m_rotation;
};

#endif // TRANSFORM_H

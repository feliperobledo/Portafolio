#ifndef TRANSFORM_H
#define TRANSFORM_H

#include <QMatrix4x4>
#include <QVector3D>
#include "IComponent.h"

class Transform : public IComponent
{
public:
    Transform();

    virtual void Initialize(const char*);
    virtual void Free();
    virtual ~Transform();

    void Position (const QVector3D &);
    void    Scale (const QMatrix4x4 &);
    void Rotation (const QMatrix4x4 &);

    const QVector3D &Position() const;
    const QMatrix4x4    &Scale() const;
    const QMatrix4x4 &Rotation() const;

    QMatrix4x4 GetMatrix() const;
private:
    QVector3D m_pos;
    QMatrix4x4 m_scale;
    QMatrix4x4 m_rotation;
};

#endif // TRANSFORM_H

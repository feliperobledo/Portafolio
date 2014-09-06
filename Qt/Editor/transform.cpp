#include "transform.h"

Transform::Transform() : IComponent()
{
}

Transform::~Transform()
{

}

void Transform::Initialize(const char*)
{
    m_pos.setX(0.0f);
    m_pos.setY(0.0f);
    m_pos.setZ(-10.0f);
}

void Transform::Free()
{

}

void Transform::Position (const QVector3D & pos)
{
    m_pos = pos;
}

void    Transform::Scale (const QMatrix4x4 & scale)
{
    m_scale = scale;
}

void Transform::Rotation (const QMatrix4x4 & rotation)
{
    m_rotation = rotation;
}

const QVector3D &Transform::Position() const
{
    return m_pos;
}

const QMatrix4x4    &Transform::Scale() const
{
    return m_scale;
}

const QMatrix4x4 &Transform::Rotation() const
{
    return m_rotation;
}

QMatrix4x4 Transform::GetMatrix() const
{
    QMatrix4x4 translation;
    translation.translate(m_pos);

    return translation * (m_rotation * m_scale);
}

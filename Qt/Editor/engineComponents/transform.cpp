#include "transform.h"
#include <QList>

Transform::Transform(QObject *parent) :
    EngineComponent(parent)
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

    m_scale.setX(5.0f);
    m_scale.setY(5.0f);
    m_scale.setZ(5.0f);
}

void Transform::Free()
{

}

void Transform::ChangeData(const QString& member, const QVariant& data)
{
    Q_UNUSED(member); Q_UNUSED(data);

    if(member == "Scale")
    {
        SetMember(m_scale,data);
    }
    else if(member == "Translate")
    {
        SetMember(m_pos,data);
    }
    else
    {
        SetMember(m_rotation,data);
    }
}

void Transform::Position (const QVector3D & pos)
{
    m_pos = pos;
}

void Transform::Scale (const QVector3D &scale)
{
    m_scale = scale;
}

void Transform::Rotation (const QVector3D &rotation)
{
    m_rotation = rotation;
}

const QVector3D &Transform::Position() const
{
    return m_pos;
}

const QVector3D &Transform::Scale() const
{
    return m_scale;
}

const QVector3D &Transform::Rotation() const
{
    return m_rotation;
}

QMatrix4x4 Transform::GetMatrix() const
{
    QMatrix4x4 transformation;
    transformation.translate(m_pos);
    //Should use quaternions for the following
    transformation.rotate(m_rotation.z(),QVector3D(0.0f,0.0f,1.0f));
    transformation.rotate(m_rotation.y(),QVector3D(0.0f,1.0f,0.0f));
    transformation.rotate(m_rotation.x(),QVector3D(1.0f,0.0f,0.0f));
    transformation.scale(m_scale);

    return transformation;
}

void Transform::SetMember(QVector3D& member,const QVariant& data)
{
    QList<QVariant> dataList(data.toList());
    member.setX( dataList[0].toFloat() );
    member.setY( dataList[1].toFloat() );
    member.setZ( dataList[2].toFloat() );
}

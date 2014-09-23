#ifndef COMPONENT_H
#define COMPONENT_H

/*                              IMPORTANT                                     */
//I think I am going to have to switch everything into a Q_OBJECT because
//changes to to a model could signify a change to either the Transform or
//Model components

#include "attribmodel.h"
#include <QObject>
#include <QVariant>
#include <QString>
#include <QMap>

class EngineComponent;

//Assignment macro for new engine components
#define NEW_ENGINE_SIGNAL(engineComponentName)\
    void new_##engineComponentName##_Data(const QString&,const QVariant&)

class Component : public QObject
{
    Q_OBJECT

public:
    struct TypeArchetype
    {
        QString m_TypeName;
        QString m_Value;
    };

    explicit Component(const QString& name,EngineComponent *c = NULL,QObject* parent = NULL);
    virtual ~Component();

    void Initialize();

    bool IsEngineComponent() const;
    EngineComponent *GetComponentPtr();
    const EngineComponent *GetComponentPtr() const;
    void SetEngineComponentPtr(EngineComponent* ptr);

    void AddAttribute(const QString& name, const QString &type);
    AttribModel *GetAttributes();

signals:

public slots:
    void receiveDataChanged(const QString&,const QVariant&);

private:
    EngineComponent* engineComponent;

    //Every component knows about its attributes
    QMap<QString,AttribModel::Attribute> m_Attributes;

    //m_TypeDefaults;
    AttribModel m_AttribModel;
};

#endif // COMPONENT_H

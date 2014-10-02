#ifndef COMPONENTMODEL_H
#define COMPONENTMODEL_H

#include "idatamodel.h"
#include <QString>
#include <QVector>
#include <QVariant>
#include <QHash>

class Component;

class ComponentModel : public IDataModel
{
public:
    struct Attribute
    {
        QString m_Type;
        QString m_Name;
    };

    typedef QVector<Attribute> Attributes;
    typedef QHash<QString,Attributes > ComponentData;

    ComponentModel();

    virtual void Initialize(const QString& initFile);
    virtual void Free();
    virtual ~ComponentModel();

    bool NewComponent(const QString& componentName);
    bool ComponentNameExists(const QString& componentName);
    Component* CreateComponent(const QString& componentName);

private:
    //Knows the component and the name of its attributes
    ComponentData m_ComponentNames;
};

#endif // COMPONENTMODEL_H

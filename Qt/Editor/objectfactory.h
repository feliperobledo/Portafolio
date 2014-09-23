#ifndef OBJECTFACTORY_H
#define OBJECTFACTORY_H


#include "EngineComponent.h"
#include "composite.h"
#include <QHash>
#include <QString>

class QObject;

//-----------------------------------------------------------------------------

class EngineComponentFactory
{
    public:
    virtual EngineComponent* create() const = 0;
};

template <typename T>
class ComponentFactory : public EngineComponentFactory
{
    public:
        virtual EngineComponent* create() const
        {
            return new T();
        }
};

//-----------------------------------------------------------------------------

class ObjectFactory
{
public:
    ObjectFactory();
    Composite* newComposite() const;
    EngineComponent* newComponent(const QString& componentName);
    void ObjectAddComponent(Composite* obj,const QString& componentName);

    template <typename T>
    void AddComponentFactory(const QString& name)
    {
        if(m_CompFactories.find(name) == m_CompFactories.end())
        {
            ComponentFactory<T>* newFactory = new ComponentFactory<T>();
            m_CompFactories.insert(name,newFactory);
        }
    }

private:
    typedef QHash<QString,EngineComponentFactory*> ComponentFactories;

    ComponentFactories m_CompFactories;
};

#endif // OBJECTFACTORY_H

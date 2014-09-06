#ifndef OBJECTFACTORY_H
#define OBJECTFACTORY_H


#include "IComponent.h"
#include "composite.h"
#include <QHash>
#include <QString>


//-----------------------------------------------------------------------------

class IComponentFactory
{
    public:
    virtual IComponent* create() const = 0;
};

template <typename T>
class ComponentFactory : public IComponentFactory
{
    public:
        virtual IComponent* create() const
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
    IComponent* newComponent(const QString& componentName);
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
    typedef QHash<QString,IComponentFactory*> ComponentFactories;

    ComponentFactories m_CompFactories;
};

/*
template <typename T>
void ObjectFactory::AddComponentFactory(const QString& name)
{
    if(m_CompFactories.find(name) == m_CompFactories.end())
    {
        ComponentFactory<T>* newFactory = new ComponentFactory<T>();
        m_CompFactories.insert(name,newFactory);
    }
}
*/

#endif // OBJECTFACTORY_H

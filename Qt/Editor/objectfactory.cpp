#include "objectfactory.h"

ObjectFactory::ObjectFactory()
{
}

Composite* ObjectFactory::newComposite() const
{
    return new Composite();
}

IComponent* ObjectFactory::newComponent(const QString& componentName)
{
    return m_CompFactories[componentName]->create();
}

void ObjectFactory::ObjectAddComponent(Composite *obj, const QString& componentName)
{
    if(obj->m_ComponentList.find(componentName) == obj->m_ComponentList.end())
    {
        IComponentFactory* factory = this->m_CompFactories[componentName];
        IComponent* newComponent = factory->create();
        obj->m_ComponentList.insert(componentName,newComponent);
    }
}

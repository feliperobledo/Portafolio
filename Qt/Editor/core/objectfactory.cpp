#include "objectfactory.h"
#include "component.h"

ObjectFactory::ObjectFactory()
{
}

Composite* ObjectFactory::newComposite() const
{
    return new Composite();
}

EngineComponent *ObjectFactory::newComponent(const QString& componentName)
{
    return m_CompFactories[componentName]->create();
}

void ObjectFactory::ObjectAddComponent(Composite *obj, const QString& componentName)
{
    if(obj->m_ComponentList.find(componentName) == obj->m_ComponentList.end())
    {
        EngineComponentFactory* factory = this->m_CompFactories[componentName];
        EngineComponent* newComponent = factory->create();
        obj->m_ComponentList[componentName]->SetEngineComponentPtr(newComponent);
    }
}

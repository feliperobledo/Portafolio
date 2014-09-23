#include "composite.h"
#include "component.h"
#include <QDebug>

Composite::Composite(QObject *parent)
    :QObject(parent)
{

}

Composite::~Composite()
{

}

Composite::Composite(const Archetype& ar,QObject *parent):
    QObject(parent)
{
    Q_UNUSED(ar);
}


Composite::Composite(const Composite& rhs) :
    QObject(rhs.parent()),
    m_ArchetypeName(rhs.m_ArchetypeName)
{

}

void Composite::Initialize()
{
    Components::iterator iter = m_ComponentList.begin();
    for(; iter != m_ComponentList.end(); ++iter)
    {
        iter.value()->Initialize();
    }
    setObjectName("NewObject");
}

void Composite::Free()
{
    //Barebone deletion instructions
    //Should look into a memory manager optimization in the future
    qDebug() << "Composite::Free";    
    if(!m_ComponentList.empty())
    {
        Components::iterator iter = m_ComponentList.begin();
        for(; iter != m_ComponentList.end(); ++iter)
        {
            if(iter.value() != NULL)
            {
                delete iter.value();
                iter.value() = NULL;
            }
        }
        m_ComponentList.clear();
    }
}

Component *Composite::GetComponent(const QString& name)
{
    Components::iterator iter = m_ComponentList.find(name);
    if(iter != m_ComponentList.end())
    {
       return iter.value();
    }
    return NULL;
}

EngineComponent* Composite::GetComponent(const QString& name,engine_component)
{
    Components::iterator iter = m_ComponentList.find(name);
    if(iter != m_ComponentList.end())
    {
        Component* comp = iter.value();
        if(comp->IsEngineComponent())
        {
            return comp->GetComponentPtr();
        }
    }
    return NULL;
}

const EngineComponent* Composite::GetComponent(const QString& name,engine_component) const
{
    Components::const_iterator iter = m_ComponentList.find(name);
    if(iter != m_ComponentList.end())
    {
        const Component* comp = iter.value();
        if(comp->IsEngineComponent())
        {
            return comp->GetComponentPtr();
        }
    }
    return NULL;
}

const Component *Composite::GetComponent(const QString& name) const
{
    Components::const_iterator iter = m_ComponentList.find(name);
    if(iter != m_ComponentList.end())
    {
       return iter.value();
    }
    return NULL;
}

const Composite::Components& Composite::GetComponentList() const
{
    return m_ComponentList;
}

void Composite::AddComponent(Component* newComponent)
{
    m_ComponentList.insert(newComponent->objectName(),newComponent);
    newComponent->setParent(this);
}

//-----------------------------------------------------------------------------

void Composite::NewChild(Composite* child)
{
    m_Children.append(child);
}

Composite::CompositeList& Composite::Children(void)
{
    return m_Children;
}

//-----------------------------------------------------------------------------

Composite Composite::operator=(const Composite&) const
{
    return *this;
}

Composite& Composite::operator=(const Composite&)
{
    return *this;
}

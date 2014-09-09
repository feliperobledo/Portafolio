#include "composite.h"
#include <QDebug>

void Composite::Initialize()
{
    Components::iterator iter = m_ComponentList.begin();
    for(; iter != m_ComponentList.end(); ++iter)
    {
        iter.value()->Initialize("");
    }
    m_Name = "NewObject";
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

IComponent* Composite::GetComponent(const QString& name)
{
    Components::iterator iter = m_ComponentList.find(name);
    if(iter != m_ComponentList.end())
    {
       return iter.value();
    }
    return NULL;
}

const IComponent* Composite::GetComponent(const QString& name) const
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

//-----------------------------------------------------------------------------

void Composite::Owner(Composite* owner)
{
    m_Owner = owner;
}

Composite* Composite::Owner(void)
{
    return m_Owner;
}

const Composite* Composite::Owner(void) const
{
    return m_Owner;
}

void Composite::NewChild(Composite* child)
{
    m_Children.append(child);
}

Composite::CompositeList& Composite::Children(void)
{
    return m_Children;
}

//-----------------------------------------------------------------------------

Composite::Composite()
{

}

Composite::~Composite()
{

}

Composite::Composite(const Archetype&, Composite* owner) :
    m_Owner(owner),
    m_Name("")
{

}


Composite::Composite(const Composite& rhs) :
    m_Owner(NULL),
    m_Name(rhs.m_Name),
    m_ArchetypeName(rhs.m_ArchetypeName)
{

}

Composite Composite::operator=(const Composite&) const
{
    return *this;
}

Composite& Composite::operator=(const Composite&)
{
    return *this;
}

#include "worlddatabase.h"
#include "composite.h"
#include "objectfactory.h"
#include "model.h"
#include "transform.h"
#include <qalgorithms.h>

WorldDatabase::WorldDatabase()
{
}

void WorldDatabase::Free()
{
    for(int iter = 0; iter < m_WorldObjects.size(); ++iter)
    {
        m_WorldObjects[iter]->Free();
        delete m_WorldObjects[iter];
    }
}

WorldDatabase::~WorldDatabase()
{

}

void WorldDatabase::Initialize(const QString &)
{
    REGISTER_FACTORY(Model);
    REGISTER_FACTORY(Transform);
}

void WorldDatabase::NewComposite(const QString&)
{

}

void WorldDatabase::NewComposite()
{
    //create dummy object in the meantime
    Composite* newObj = this->m_Factory.newComposite();
    m_Factory.ObjectAddComponent(newObj,"Model");
    m_Factory.ObjectAddComponent(newObj,"Transform");

    newObj->Initialize();

    this->m_WorldObjects.push_back(newObj);
}

const WorldDatabase::ObjectList* WorldDatabase::WorldObjects() const
{
    return &m_WorldObjects;
}

WorldDatabase::ObjectList* WorldDatabase::WorldObjects()
{
    return &m_WorldObjects;
}

//-----------------------------------------------------------------------------

void WorldDatabase::Remove(const Composite* address)
{
    ObjectList::iterator begin = m_WorldObjects.begin(),
                         end   = m_WorldObjects.end();

    //don't know if this will work...
    end = std::remove(begin,end,address);
}

Composite* WorldDatabase::GetLastCreated(void)
{
    return m_WorldObjects.back();
}

//-----------------------------------------------------------------------------

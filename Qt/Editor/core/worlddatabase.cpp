#include "worlddatabase.h"
#include "composite.h"
#include "objectfactory.h"
#include "../engineComponents/model.h"
#include "../engineComponents/transform.h"
#include "component.h"
#include "../attributeMVC/attribmodel.h"
#include <qalgorithms.h>
#include <QList>

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

void WorldDatabase::AddComponentTo(Component* newComponent,Composite* object)
{
    //Create the component if it is an engine component, then add the component
    //to the object. Will work even if NULL
    EngineComponent* engineComponent = m_Factory.newComponent(newComponent->objectName());
    newComponent->SetEngineComponentPtr(engineComponent);
    //set component attributes to default
    SetComponentToDefault(newComponent);
    object->AddComponent(newComponent);

    //If the engine component is viable, then set its parent
    if(engineComponent)
    {
        engineComponent->setParent(object);
    }
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

void WorldDatabase::SetComponentToDefault(Component* component)
{
    AttribModel& attribModel = *(component->GetAttributes());
    QHash<QString,AttribModel::Attribute>::iterator iter = attribModel.GetData().begin();
    for(;iter != attribModel.GetData().end(); ++iter)
    {
        if(iter.value().m_Type == QString("bool"))
        {
            iter.value().m_Data = QVariant(false);
        }
        else if(iter.value().m_Type == QString("double"))
        {
            iter.value().m_Data = QVariant(0.0);
        }
        else if(iter.value().m_Type == QString("Object"))
        {
            iter.value().m_Data = QVariant("");
        }
        else if(iter.value().m_Type == QString("List"))
        {
            iter.value().m_IsList = true;
            iter.value().m_Data = QVariant("[]");
        }
        if(iter.value().m_Type == QString("String"))
        {
            iter.value().m_Data = QVariant(QString(""));
        }
        else if(iter.value().m_Type == QString("vec2"))
        {
            QList<QVariant> temp;
            for(int i = 0; i < 2; ++i)
                temp.push_back(QVariant(0.0));
            iter.value().m_IsList = true;
            iter.value().m_Data = QVariant(temp);
        }
        else if(iter.value().m_Type == QString("vec3"))
        {
            QList<QVariant> temp;
            for(int i = 0; i < 3; ++i)
                temp.push_back(QVariant(0.0));
            iter.value().m_IsList = true;
            iter.value().m_Data = QVariant(temp);
        }
        else if(iter.value().m_Type == QString("vec4"))
        {
            QList<QVariant> temp;
            for(int i = 0; i < 4; ++i)
                temp.push_back(QVariant(0.0));
            iter.value().m_IsList = true;
            iter.value().m_Data = QVariant(temp);
        }
        else if(iter.value().m_Type == QString("mat2"))
        {
            QList<QVariant> temp;
            for(int i = 0; i < 2 * 2; ++i)
                temp.push_back(QVariant(0.0));
            iter.value().m_IsList = true;
            iter.value().m_Data = QVariant(temp);
        }
        else if(iter.value().m_Type == QString("mat3"))
        {
            QList<QVariant> temp;
            for(int i = 0; i < 3 * 3; ++i)
                temp.push_back(QVariant(0.0));
            iter.value().m_IsList = true;
            iter.value().m_Data = QVariant(temp);
        }
        else if(iter.value().m_Type == QString("mat4"))
        {
            QList<QVariant> temp;
            for(int i = 0; i < 4 * 4; ++i)
                temp.push_back(QVariant(0.0));
            iter.value().m_IsList = true;
            iter.value().m_Data = QVariant(temp);
        }

    }
}

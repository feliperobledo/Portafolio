#include "component.h"
#include "enginecomponent.h"
#include "model.h"
#include "transform.h"

Component::Component(const QString &name, EngineComponent *c, QObject *parent) :
    QObject(parent),
    engineComponent(c)
{
    setObjectName(name);
}

Component::~Component()
{
    if(engineComponent)
    {
        engineComponent->Free();
    }
}

void Component::Initialize()
{
    //The following algorithm should be a generic thing to do for both components
    //that affect the visual elements and those that are simply data
    if(engineComponent)
    {
        //Initialize the engine component's data
        engineComponent->Initialize("");

        this->connect(&(this->m_AttribModel),SIGNAL(dataChanged(const QString&,const QVariant&)),
                this,SLOT(receiveDataChanged(QString,QVariant)));

        //Set the model's data to the data of the engine component
        if(dynamic_cast<Transform*>(engineComponent ) != NULL)
        {
            m_AttribModel.SetToEngineData(dynamic_cast<Transform*>(engineComponent));
        }
        else if(dynamic_cast<Model*>(engineComponent ) != NULL)
        {
           m_AttribModel.SetToEngineData(dynamic_cast<Model*>(engineComponent));
        }
    }
}

bool Component::IsEngineComponent() const
{
    return engineComponent != NULL;
}

AttribModel* Component::GetAttributes()
{
    return &m_AttribModel;
}

void Component::AddAttribute(const QString& name,const QString& type)
{
    if(m_AttribModel.GetData().find(name) == m_AttribModel.GetData().end() )
    {
        //If the attribute does not exist, create the key and set the type
        //of that attribute
        AttribModel::Attribute a;
        a.m_Data = QVariant(""); //default for now
        a.m_Type = type;
        //QHash<QString,AttribModel::Attribute>::iterator iter =
        m_AttribModel.GetData().insert(name,a);
    }
}

EngineComponent* Component::GetComponentPtr()
{
    return engineComponent;
}

const EngineComponent* Component::GetComponentPtr() const
{
    return engineComponent;
}

void Component::SetEngineComponentPtr(EngineComponent* ptr)
{
    engineComponent = ptr;
}

// -----------------------------------------------------------------------------

void Component::receiveDataChanged(const QString& attribName,const QVariant& data)
{
    //We only receive this if we are an engine component and there is data
    //we need to change.
    engineComponent->ChangeData(attribName,data);

    //Now the component changes its data base to reflect the change on the
    //engine component.
}

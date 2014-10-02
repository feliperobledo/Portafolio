#include "componentmodel.h"
#include "component.h"

ComponentModel::ComponentModel()
{
}

void ComponentModel::Initialize(const QString&)
{
    //Make sure the component data exists before creating it
    NewComponent("Transform");

    Attribute attr;

    attr.m_Name = "Scale";
    attr.m_Type = "vec3";
    m_ComponentNames["Transform"].push_back(attr);
    attr.m_Name = "Rotate";
    attr.m_Type = "vec3";
    m_ComponentNames["Transform"].push_back(attr);
    attr.m_Name = "Translate";
    attr.m_Type = "vec3";
    m_ComponentNames["Transform"].push_back(attr);

    NewComponent("Model");
    attr.m_Name = "Model File";
    attr.m_Type = "String";
    m_ComponentNames["Model"].push_back(attr);
}

void ComponentModel::Free()
{

}

ComponentModel::~ComponentModel()
{

}


bool ComponentModel::NewComponent(const QString& componentName)
{
    //Only add a new component name if it does not exists already
    if(m_ComponentNames.find(componentName) == m_ComponentNames.end())
    {
        m_ComponentNames.insert(componentName,QVector<Attribute>());
        return true;
    }
    return false;
}

bool ComponentModel::ComponentNameExists(const QString& componentName)
{
    return m_ComponentNames.find(componentName) != m_ComponentNames.end();
}

Component* ComponentModel::CreateComponent(const QString& componentName)
{
    //Make sure the component data exists before creating it
    NewComponent(componentName);

    Component* newComponent = new Component(componentName);
    QVector<Attribute>& attributes = m_ComponentNames.find(componentName).value();
    for(int i = 0;i < attributes.size(); ++i)
    {
        newComponent->AddAttribute(attributes[i].m_Name,
                                   attributes[i].m_Type);
    }

    return newComponent;
}

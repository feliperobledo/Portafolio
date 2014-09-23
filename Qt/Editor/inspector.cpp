#include "inspector.h"
#include "composite.h"
#include "component.h"
#include "EngineComponent.h"
#include "attributeview.h"
#include <QVBoxLayout>
#include <QPushButton>
#include <QString>


Inspector::Inspector(QWidget *parent) :
    QScrollArea(parent)
{
}

void Inspector::Initialize()
{
    setLayout(new QVBoxLayout(this));
}

void Inspector::ReceiveNew(const CompositeHandle& rhs)
{
    InitCompositeWidgets(rhs);
}

void Inspector::ReceiveNew(const QVector<CompositeHandle>& rhs)
{
    //Check that all objects are the same here...
    if(ShareSameComponents(rhs))
    {
        //Send only the first object to init the widgets since all other objects
        //are the same
        InitCompositeWidgets(rhs[0],clear_fields());
    }
    else
    {
        InitCompositeWidgets(rhs[0],transform_only());
    }
}

void Inspector::UpdateFields(const CompositeHandle& cHandle)
{
    //Only add a child if it cannot be found
    const Composite::Components& components =  cHandle->GetComponentList();
    Composite::Components::const_iterator iter = components.begin();
    for(;iter != components.end(); ++iter)
    {
        QString name(iter.key());
        if(!HasWidgetNamed(name))
        {
            AttributeView* newAV = new AttributeView(name,this);
            newAV->setObjectName(name);
            newAV->GetView()->setModel((iter.value()->GetAttributes()));

            this->layout()->addWidget(newAV);

            newAV->Initialize();
        }
        //children().removeOne()
    }
}

bool Inspector::HasWidgetNamed(const QString& name)
{
    QObjectList::const_iterator iter = children().begin();
    for(;iter != children().end();++iter)
    {
        if((*iter)->objectName() == name)
        {
            return true;
        }
    }
    return false;
}

// -----------------------------------------------------------------------------

bool Inspector::ShareSameComponents(const QVector<CompositeHandle>&)
{
    //Use first element in the vector to determine if all other composites
    //share the same attributes as the it.
    return false;
}

void Inspector::InitCompositeWidgets(const CompositeHandle& cHandle)
{
    //Do widget addition logic here
    const Composite::Components& components =  cHandle->GetComponentList();
    Composite::Components::const_iterator iter = components.begin();
    for(;iter != components.end(); ++iter)
    {
        //Create new view for this component
        QString name(iter.key());
        AttributeView* newAV = new AttributeView(name,this);
        newAV->setObjectName(name);

        //Give this view the data it needs to display
        newAV->GetView()->setModel((iter.value()->GetAttributes()));

        //Add the view to the layout of the inspector
        this->layout()->addWidget(newAV);

        //Finilize composition of view by initializing the view
        newAV->Initialize();
    }

}

void Inspector::InitCompositeWidgets(const CompositeHandle& rhs, clear_fields)
{
    //Add widgets
    InitCompositeWidgets(rhs);

    //Do logic to clear fields here
}

void Inspector::InitCompositeWidgets(const CompositeHandle& rhs, transform_only)
{
    //Add widgets
    InitCompositeWidgets(rhs);

    //Do logic to clear fields here
}

#include "inspector.h"
#include "composite.h"
#include "IComponent.h"
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

// -----------------------------------------------------------------------------

bool Inspector::ShareSameComponents(const QVector<CompositeHandle>& rhs)
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
        QString name(iter.key());
        this->layout()->addWidget(new QPushButton(name));
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

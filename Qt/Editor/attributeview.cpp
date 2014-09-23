#include "attributeview.h"
#include <QVBoxLayout>
#include <QDebug>

AttributeView::AttributeView(const QString& title,QWidget *parent) :
    QGroupBox(title,parent),
    m_Delegate()
{

}

void AttributeView::Initialize()
{
    //Set the item delegate that controls editing data
    m_Delegate.Initialize();
    m_View.setItemDelegate(&m_Delegate);

    //Create a layout for the view to be able to hold objects in a coherent
    //manner
    setLayout(new QVBoxLayout(this));
    layout()->addWidget(&m_View);
    m_View.show();

    //Create connection to request an update of the data
    connect( this,SIGNAL(requestUpdate()),
             &m_View,SLOT(updateEditorData()) );

    //Request that the initial data be display
    emit requestUpdate();

    //Initial data now is displaying. Can get rid of connection.
    disconnect( this,SIGNAL(requestUpdate()),
                &m_View,SLOT(updateEditorData()) );
}

QTableView *AttributeView::GetView()
{
    return &m_View;
}

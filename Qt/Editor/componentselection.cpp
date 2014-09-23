#include "componentselection.h"
#include <QListWidgetItem>
#include <QListWidget>
#include <QDebug>

ComponentSelection::ComponentSelection(QWidget *parent) :
    QDialog(parent),
    m_ComponentNames(this)
{
}

void ComponentSelection::Initialize()
{
    QPoint center(this->parentWidget()->width() / 2,
                  this->parentWidget()->height() / 2);
    move(center);
    resize(center.x() / 2, center.y() / 2);
    hide();

    //Makes it so the user HAS to select something
    setModal(true);

    connect(&(this->m_ComponentNames),SIGNAL(itemDoubleClicked(QListWidgetItem*)),
            this,SLOT(ReceiveSelection(QListWidgetItem*))                     );

    //Add first entries of Transform and Cube. Add engine component names
    m_ComponentNames.addItem(QString("Transform"));
    m_ComponentNames.addItem(QString("Model"));
}

void ComponentSelection::ReceiveSelection(QListWidgetItem* item)
{
    emit signalSelection(item);
}

QListWidget& ComponentSelection::GetList()
{
    return m_ComponentNames;
}

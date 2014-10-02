#ifndef ATTRIBUTEVIEW_H
#define ATTRIBUTEVIEW_H

#include <QTableView>
#include <QGroupBox>
#include "attributedelegate.h"

class QAbstractItemModel;

class AttributeView : public QGroupBox
{
    Q_OBJECT
public:
    explicit AttributeView(const QString& title,QWidget *parent = 0);

    void Initialize();
    QTableView* GetView();
signals:
    void requestUpdate();

public slots:

private:
    QTableView m_View;
    AttributeDelegate m_Delegate;
};

#endif // ATTRIBUTEVIEW_H

#ifndef INSPECTOR_H
#define INSPECTOR_H

#include "core/compositehandle.h"
#include <QVector>
#include <QPointer>
#include <QScrollArea>

class Inspector : public QScrollArea
{
    Q_OBJECT
public:
    explicit Inspector(QWidget *parent = 0);

    void Initialize();
    void ReceiveNew(const CompositeHandle& rhs);
    void ReceiveNew(const QVector<CompositeHandle>& rhs);
    void UpdateFields(const CompositeHandle& rhs);
    bool HasWidgetNamed(const QString &name);

signals:

public slots:

private:
    struct clear_fields {};
    struct transform_only {};

    //The list of component inspectors
    QVector<QPointer<QWidget> > m_ComponentView;

private:
    bool ShareSameComponents(const QVector<CompositeHandle>& rhs);

    //Use this one to init all fields to the values the Composite components have
    void InitCompositeWidgets(const CompositeHandle& cHandle);
    //Use this one to display nothing on all fields
    void InitCompositeWidgets(const CompositeHandle& rhs, clear_fields);
    //Use this one when the collection of handles belongs to composites that
    //share no attributes. This means the user wants to translate the collection
    //of objects
    void InitCompositeWidgets(const CompositeHandle& rhs, transform_only);

};

#endif // INSPECTOR_H

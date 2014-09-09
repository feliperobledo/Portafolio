#ifndef INSPECTORCOMPONENT_H
#define INSPECTORCOMPONENT_H

#include <QWidget>
#include <QString>

class InspectorComponent : public QWidget
{
    Q_OBJECT
public:
    explicit InspectorComponent(QWidget *parent = 0);

    void Initialize(const QString& compName);
signals:

public slots:

};

#endif // INSPECTORCOMPONENT_H

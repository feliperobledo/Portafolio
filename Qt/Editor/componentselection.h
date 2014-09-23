#ifndef COMPONENTSELECTION_H
#define COMPONENTSELECTION_H

#include <QListWidget>
#include <QString>
#include <QDialog>

class ComponentSelection : public QDialog
{
    Q_OBJECT
public:
    explicit ComponentSelection(QWidget *parent = 0);

    void Initialize();
    QListWidget& GetList();
signals:
    void signalSelection(QListWidgetItem*);

public slots:
    void ReceiveSelection(QListWidgetItem*);

private:
    QListWidget m_ComponentNames;

};

#endif // COMPONENTSELECTION_H

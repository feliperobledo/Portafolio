// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  The main window widget that holds all the other modules of the editor
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
// -----------------------------------------------------------------------------

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "core/handlesystem.h"
#include "core/componentselection.h"
#include <QMainWindow>
#include <QMultiHash>
#include <QVector>
#include <QString>
#include <QListWidget>
#include <QDialog>

class WorldWindow;
class IDataModel;
class Composite;

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    typedef QMultiHash<QString,IDataModel*> Databases;

    explicit MainWindow(QWidget *parent = 0);

    void Initialize();
    void InitDatabases();

    ~MainWindow();

public slots:
    void CreateEmpty(void);
    void NewComponent();
    void WorldObjectRequest();
    void AddComponentToSelection(QListWidgetItem*);
    void ShowComponentList();

signals:
    void SendWorldObjects(QVector<Composite*>*);

private:
    Ui::MainWindow* m_Ui;
    WorldWindow* m_WorldScreen;
    HandleSystem m_HandleSys;
    Databases m_DataModels;
    ComponentSelection m_CompSelectDialog;

private:
    IDataModel* DataModel(const QString& name);
    const IDataModel* DataModel(const QString& name) const;
    bool InsertComponent(const QString& componentName);





};

#endif // MAINWINDOW_H

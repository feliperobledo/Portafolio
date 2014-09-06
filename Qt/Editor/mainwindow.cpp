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

#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "worldwindow.h"
#include "worlddatabase.h"
#include "idatamodel.h"
#include "archetypedatabase.h"
#include "composite.h"
#include <QHBoxLayout>
#include <QMetaObject>
#include <QDebug>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    m_Ui(new Ui::MainWindow)
{

}

void MainWindow::Initialize()
{
    m_Ui->setupUi(this);

    m_WorldScreen = new WorldWindow();
    QWidget* screenWidget = this->createWindowContainer(m_WorldScreen,m_Ui->WorldFrame);
    m_WorldScreen->initialize();
    m_WorldScreen->setAnimating(true);

    m_Ui->WorldFrame->setLayout(new QHBoxLayout);
    m_Ui->WorldFrame->layout()->addWidget(screenWidget);

    //Init all databases
    InitDatabases();
}

MainWindow::~MainWindow()
{
    delete m_Ui;

    Databases::iterator iter = m_DataModels.begin();
    for(;iter != m_DataModels.end(); ++iter)
    {
        iter.value()->Free();
        delete iter.value();
    }
}

void MainWindow::InitDatabases()
{
    //Maybe read from a file the types of databases that the editor has

    //Probably do some sort of compile time database registration. If at
    //compile time the name of the database can be found, then create a
    //new instance of it.
    //This way we can use a text file to specify what functionality we want

    //Let's hard code some databases for now
    m_DataModels.insert(QString("World"),new WorldDatabase);
    m_DataModels.insert(QString("Archetypes"),new ArchetypeDatabase);

    Databases::iterator iter = m_DataModels.begin();
    for(;iter != m_DataModels.end(); ++iter)
    {
        iter.value()->Initialize(QString(""));
    }

    //specific signal,slot connections
    //WorldDatabase* world = dynamic_cast<WorldDatabase*>(DataModel("World"));
    connect(this,SIGNAL(SendWorldObjects(QVector<Composite*>*)),
            m_WorldScreen,SLOT(receiveWorldData(QVector<Composite*>*)));

    connect(m_WorldScreen,SIGNAL(requestWorldData()),
            this,SLOT(WorldObjectRequest()));
}

// -----------------------------------------------------------------------------

void MainWindow::CreateEmpty(void)
{
    //Populate databases with sample objects
    WorldDatabase* world = dynamic_cast<WorldDatabase*>(DataModel("World"));
    if(world)
    {
        world->NewComposite();
    }
}

void MainWindow::WorldObjectRequest()
{
    WorldDatabase* world =
            dynamic_cast<WorldDatabase*>(DataModel("World"));

    QVector<Composite*>* data =
            reinterpret_cast<QVector<Composite*>*>(world->WorldObjects());

    emit SendWorldObjects(data);
}

// -----------------------------------------------------------------------------

IDataModel* MainWindow::DataModel(const QString& name)
{
    if(m_DataModels.find(name) != m_DataModels.end())
    {
         return m_DataModels.find(name).value();
    }
    return NULL;
}

const IDataModel* MainWindow::DataModel(const QString& name) const
{
    if(m_DataModels.find(name) != m_DataModels.end())
    {
         return m_DataModels.find(name).value();
    }
    return NULL;
}

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
#include "componentmodel.h"
#include "composite.h"
#include <QHBoxLayout>
#include <QMetaObject>
#include <QDebug>
#include <QInputDialog>
#include <QListWidget>
#include <QListWidgetItem>
#include <QPoint>
#include <QMetaObject>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    m_Ui(new Ui::MainWindow),
    m_CompSelectDialog(this)
{

}

void MainWindow::Initialize()
{
    m_Ui->setupUi(this);
    m_Ui->ObjInspector->Initialize();

    m_WorldScreen = new WorldWindow();
    QWidget* screenWidget = this->createWindowContainer(m_WorldScreen,m_Ui->WorldFrame);
    m_WorldScreen->initialize();
    m_WorldScreen->setAnimating(true);

    m_Ui->WorldFrame->setLayout(new QHBoxLayout);
    m_Ui->WorldFrame->layout()->addWidget(screenWidget);

    //Init all databases
    InitDatabases();

    //Init other systems
    m_CompSelectDialog.Initialize();

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
    m_DataModels.insert(QString("Components"), new ComponentModel);

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
    ComponentModel* components = dynamic_cast<ComponentModel*>(DataModel("Components"));
    if(world != NULL && components != NULL)
    {           
        world->NewComposite();
        Composite* newObj = world->GetLastCreated();
        //Create component. If engine component, the engine component will also be
        //created. Also, all attributes are set to a generic default value at this point.
        Component* newComponent = components->CreateComponent("Transform");
        world->AddComponentTo(newComponent,newObj);

        newComponent = components->CreateComponent("Model");
        world->AddComponentTo(newComponent,newObj);

        //Initialize will set the component's model equal to the component values
        newObj->Initialize();

        m_HandleSys.HandleNew( newObj );
        m_Ui->ObjInspector->ReceiveNew(m_HandleSys.GetHandle());
    }
}

void MainWindow::NewComponent()
{
    ComponentModel* components = dynamic_cast<ComponentModel*>(DataModel("Components"));
    if(components)
    {
        //Prop user if text box pop-up
        QString componentName = QInputDialog::getText(this,tr("New Component"),
                                                      tr("Name: "),QLineEdit::Normal);

        if(componentName.isEmpty())
            return;

        //Use field in text box pop-up to create the new components name
        if(components->NewComponent(componentName))
        {
            //Add the name to the GUI
            m_CompSelectDialog.GetList().addItem(componentName);
        }
    }
}

void MainWindow::AddComponentToSelection(QListWidgetItem* item)
{
    if(InsertComponent(item->text()) == true)
    {
        m_Ui->ObjInspector->UpdateFields(m_HandleSys.GetHandle());
    }
    //Disable the connection between the list and the main window since
    //the component has already been added
    disconnect(&(this->m_CompSelectDialog),SIGNAL(signalSelection(QListWidgetItem*)),
               this,SLOT(AddComponentToSelection(QListWidgetItem*))               );

    m_CompSelectDialog.hide();
}

void MainWindow::ShowComponentList()
{
    //Whenever you double click on the component list, then that means a
    //component is being added to the  currently selected object
    QMetaObject::Connection con = connect( &(this->m_CompSelectDialog),
                                           SIGNAL(signalSelection(QListWidgetItem*)),
             this,SLOT(AddComponentToSelection(QListWidgetItem*))                );

    if(bool(con) == false)
    {
        qDebug() << "Something is not working";
    }

    //Show the possible components to choose from
    m_CompSelectDialog.show();
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

bool MainWindow::InsertComponent(const QString& componentName)
{
    //Use data to locate component meta in component model
    ComponentModel* components = dynamic_cast<ComponentModel*>(DataModel("Components"));
    if(components->ComponentNameExists(componentName))
    {
        //Get the handle of the currently selected object and check that it
        //does not have the component already
        CompositeHandle handle = m_HandleSys.GetHandle();
        if(handle->GetComponent(componentName) == NULL)
        {
            //Create the component
            Component* newComponent = components->CreateComponent(componentName);

            //Add the component
            handle->AddComponent(newComponent);

            return true;
        }
    }
    return false;
}

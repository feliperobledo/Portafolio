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

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    m_Ui(new Ui::MainWindow)
{
    m_Ui->setupUi(this);

    m_WorldScreen = new WorldWindow();
    QWidget* screenWidget = this->createWindowContainer(m_WorldScreen,m_Ui->WorldFrame);
    m_WorldScreen->initialize();

    //ui->horizontalLayout_2->addWidget(screenWidget);
}

MainWindow::~MainWindow()
{
    delete m_Ui;
}

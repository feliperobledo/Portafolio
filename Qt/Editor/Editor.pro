#-------------------------------------------------
#
# Project created by QtCreator 2014-08-07T08:46:52
#
#-------------------------------------------------

QT       += core gui opengl

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = Editor
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    worldwindow.cpp \
    objectfactory.cpp \
    transform.cpp \
    model.cpp \
    composite.cpp \
    worlddatabase.cpp \
    archetypedatabase.cpp \
    compositehandle.cpp \
    inspector.cpp \
    handlesystem.cpp \
    component.cpp \
    componentmodel.cpp \
    componentselection.cpp \
    attributeview.cpp \
    attribmodel.cpp \
    attributedelegate.cpp \
    attributeeditor.cpp

HEADERS  += mainwindow.h \
    worldwindow.h \
    objectfactory.h \
    transform.h \
    model.h \
    BypassGL.h \
    composite.h \
    worlddatabase.h \
    archetypedatabase.h \
    idatamodel.h \
    compositehandle.h \
    inspector.h \
    handlesystem.h \
    component.h \
    enginecomponent.h \
    componentmodel.h \
    componentselection.h \
    attributeview.h \
    attribmodel.h \
    attributedelegate.h \
    attributeeditor.h

FORMS    += mainwindow.ui

OTHER_FILES += \
    GLnotes.txt

RESOURCES += \
    Resources.qrc

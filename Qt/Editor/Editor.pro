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
    ISerializer.cpp \
    mymodelserializer.cpp \
    transform.cpp \
    model.cpp \
    externalinitializer.cpp \
    composite.cpp \
    worlddatabase.cpp \
    archetypedatabase.cpp \
    idatamodel.cpp \
    compositehandle.cpp \
    inspector.cpp \
    handlesystem.cpp \
    inspectorcomponent.cpp \
    componentmetadatabase.cpp

HEADERS  += mainwindow.h \
    worldwindow.h \
    IComponent.h \
    ComponentTypes.h \
    objectfactory.h \
    ISerializer.h \
    mymodelserializer.h \
    transform.h \
    model.h \
    BypassGL.h \
    externalinitializer.h \
    composite.h \
    worlddatabase.h \
    archetypedatabase.h \
    idatamodel.h \
    compositehandle.h \
    inspector.h \
    handlesystem.h \
    inspectorcomponent.h \
    componentmetadatabase.h

FORMS    += mainwindow.ui

OTHER_FILES += \
    GLnotes.txt

RESOURCES += \
    Resources.qrc

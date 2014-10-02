#-------------------------------------------------
#
# Project created by QtCreator 2014-08-07T08:46:52
#
#-------------------------------------------------

QT       += core gui opengl

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = Editor
TEMPLATE = app

#export DYLD_IMAGE_SUFFIX=_debug

win32 {
    DESTDIR = ../build-Win32
    MOC_DIR = ../build-Win32/moc
    OBJECTS_DIR = ../build-Win32/obj
}
macx {
    DESTDIR = ../build-OSX
    MOC_DIR = ../build-OSX/moc
    OBJECTS_DIR = ../build-OSX/obj
}

FORMS    += mainwindow.ui

SOURCES += main.cpp \
    mainwindow.cpp \
    inspector.cpp

HEADERS += mainwindow.h \
    inspector.h

#-------------------------------------------------
# Add all subdirectories for the different modules
# here.
#
#-------------------------------------------------
include(attributeMVC/attributeMVC.pri)
include(core/core.pri)
include(engineComponents/engineComponents.pri)
include(glMVC/glMVC.pri)

OTHER_FILES += \
    GLnotes.txt

RESOURCES += \
    Resources.qrc

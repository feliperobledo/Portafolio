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
    worldwindow.cpp

HEADERS  += mainwindow.h \
    worldwindow.h

FORMS    += mainwindow.ui

OTHER_FILES += \
    GLnotes.txt

RESOURCES += \
    Resources.qrc

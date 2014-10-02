#include "mainwindow.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

/*
 * This is some code I found on a forum that may be useful if we decide to use
 * plugins.
 *
#if defined( Q_OS_MACX )
QCoreApplication::addLibraryPath(QCoreApplication::applicationDirPath() + "/../PlugIns");
#endif
*/

    MainWindow w;
    w.Initialize();
    w.show();

    return a.exec();
}

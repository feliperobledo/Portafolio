#include "externalinitializer.h"
#include "model.h"
#include "mymodelserializer.h"
#include <QFile>
#include <QChar>
#include <QDebug>
#include <QByteArray>
// Include the whole JSON family
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QErrorMessage>



ExternalInitializer::ExternalInitializer()
{
}

bool ExternalInitializer::SerializeData(Model *mod, const QString &filepath)
{
    using namespace SampleModelSerializer;

    //Open file
    /*
    MyModelSerializer serializer;
    if(!serializer.Open(filepath))
    {
        MyModelSerializer::ParseError error(serializer.GetError());
        qDebug() << error.Description();
        return false;
    }

    //Generate data object
    if(!serializer.Parse())
    {
        MyModelSerializer::ParseError error(serializer.GetError());
        qDebug() << error.Description();
        return false;
    }
    */
    QFile loadFile( filepath );

    if(!loadFile.open(QIODevice::ReadOnly))
    {
        qWarning("Couldn't open model file");
        return false;
    }

    QByteArray data = loadFile.readAll();

    QJsonDocument doc(QJsonDocument::fromJson(data));
    //doc = QJsonDocument::fromJson(filepath.toLocal8Bit());

    //Pass to model the data for initialization
    mod->LoadModel(doc);
}

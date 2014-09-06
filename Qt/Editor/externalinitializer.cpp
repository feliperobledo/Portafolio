#include "externalinitializer.h"
#include "model.h"
#include "mymodelserializer.h"
#include <QFile>
#include <QChar>
#include <QDebug>


ExternalInitializer::ExternalInitializer()
{
}

bool ExternalInitializer::SerializeData(Model *mod, const QString &filepath)
{
    using namespace SampleModelSerializer;

    //Open file
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

    //Pass to model the data for initialization
    mod->LoadModel(serializer.ObjectStore()->GetDataStore());
}

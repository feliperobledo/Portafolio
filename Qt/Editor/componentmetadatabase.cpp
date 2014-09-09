#include "componentmetadatabase.h"
#include <QFile>

ComponentMetaDatabase::ComponentMetaDatabase()
{
}

void ComponentMetaDatabase::Initialize(const QString&)
{
    InitAttributeTable(QString(":/Resources/Databases/ComponentDatabase"));
    InitConversionTable(QString(":/Resources/Databases/ConversionTypes"));
}

void ComponentMetaDatabase::Free()
{

}

ComponentMetaDatabase::~ComponentMetaDatabase()
{

}

//-----------------------------------------------------------------------------

void ComponentMetaDatabase::InitAttributeTable(const QString& filename)
{
    QFile file(filename);
    if(!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {

    }
}

void ComponentMetaDatabase::InitConversionTable(const QString& filename)
{

}

#ifndef COMPONENTMETADATABASE_H
#define COMPONENTMETADATABASE_H

#include "idatamodel.h"
#include <QMultiHash>
#include <QVector>

class ComponentMetaDatabase : public IDataModel
{
public:
    typedef QMultiHash<QString,QVector<QString> > AttributeData;
    typedef QMultiHash<QString,QString> ConversionData;

    ComponentMetaDatabase();
    virtual void Initialize(const QString& initFile);
    virtual void Free();
    ~ComponentMetaDatabase();

private:
    AttributeData m_CompAttribTable;
    ConversionData m_ConversionTable;

private:
    void InitAttributeTable(const QString &filename);
    void InitConversionTable(const QString& filename);
};

#endif // COMPONENTMETADATABASE_H

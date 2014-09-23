#ifndef IDATAMODEL_H
#define IDATAMODEL_H

#include <QString>

class IDataModel
{
public:
    IDataModel() {};
    virtual void Initialize(const QString& initFile) = 0;
    virtual void Free() = 0;
    virtual ~IDataModel() {}
};

#endif // IDATAMODEL_H

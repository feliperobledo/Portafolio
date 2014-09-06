#include "mymodelserializer.h"
#include <QFile>

namespace SampleModelSerializer
{
    const void *MyModelSerializer::MyDataHolder::GetDataStore() const
    {
        return static_cast<const void*>(&(this->m_DataConfig));
    }

    void MyModelSerializer::MyDataHolder::Close()
    {
        //Get rid of all the dat
    }


// -----------------------------------------------------------------------------

    MyModelSerializer::MyModelSerializer()
    {
        this->ObjectStore(new MyModelSerializer::MyDataHolder);
    }

    bool MyModelSerializer::Open(const QString& filename) throw()
    {        
        QFile modelFile(filename);
        if(!modelFile.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            QString errStr(filename);
            errStr += QString(" not found");
            this->AddError(ParseError(ParseError::FILE_NOT_FOUND,
                                      errStr));
            return false;
        }


        return true;
    }

    bool MyModelSerializer::Parse() throw()
    {
        //Parse this file according to the format selected
        QString errStr("not parsing yet");
        this->AddError(ParseError(ParseError::FILE_NOT_FOUND,
                                  errStr));
        return false;
    }
}

// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  Use this interface to use different types of serializers for different
//  types of engine logic.
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
// -----------------------------------------------------------------------------
#ifndef EXTERNALINITIALIZER_H
#define EXTERNALINITIALIZER_H

#include <QMap>
#include <QString>

#define REGISTER_SERIALIZE(class)\
    bool SerializeData(class* obj,const QString& filepath)

class Model;

namespace Serializer
{
    class ISerializer;
}

class ExternalInitializer
{    
public:
    ExternalInitializer();

    //Every new serializer must register with a new method
    REGISTER_SERIALIZE(Model);

private:

};

#endif // EXTERNALINITIALIZER_H

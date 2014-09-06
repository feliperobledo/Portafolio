// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  Component interface used define game object properties
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
// -----------------------------------------------------------------------------
#ifndef ICOMPONENT_H
#define ICOMPONENT_H

#include <QString>

#define REGISTER_COMPONENT(x) CT_##x
enum ComponentType
{
    #include "ComponentTypes.h"
    Total
};
#undef REGISTER_COMPONENT

// -----------------------------------------------------------------------------

#define REGISTER_COMPONENT(x) #x
static char* ComponentTypeArray[] =
{
    #include "ComponentTypes.h"
    "Total"
};
#undef REGISTER_COMPONENT

class Composite;

// -----------------------------------------------------------------------------

class IComponent
{
public:
    struct Archetype
    {
      QString       TypeName;
      //Json::Object JsonData;

      Archetype() : TypeName() {}
      //Archetype() : TypeName(), JsonData (Utilities::Hash::FNVUnicode) {}
    };

public:
    IComponent() {}
    virtual void Initialize(const char*) = 0;
    virtual void Free() = 0;
    virtual ~IComponent() {}
    //ComponentType GetType() const { return m_Type; }
    const Composite* Owner() const { return m_owner; }

private:
    //ComponentType m_Type;
    Composite* m_owner;

    //now composites can access private data publicly
    friend class Composite;
};

#endif // ICOMPONENT_H

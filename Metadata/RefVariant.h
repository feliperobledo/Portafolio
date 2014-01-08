/********************************************************************
File: RefVariant.h
Date Created: 12/06/13
Purpose: Defines the interface of a Variant.
         A Variant is a generic container that can represent any 
         sort of data type, be it user defined or primitive.
         This is a component of the reflection system, and it is 
         widely use for script integration.
         A RefVariant is just a shallow copy of some data. Unlike
         the Variant, it does not memory handling.
********************************************************************/

#pragma once

#include "Metadata.h"

class RefVariant
{
    public:
        template <typename Type>
        RefVariant(Type& data) : m_MetaData(META_TYPE(Type)),
                                 m_Data(reinterpret_cast<void*>(&data))
        {
        }

        ~RefVariant(void);        

        template <typename Type>
        Type Cast(void)
        {
            return reinterpret_cast<Type>(m_Data);
        }

        template <typename Type>
        Type GetValue(void)
        {
            return Cast<Type>();
        }

        template <typename Type>
        const Type GetValue(void) const
        {
            return Cast<Type>();
        }

        const char* GetType(void) const;

        const Metadata* GetMeta(void) const;

    private:
        const Metadata* m_MetaData;
        void* m_Data;
};


/********************************************************************
File: Variant.h
Date Created: 11/20/13
Purpose: Defines the interface of a Variant.
         A Variant is a generic container that can represent any 
         sort of data type, be it user defined or primitive.
         This is a component of the reflection system, and it is 
         widely use for script integration.
********************************************************************/

#pragma once

#include "MetaMacros.h"
#include "Metadata.h"

class Variant
{
    public:
        template <typename Type>
        Variant(const Type& data) : m_MetaData(META_TYPE(Type)),
                                    m_Data(NULL)
        {
            m_Data = m_MetaData->NewCopy<Type>(data);
        }

        ~Variant(void);        

        template <typename Type>
        Type* Cast(void)
        {
            return reinterpret_cast<Type*>(m_Data);
        }

        template <typename Type>
        Type& GetValue(void)
        {
            return *Cast<Type*>();
        }

        template <typename Type>
        const Type& GetValue(void) const
        {
            return *Cast<Type*>();
        }

        const char* GetType(void) const;

        bool GetIsValid(void) const;

        template <typename Type>
        Variant& operator=(const Type& rhs)
        {
            if(m_MetaData != META_TYPE(Type))
            {
                //have an assert here for asserting that we cannot
                //create metadata about NULL


                //As a possible optimization one could actually avoid 
                //creating a new buffer if the size of the incoming 
                //type is less than the size currently held by the
                //Variant.
                m_MetaData->Delete(m_Data);
                m_MetaData = META_TYPE(Type);
                m_MetaData = m_MetaData->NewCopy(reinterpret_cast<void*>(rhs));
            }
            else
            {
                m_MetaData->Copy(m_Data,rhs);
            }
            return *this;
        }

    private:
        const Metadata* m_MetaData;
        void* m_Data;
        bool m_IsValid;
};
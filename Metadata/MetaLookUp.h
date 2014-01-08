#pragma once

#include "MetaIsDynamic.h"

/*
    Description:
        Uses MetaIsDynamic to determine if a class's Metadata
        should be retrieved through a getMetadata method if the
        class is polymorphic or if its MetaSingleton can be 
        invoked.
*/
template <typename MetaType>
struct MetaLookup
{
   template <typename U>
   static typename std::enable_if<MetaIsDynamic<U>::value, const Metadata*>::type resolve(const U& obj)
   {
     return obj.getMetadata();
   }

   template <typename U>
   static typename std::enable_if<!MetaIsDynamic<U>::value, const Metadata*>::type resolve(const U&)
   {
     return MetaSingleton<U>::get();
   }

   static const Metadata* get(const MetaType& obj) { return resolve<MetaType>(obj); }
};

template <typename MetaType>
struct MetaLookup<MetaType*>
{
   static const Metadata* get(const MetaType* obj) { return MetaLookup<MetaType>::get(*obj); }
};

template <typename MetaType>
struct MetaLookup<const MetaType*> : public MetaLookup<MetaType*> {};

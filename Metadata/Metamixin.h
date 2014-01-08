//This Approach is not being used at the moment. The macro
//apprach is being used.
#pragma once

#include "Metasingleton.h"

//First approach to trying to solve the dynamic classes
//problem with the metadata system, where a poitner
//to the base of a derived will call the
//metadata for the base.
//The mixin apprach allows for the following to happen
/*
   ----------
  |          |
  |   Foo    |
  |          |
   ----------
       |
       |
   ----------
  |          | template <Foo2, Foo>
  |          | class Mixin : public Foo
  |          |
   ----------
       |
       |
   ----------
  |          |
  |   Foo2   | class Foo2 : Mixin<Foo2, Foo>
  |          |
   ----------

*/
template <typename MetaType, typename BaseType>
struct Metamixin : public BaseType
{
    virtual const Metadata* getMetadata(void) const
    { return MetaSingleton<MetaType>::get(); }
};



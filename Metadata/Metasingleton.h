#pragma once

//#include "Metadata.h"
#include <type_traits> //vs2010 does not have this

class Metadata;

/*
    Description: 
        A static class used to instantiate only one
        instance of every Metadata per user-defined class.
*/
template <typename MetaType>
class MetaSingleton
{
  public:
      MetaSingleton(void)
      { MetaType::DefineInternals();}

      static Metadata* get(void)
      { return &s_Meta; }
      
  private:
      static Metadata s_Meta;
};

/*
    Description:
        Use of partial template specialization to refer only
        to the qualified type instead of pointers, references,
        const referense, etc...
*/
template <typename MyType>
class MetaSingleton<const MyType> : public MetaSingleton<MyType>
{};

template <typename MyType>
class MetaSingleton<MyType&> : public MetaSingleton<MyType>
{};

template <typename MyType>
class MetaSingleton<const MyType&> : public MetaSingleton<MyType>
{};

template <typename MyType>
class MetaSingleton<MyType&&> : public MetaSingleton<MyType>
{};

template <typename MyType>
class MetaSingleton<MyType*> : public MetaSingleton<MyType>
{};

template <typename MyType>
class MetaSingleton<const MyType*> : public MetaSingleton<MyType>
{};

//ADDED!!!
template <typename MyType>
class MetaSingleton<volatile MyType> : public MetaSingleton<MyType>
{};

//STORAGE CLASS: No need since those affect scope in 
//               of variable, not its identity.

//TYPE QUALIFIER: volatile must be covered since the type
//                could be changed but we only want the
//                MetaSingleton for the specified type.


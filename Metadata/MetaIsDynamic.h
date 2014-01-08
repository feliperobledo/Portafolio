#pragma once

#include "Metasingleton.h"

/*
    Description:
        Checks to see of a Type has the getMetaData method,
        which only dynamic polymorphic classes have. If the
        given class does, then the instance of this class for
        that type will hold true for member value. 
*/
template <typename MetaType>
struct MetaIsDynamic
{
  private:
      struct no_return {};

      /*
        param: It's a pointer to decltype of an expression

        Cheap way of constructing a "random" pointer to call a method on
      */
      template <typename U>
      static char check( decltype( static_cast<U*>(0)->getMetaData() )* );

      /* ELLIPSES
        An ellipsis is used not only because it will 
        accept any argument, but also because its 
        conversion rank is lowest, so a call to the 
        first function will be preferred if it is 
        possible; this removes ambiguity.
      */
      template <typename U>
      static no_return check(...);

  public:
      //boolean 'value' is false if no_return is the same type as the return value of 'check(0)
      static const bool value = !std::is_same<no_return,decltype(check<MetaType>(0))>::value;
};
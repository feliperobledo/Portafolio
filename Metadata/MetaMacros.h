#pragma once

//NOTE:
/*
  Defines are REAAAALLLYYYY dumb. You don't really need any includes.
*/
//#include "Metasingleton.h"
//#include "MetaLookUp.h"
//#include "Function.h"

/********************************************************************
    Description:    
        Declares a MetaSingleton object of specified metatype.
        We need the global meta-singleton in order to call
        the static methods of each class that will register their
        data to their according Metadata object.
        The metasingleton also ensures that there is only 1 Metadata
        object per type.
********************************************************************/
#define REGISTER_META(metatype) MetaSingleton<metatype> g_Meta##metatype;

//For projects with namespaces
#define REGISTER_META_FROM(metatype,space) MetaSingleton<space::metatype> space::g_Meta##metatype;

/********************************************************************
    Description:
        Constructs the Metadata object inside the specified 
        Metadata singleton and assign its Metadata parent (for
        polymorphic classes only). Pass NULL to the parent if
        the class is not polymorphic.
********************************************************************/
#define DEFINE_META(metatype, parent) \
    Metadata MetaSingleton<metatype>::s_Meta(#metatype,sizeof(metatype),parent)

#define DEFINE_META_FROM(metatype, parent, space) \
    Metadata MetaSingleton<space::metatype>::s_Meta(#metatype,sizeof(metatype),parent)

/********************************************************************
    Description:
        Constructs the Metadata object inside the specified 
        Metadata singleton and assign its Metadata parent (for
        polymorphic classes only). Use for primitive types only.
********************************************************************/
#define DEFINE_PRIMITIVE(metatype) \
    Metadata MetaSingleton<metatype>::s_Meta(#metatype,sizeof(metatype),NULL,true)

/********************************************************************
    Description:
        Given an object type, retrieve the Metadata object
        of the type.
********************************************************************/
#define META_TYPE(metatype) (MetaSingleton<metatype>::get())

#define META_TYPE_(metatype,space) (MetaSingleton<space::metatype>::get())

/********************************************************************
    Description:
        Macro that defines an action within the AddMembers function
        of polymorphic classes. Use this macro to be able 
        add member data to Metadata classes.
********************************************************************/
#define META_ADD_MEMBER(objType,name) \
    META_TYPE(objType)->AddMember<decltype(name)>(#name,(unsigned)offsetof(objType,name))

#define META_ADD_MEMBER_(objType,name,space) \
    META_TYPE_(objType,space)->AddMember<decltype(name)>(#name,(unsigned)offsetof(space::objType,name))

/********************************************************************
    Description: Use this macro when binding a function to
    Metadata.

********************************************************************/
#define META_ADD_FUNCTION(name,funcAddress,typeToBind)\
    META_TYPE(typeToBind)->AddFunction(name,new Function( funcAddress ))    

#define META_ADD_FUNCTION_(name,funcAddress,typeToBind,space)\
    META_TYPE_(typeToBind,space)->AddFunction(name,new Function( funcAddress ))   


/********************************************************************
    Description: Use this macro to bind a conversion to a specific 
    data type.

********************************************************************/
#define META_ADD_CONVERSION(type,conversion)\
    META_TYPE(type)->AddConversion(#conversion)

/********************************************************************
    Description:
        For use only in polymorphic modules. Insert this 
        macro in the class declaration.
********************************************************************/
#define DECLARE_META(metatype) \
   public: virtual const Metadata* getMetadata() const \
   { return MetaSingleton<metatype>::get(); } \
   public: static void DefineInternals(void)

#define DECLARE_META_(metatype,space) \
   public: virtual const Metadata* getMetadata() const \
   { return MetaSingleton<space::metatype>::get(); } \
   public: static void DefineInternals(void)

/********************************************************************
    Description:
        Given an object name, this macro returns the Metadata for 
        that object (use also for primitive types.
********************************************************************/
#define META(object) (MetaLookup<decltype(object)>::get((object)))


/********************************************************************
    Description:
        Interface for calling the function of a given object and
        a function name.
********************************************************************/
#define CALL_METHOD_SIMPLE(object,methodName)\
    (*(META(object)->getMethod(methodName)))(object)

#define CALL_METHOD_SIMPLE_RETURN(object,methodName,returnVar)\
    (*(META(object)->getMethod(methodName)))(object,returnVar)

#define CALL_METHOD_NO_RETURN(object,methodName,...)\
    (*(META(object)->getMethod(methodName)))(object,__VA_ARGS__)

#define CALL_METHOD(object,methodName,returnVar,...)\
   (*(META(object)->getMethod(methodName)))(object,returnVar,__VA_ARGS__ )

#define CALL_FN(objPtr,method)\
    (objPtr->*method)

//Note* Future use - Metadata instance dedicated to bind global method. Macro does not need a type (default) 
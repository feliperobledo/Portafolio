#include <iostream>
#include <cstddef> //offsetof

#include "MetaManager.h"
#include "MetaMacros.h"
#include "MetaLookUp.h"
#include "Foo.h"
#include "Foo2.h"
#include "MetaCasts.h"
#include "RefVariant.h"
#include "Variant.h"

class MyClass { /* ... */ };

//DECLARE_META(MyClass);
//DEFINE_META(MyClass, NULL);

void print_size_of(const char* class_name)
{
   const Metadata* meta = MetaManager::get(class_name);
   if (meta != NULL)
     std::cout << "Size of " << meta->name() << " is " << meta->size() << std::endl;
   else
     std::cout << "Size of " << class_name << " is unknown" << std::endl;
}

template <typename Type>
void print_name_of(const Type& object)
{
   const Metadata* meta = META(object);
   std::cout << "Object is a " << meta->name() << std::endl;
}

template <typename Type>
void does_member_belong(const Type& object, const std::string& member)
{
    const Metadata* meta = META(object);
    if(meta != NULL)
    {
        if(meta->HasMember(member))
            std::cout << member << " is contained by " << meta->name() << std::endl;
        else
            std::cout << member << " is NOT contained " << meta->name() << std::endl;
    }
    else
    {
        std::cout << "Type does not have metadata." << std::endl;
    }
}

template <typename Type>
void does_method_belong(const Type& object, const char* method)
{
    const Metadata* meta = META(object);
    if(meta != NULL)
    {
        if(meta->HasMethod(method))
            std::cout << method << " is contained by " << meta->name() << std::endl;
        else
            std::cout << method << " is NOT contained " << meta->name() << std::endl;
    }
    else
    {
        std::cout << "Type does not have metadata." << std::endl;
    }
}

template <typename ObjectType>
void call_method_of(ObjectType* obj,const char* methodName)
{
    const Metadata* meta = META(obj);
    if(meta->HasMethod(methodName))
        meta->getMethod(methodName)->Call(obj);
}

//void return
template <typename ObjectType>
void call_method_of(ObjectType* obj,const char* methodName, int n)
{
    const Metadata* meta = META(obj);
    if(meta->HasMethod(methodName))
        meta->getMethod(methodName)->Call<ObjectType>(obj,&n);
}

//some return type
template <typename ObjectType, typename ReturnType>
void call_method_of(ObjectType* obj,const char* methodName, int n, ReturnType& value)
{
    const Metadata* meta = META(obj);
    if(meta->HasMethod(methodName))
         meta->getMethod(methodName)->Call<ObjectType,ReturnType>(obj,value, &n);
}

template <typename ObjectType>
void call_object_method(ObjectType& instance, const char* methodName)
{
    const Metadata* meta = META(instance);
    if(meta->HasMethod(methodName))
        CALL_METHOD_SIMPLE(instance,methodName);
}

void TestVariant(void)
{
    Foo foo;
    int i = 5;
    int par = 1;
    int* pi = &i;
    int i2 = 20;
    char c = 5;
    RefVariant var(i);
    RefVariant var2(pi);

    int value = *(var2.GetValue<int*>());

    /*
    CALL_METHOD_SIMPLE(foo,"FooPrint");

    CALL_METHOD_SIMPLE_RETURN(foo,"GetId",i);

    CALL_METHOD(foo,"PrintNewID",i,par);
    
    CALL_METHOD(foo,"SelectHighest",i,par,i2);
    */

}


int main(void)
{
   TestVariant();

   getchar();
}



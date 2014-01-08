#include "Foo.h"
#include "Metadata.h"
#include <iostream>

//Be careful! Remember that the compiler goes over .cpps once, 
//but several times over the .hs
void Print(void) 
{ 
    std::cout << "Hello!" << std::endl;
}

void Foo::FooPrint(void) 
{
    std::cout << "FooPrint!" << std::endl; 
}

void Foo::ConstFooPrint(void) const
{
    std::cout << "ConstFooPrint()" << std::endl;
}

void Foo::FooPrint2(void) 
{ 
    std::cout << "FooPrint2!" << std::endl; 
}

void Foo::PrintMe(int n) 
{  
    std::cout << "Print me:" << n << std::endl; 
}

int Foo::PrintNewID(int newID)
{
    std::cout << "Old id: " << id_ << std::endl;
    id_ = newID;
    return id_;
}

int Foo::GetId(void) const
{
    return id_;
}

int Foo::SelectHighest(int n, int m)
{
    std::cout << "Selecting highest ID" << std::endl;
    id_ = n > m ? n : m;
    std::cout << "New id: " << id_ << std::endl;
    return id_;
}

//Required definition of the declared Metasingleton for Foo
DEFINE_META(Foo, NULL);
REGISTER_META(Foo);

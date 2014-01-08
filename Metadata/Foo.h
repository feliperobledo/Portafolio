#pragma once

#include "Meta.h"

void Print(void);

class Foo
{
    public:
        Foo(void) : id_(10) {}
        void FooPrint(void);
        void ConstFooPrint(void) const;
        void FooPrint2(void);
        void PrintMe(int n);
        int PrintNewID(int newID);
        int GetId(void) const;
        int SelectHighest(int n, int m);

    private:

        int id_;

    DECLARE_META(Foo)
    {
        //Add members like this
        META_ADD_MEMBER(Foo,id_);

        //Add methods like this
        META_ADD_FUNCTION("FooPrint",  &Foo::FooPrint,  Foo);
        META_ADD_FUNCTION("ConstFooPrint",&Foo::ConstFooPrint,Foo);
        META_ADD_FUNCTION("FooPrint2", &Foo::FooPrint2, Foo);
        META_ADD_FUNCTION("PrintMe",   &Foo::PrintMe,   Foo);
        META_ADD_FUNCTION("PrintNewID",&Foo::PrintNewID,Foo);  
        META_ADD_FUNCTION("GetId",     &Foo::GetId,     Foo);
        META_ADD_FUNCTION("SelectHighest",&Foo::SelectHighest,Foo);

        //Add conversions here
    }
};


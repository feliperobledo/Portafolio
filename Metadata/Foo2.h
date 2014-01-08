#pragma once

#include <cstddef>

#include "Foo.h"
#include "Meta.h"

class Foo2 : public Foo
{
    private:
        int mem;

    DECLARE_META(Foo2)
    {
        META_ADD_MEMBER(Foo2,mem);
    }
};

class Foo3 : public Foo2
{
    private:
        float flow;

    DECLARE_META(Foo3)
    {
        META_ADD_MEMBER(Foo3,flow);
    }
};



//Department of Licensing Phone number
//206-464-6845
// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  A system used to translate all user input into data the object can interpret
//  This is like the Controller of the MVC approach.
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
// -----------------------------------------------------------------------------
#ifndef HANDLESYSTEM_H
#define HANDLESYSTEM_H

#include "compositehandle.h"

class Composite;

class HandleSystem
{
public:
    HandleSystem();

    void HandleNew( Composite* comp );

    CompositeHandle GetHandle();

private:
    //make it a single handle for now
    CompositeHandle m_Handle;
};

#endif // HANDLESYSTEM_H

#include "archetypedatabase.h"
#include "composite.h"
#include "IComponent.h"
#include <QFile>


ArchetypeDatabase::ArchetypeDatabase() :
    IDataModel()
{

}

ArchetypeDatabase::~ArchetypeDatabase()
{

}

//Parse archetypeFile with JSON parser in order to create
//initial database of ArchetypeObjects
void ArchetypeDatabase::Initialize(const QString&)
{
   //utilize JSON parser here
}

void ArchetypeDatabase::Free()
{

}


//Take a composite and saves its setup to a new .arch file
//Adds archetype to end of list
void ArchetypeDatabase::NewCompositeArchetype(const Composite*,
                           const QString&)
{

}

const Composite::Archetype* ArchetypeDatabase::GetArchetype(const QString&,
                                                            CompositeArchetype)
{
    return NULL;
}

const IComponent::Archetype* ArchetypeDatabase::GetArchetype(const QString&,
                                                             ComponentArchetype)
{
    return NULL;
}






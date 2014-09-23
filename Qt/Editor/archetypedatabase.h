#ifndef ARCHETYPEDATABASE_H
#define ARCHETYPEDATABASE_H

#include "composite.h"
#include "EngineComponent.h"
#include "idatamodel.h"
#include <QMultiHash>
#include <QString>

class ArchetypeDatabase : public IDataModel
{
public:
    typedef QMultiHash<QString,Composite::Archetype*> CompositeArchList;
    typedef QMultiHash<QString,EngineComponent::Archetype*> ComponentArchList;

    struct CompositeArchetype {};
    struct ComponentArchetype {};

    ArchetypeDatabase();
    ~ArchetypeDatabase();

    //Parse archetypeFile with JSON parser in order to create
    //initial database of ArchetypeObjects
    void Initialize(const QString& initFile);
    void Free();

    //Take a composite and saves its setup to a new .arch file
    //Adds archetype to end of list
    void NewCompositeArchetype(const Composite* compositeSetup,
                               const QString& archName);

    const Composite::Archetype* GetArchetype(const QString& name, CompositeArchetype ar);
    const EngineComponent::Archetype* GetArchetype(const QString& name, ComponentArchetype ar);

private:
    CompositeArchList m_CompositeArchetypes;
    ComponentArchList m_ComponentArchetypes;
};

#endif // ARCHETYPEDATABASE_H

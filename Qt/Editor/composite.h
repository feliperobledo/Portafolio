#ifndef COMPOSITE_H
#define COMPOSITE_H

#include "objectfactory.h"
#include <QHash>
#include <QString>
#include <QList>

class IComponent;

class Composite
{    
public:
    struct Archetype
    {
      QString       TypeName;
      //Json::Object JsonData;

      Archetype() : TypeName() {}
      //Archetype() : TypeName(), JsonData (Utilities::Hash::FNVUnicode) {}
    };

public:
    typedef QHash<QString,IComponent*> Components;
    typedef QList<Composite*> CompositeList;

    ~Composite();

    void Initialize();
    void Free();
    IComponent* GetComponent(const QString& name);
    const IComponent* GetComponent(const QString& name) const;
    const Components& GetComponentList() const;

    void Owner(Composite* owner);
    Composite* Owner(void);
    const Composite* Owner(void) const;
    void NewChild(Composite* child);
    CompositeList& Children(void);

private:
    Composite();
    Composite(const Archetype& archetype, Composite* owner);
    Composite(const Composite& rhs);
    Composite operator=(const Composite& rhs) const;
    Composite& operator=(const Composite& rhs);

private:
    //Only the object factory can create and manipulate composites
    friend class ObjectFactory;

    Composite* m_Owner;
    Components m_ComponentList;
    QString m_Name;
    QString m_ArchetypeName;
    CompositeList m_Children;


};

#endif // COMPOSITE_H

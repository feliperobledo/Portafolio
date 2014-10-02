#ifndef COMPOSITE_H
#define COMPOSITE_H

#include "objectfactory.h"
#include <QObject>
#include <QHash>
#include <QString>
#include <QList>

class EngineComponent;
class Component;

class Composite : public QObject
{    
    Q_OBJECT
public:
    struct Archetype
    {
      QString       TypeName;
      //Json::Object JsonData;

      Archetype() : TypeName() {}
      //Archetype() : TypeName(), JsonData (Utilities::Hash::FNVUnicode) {}
    };

public:
    typedef QHash<QString,Component*> Components;
    typedef QList<Composite*> CompositeList;

    struct engine_component {};
    struct py_component {};

    explicit Composite(QObject* parent = NULL);
    explicit Composite(const Archetype& archetype, QObject *parent = NULL);
    Composite(const Composite& rhs);
    virtual ~Composite();

    void Initialize();
    void Free();

    Component* GetComponent(const QString& name);
    EngineComponent* GetComponent(const QString& name,engine_component);
    const EngineComponent* GetComponent(const QString& name,engine_component) const;
    const Component* GetComponent(const QString& name) const;
    const Components& GetComponentList() const;

    void NewChild(Composite* child);
    CompositeList& Children(void);

    void AddComponent(Component *newComponent);

signals:

public slots:

private:
    Composite operator=(const Composite& rhs) const;
    Composite& operator=(const Composite& rhs);

private:
    //Only the object factory can create and manipulate composites
    friend class ObjectFactory;

    Components m_ComponentList;
    QString m_ArchetypeName;
    CompositeList m_Children;
};

#endif // COMPOSITE_H

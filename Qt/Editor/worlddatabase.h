#ifndef WORLDDATABASE_H
#define WORLDDATABASE_H

#include "idatamodel.h"
#include "objectfactory.h"
#include <QVector>

class Composite;
class Component;

class WorldDatabase : public IDataModel
{
public:
    typedef QVector<Composite*> ObjectList;

    WorldDatabase();
    virtual ~WorldDatabase();

    void Initialize(const QString &initFile);
    void Free();

    template <typename T>
    void AddComponentFactory(const QString& name);

    void NewComposite(const QString& archetypeName);
    void NewComposite();

    void Remove(const Composite* address);
    Composite* GetLastCreated(void);

    const ObjectList* WorldObjects() const;
    ObjectList* WorldObjects();

    void AddComponentTo(Component* newComponent,Composite* object);
    void SetComponentToDefault(Component* component);

private:
    ObjectFactory m_Factory;
    ObjectList m_WorldObjects;
};

template <typename T>
void WorldDatabase::AddComponentFactory(const QString& name)
{
    m_Factory.AddComponentFactory<T>(name);
}

#define REGISTER_FACTORY(classtype)\
    m_Factory.AddComponentFactory<classtype>(QString( #classtype ))

#endif // WORLDDATABASE_H

// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  Component interface used define game object properties
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
// -----------------------------------------------------------------------------
#ifndef ENGINE_COMPONENT_H
#define ENGINE_COMPONENT_H

#include <QObject>
#include <QString>

class Composite;

// -----------------------------------------------------------------------------

class EngineComponent : public QObject
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
    explicit EngineComponent(QObject* parent = NULL) : QObject(parent) {}
    virtual void Initialize(const char*) = 0;
    virtual void Free() = 0;
    virtual void ChangeData(const QString& member, const QVariant& data) = 0;
    virtual ~EngineComponent() {}

signals:

public slots:
    //every child will create their own slots


private:
    //now composites can access private data publicly
    friend class Composite;
};

#endif // EngineComponent_H

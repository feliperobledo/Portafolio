#ifndef COMPOSITEHANDLE_H
#define COMPOSITEHANDLE_H

#include <QString>

class Composite;

class CompositeHandle
{
public:
    CompositeHandle();

    CompositeHandle& operator=(Composite* rhs);

    Composite* operator->();
    const Composite* operator->() const;
    Composite& operator*();
    const Composite& operator*() const;

private:
    Composite* m_Object;
};

#endif // COMPOSITEHANDLE_H

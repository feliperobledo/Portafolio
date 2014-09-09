#include "compositehandle.h"

CompositeHandle::CompositeHandle()
{

}

const Composite* CompositeHandle::operator->()
{
   return m_Object;
}

const Composite* CompositeHandle::operator->() const
{
    return m_Object;
}

const Composite& CompositeHandle::operator*()
{
    return *m_Object;
}

const Composite& CompositeHandle::operator*() const
{
    return *m_Object;
}

CompositeHandle& CompositeHandle::operator=(Composite* rhs)
{
    m_Object = rhs;
}

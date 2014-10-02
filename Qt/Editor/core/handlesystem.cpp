#include "handlesystem.h"

HandleSystem::HandleSystem()
{
}

void HandleSystem::HandleNew( Composite* comp )
{
    m_Handle = comp;
}

CompositeHandle HandleSystem::GetHandle()
{
    return m_Handle;
}

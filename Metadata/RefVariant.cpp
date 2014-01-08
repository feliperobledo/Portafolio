#include "RefVariant.h"


RefVariant::~RefVariant(void)
{
}

const char* RefVariant::GetType(void) const
{
    return m_MetaData->name();
}

const Metadata* RefVariant::GetMeta(void) const
{
    return m_MetaData;
}

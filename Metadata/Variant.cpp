#include "Variant.h"

Variant::~Variant(void)
{
    m_MetaData->Delete(m_Data);
}

bool Variant::GetIsValid(void) const
{
    return m_IsValid;
}

const char* Variant::GetType(void) const
{
    return m_MetaData->name();
}

//boost::any
//VS13
//bitbucket - Sean Middleditch
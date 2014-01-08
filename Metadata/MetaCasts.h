#pragma once

#include "Metadata.h"
#include "Metasingleton.h"


/*
    Description: Use this function to cast a non-const
    InputType into a desired type. Same interface as dynamic_cast.
*/
template <typename TargetType, typename InputType>
static TargetType* MetaCast(InputType *input)
{
    TargetType* tType = nullptr;
    const Metadata* meta = MetaLookup<InputType*>::get(input);
    const Metadata* target = MetaLookup<TargetType*>::get(tType);
    return meta != NULL && meta->isa(target) ? static_cast<TargetType*>(input) : NULL;
}

/*
    Description: Use this function to cast a const
    InputType into a desired type. Same interface as dynamic_cast.
*/
template <typename TargetType, typename InputType>
static const TargetType* MetaCast(const InputType *input)
{
    TargetType* tType = nullptr;
    const Metadata* meta = MetaLookup<InputType*>::get(input);
    const Metadata* target = MetaLookup<TargetType*>::get(tType);
    return meta != NULL && meta->isa(target) ? static_cast<TargetType*>(input) : NULL;
}
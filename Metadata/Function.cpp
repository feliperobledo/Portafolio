//#include "Function.h"

template <>
Function::Function(Function::ObjectMethod fptr) : m_Function()
{
    m_Function.objectMethod = fptr;

    /*
    With this method, I need to cast ftpr to the appropiate 
    method later on, at least if I am considering having metadata
    hold fptrs to globals.
    */
}
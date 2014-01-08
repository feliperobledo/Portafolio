#include <cstring>
#include "Metadata.h"
#include "MetaManager.h"
#include "Function.h"

Metadata::Metadata(const char* name, size_t size, const Metadata* parent, bool primitive) : m_Name(name), 
                                                                                            m_Size(size),
                                                                                            m_IsPrimitive(primitive),
                                                                                            m_Parent(parent)
{ 
    MetaManager::registerMeta(this); 
}

Metadata::~Metadata(void)
{
    //Destroys all allocated members
    auto iter = m_Members.begin();
    while(iter != m_Members.end())
    {
        delete *iter;
        ++iter;
    }
    m_Members.clear();

    //Destroy all allocated methods
    auto iter2 = m_Methods.begin();
    while(iter2 != m_Methods.end())
    {
        delete iter2->second;
        ++iter2;
    }
    m_Methods.clear();

    //Destroy all allocated conversions
    auto iter3 = m_Conversions.begin();
    while(iter3 != m_Conversions.end())
    {
        delete [] *iter3;
        ++iter3;
    }
    m_Conversions.clear();
}

const char* Metadata::name(void) const
{
    return m_Name;
}

size_t Metadata::size(void) const 
{
    return m_Size;
}

const Metadata* Metadata::parent(void) const
{
    return m_Parent;
}

bool Metadata::isa(const Metadata* base) const
{
    //principles of walking a linked list. Awesome.
    const Metadata* meta = this;
    while(meta != NULL)
    {
        if(meta == base)
            return true; //found match
        meta = meta->parent();
    }
    return false;//no match found
}

bool Metadata::HasMember(const std::string& member) const
{
    Members::const_iterator iter = m_Members.begin();
    while(iter != m_Members.end())
    {
        const std::string& temp = (*iter)->GetName();
        if(temp == member)
            return true;
        ++iter;
    }
    return false;
}

void Metadata::AddFunction(const char* name,Function* newMethod)
{
    printf("Adding method %s\n",name);
    m_Methods[name] = newMethod;
}

bool Metadata::HasMethod(const char* method) const
{
    return m_Methods.find(method) != m_Methods.end();
}

const Function* Metadata::getMethod(const char* methodName) const
{
    Methods::const_iterator methodIter = m_Methods.find(methodName);
    return methodIter->second;
}

void Metadata::AddConversion(const char* type)
{
    unsigned length = std::strlen(type) + 1;//strlen does not consider the null
    char* newType = new char[length];
    std::memmove(newType,type,length);
    newType[length - 1] = '\0'; 
    m_Conversions.insert(newType);
}

bool Metadata::CanConvertTo(const char* type) const
{
    return m_Conversions.find(type) != m_Conversions.end();
}

/*
Description: A copy method that copies the data from
                src to dest equal to the size of the
                object this metadata holds info of completely
                in bytes
*/
void Metadata::Copy(void* dest, const void* src) const
{
    std::memcpy(dest,src,m_Size);
}

/*
Description: Given some data of same size as the data
                this metadata object represents, delete the 
                data.
*/
void Metadata::Delete(void* data) const
{
    if(data)
    {
        delete [] reinterpret_cast<char*>(data);
        data = NULL;
    }
}

/*
Description: Hand some data to the user equal to the size
                in bytes of the data type this metadata instance
                represents.
*/
void* Metadata::New(void) const
{
    return new char[m_Size];
}

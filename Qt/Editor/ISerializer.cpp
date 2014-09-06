#include "ISerializer.h"

namespace Serializer
{
    ISerializer::ISerializer() : m_ObjectStore(NULL),
                                 m_ErrorQueue()
    {

    }

    bool ISerializer::HasErrors() const
    {
        return m_ErrorQueue.size() != 0;
    }

    ISerializer::ParseError ISerializer::GetError()
    {
        ParseError error(m_ErrorQueue.front());
        m_ErrorQueue.pop_front();
        return error;
    }

    void ISerializer::AddError(const ISerializer::ParseError& newError)
    {
        m_ErrorQueue.push_back(newError);
    }
}

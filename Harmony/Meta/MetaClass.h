//
//  MetaClass.h
//  Meta
//
//  Created by Felipe Robledo on 4/11/15.
//
//

#ifndef Meta_MetaClass_h
#define Meta_MetaClass_h

#include <cstddef>
#include <string>

namespace HarmonyMeta
{
    class MetaProp;
    
    class Meta
    {
    public:
        Meta();
        ~Meta();
        
    private:
        std::size_t m_ByteSize;
        std::string m_ClassName;
    };
}

#endif

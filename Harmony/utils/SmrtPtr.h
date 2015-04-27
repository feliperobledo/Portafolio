//
//  SmrtPtr.h
//  utils
//
//  Created by Felipe Robledo on 4/11/15.
//
//

#ifndef utils_SmrtPtr_h
#define utils_SmrtPtr_h

#include <cstddef>

namespace HarmonyUtils
{
    template <typename T>
    class SmartPtr
    {
    public:
        typedef T pt_type;
        
        SmartPtr(T* data) : m_Data(data), m_Count(0) {}
        SmartPtr(SmartPtr<T>& pt) : m_Data(pt.m_Data), m_Count(
        
    private:
        T* m_Data;
        std::size_t m_Count;
    };
}

#endif

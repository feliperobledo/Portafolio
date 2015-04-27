//
//  Component.h
//  Core
//
//  Created by Felipe Robledo on 4/8/15.
//
//

#ifndef Core_Component_h
#define Core_Component_h

namespace HarmonyCore
{
    class Message;
    
    class Component
    {
    public:
        Component() {}
        virtual ~Component() {}
        
        virtual void init();
        virtual void update(float dT);
        
    private:
    };
}


#endif

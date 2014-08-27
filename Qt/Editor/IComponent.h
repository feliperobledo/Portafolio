#ifndef ICOMPONENT_H
#define ICOMPONENT_H

#define REGISTER_COMPONENT(x) x
enum ComponentType
{
    #include "ComponentTypes.h"
    Total
};
#endif REGISTER_COMPONENT

// -----------------------------------------------------------------------------

#define REGISTER_COMPONENT(x) #x
static char* ComponentType[] =
{
    #include "ComponentTypes.h"
    "Total"
};
#endif REGISTER_COMPONENT

// -----------------------------------------------------------------------------

class IComponent
{
public:
    IComponent();
    virtual Initialize() = 0;
    virtual ~IComponent() {}
private:
};

#endif // ICOMPONENT_H

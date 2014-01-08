#pragma once

#include <string>

class Metadata;

class Member
{
    public:
        Member(std::string name, unsigned offset,const Metadata* meta);

        const std::string& GetName(void) const;
        unsigned GetOffset(void) const;
        const Metadata* GetMetaData(void) const;


        /*
            Description: 
                Deserialize function. Takes the component the data
                is going to belong to and the source of the data,
                the std::istream reference.

            Notes: 
                This function differs from engine to engine, where
                the first parameter is whatever entity this data
                belongs to.

            Method:
                To get the data member off the serializable entity,
                we are going to use the offset value of this member
                in the entity.
        */
        /*void deserialize(IComponent* component,std::istream& input)*/

    private:
        std::string m_Name; 
        unsigned m_Offset;
        const Metadata* m_Meta;
};

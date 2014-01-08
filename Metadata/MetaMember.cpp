#include "MetaMember.h"
#include "Metadata.h"

Member::Member(std::string name, 
               unsigned offset, 
               const Metadata* meta) : m_Name(name),
                                       m_Offset(offset),
                                       m_Meta(meta)
{
}

const std::string& Member::GetName(void) const
{
    return m_Name;
}

unsigned Member::GetOffset(void) const
{
    return m_Offset;
}

const Metadata* Member::GetMetaData(void) const
{
    return m_Meta;
}

/*void Member::deserialize(IComponent* component,std::istream& input)
{
    //Get pointer to data in component
    char* offsetVar = (reinterpret_cast<char*>(&component) + m_Offset);

    //Now input the data.
    //if the member is a primitive, serialize normally,
    //otherwise deserialize the User Define Type
    if(m_Name == "int")
    {
        int* member = (reinterpret_cast<int*>(offsetVar));
        (*member) << input;
    }
    else if(m_Name == "float")
    {
        float* member = (reinterpret_cast<float*>(offsetVar));
        (*member) << input;
    }
    else if(m_Name == "unsigned")
    {
        unsigned* member = (reinterpret_cast<unsigned*>(offsetVar));
        (*member) << input;
    }
    else if(m_Name == "double")
    {
        double* member = (reinterpret_cast<double*>(offsetVar));
        (*member) << input;
    }
    else if(m_Name == "bool")
    {
        bool* member = (reinterpret_cast<bool*>(offsetVar));
        (*member) << input;
    }
    else if(m_Name == "char")
    {
        char* member = (reinterpret_cast<char*>(offsetVar));
        member << input;
    }
    //if it is a composition
    //pass the input into its deserialize function
    else
    {
        std::string name;

        while(input)
        {
            name << input; //reading name of composition's first member

            Member* member = m_Meta->GetProperty(name);//getting first member
            member->deserialize(component,input);//giving stream to member to deserialize
        }
    }
}
*/

#pragma once

#include <vector>
#include <map>
#include <stdio.h>
#include <set>

#include "Metamember.h"
#include "MetaMacros.h"
#include "MetaLookUp.h"

class Function;

/*
    Description: Stores information about user defined
    classes. Bare-bone of the reflection system.
*/
class Metadata
{
  public:
      Metadata(const char* name, size_t size, const Metadata* parent, bool primitive = false);
      ~Metadata(void);

      const char* name(void) const;
      size_t size(void) const;

      /*
        Description: Use this method to determine if this class
        is not a base. If a nullptr pointer is returned, then this
        Metadata instance reflects the base of a hierarchy.
      */
      const Metadata* parent(void) const;

      /*
        Description: Use this method to determine if this
        Metadata reflection is-a base.
      */
      bool isa(const Metadata* base) const;

      /*
        Description: Adds a Member to the Metadata's vector
        of Members. The member is defined with a name,
        offset from the start, and a pointer to its own 
        Metadata object.
      */      
      template <typename Type>
      void AddMember(std::string name, unsigned offset);

      /*
        Description: returns true if the member is held
        by this instance of the metadata.
      */
      bool HasMember(const std::string& member) const;

      /*
        Description: Function used to bind function pointers
        to this instance of the Metadata.
      */
      void AddFunction(const char* name,Function* fPtr);

      /*
        Description: Inspects the metadata of a type for a 
                     specific method.
      */
      bool HasMethod(const char* method) const;

      /*
        Description: Inspects the metadata of a type for a 
                     specific method.
      */
      const Function* getMethod(const char* methodName) const;

      /*
        Description: Adds to the set of conversions a new 
                     conversion type.
      */
      void AddConversion(const char* type);

      /*
        Description: Inspects if this object type can convert
                     to a given type.
      */
      bool CanConvertTo(const char* type) const;

      /*
        Description: A copy method that copies the data from
                     src to dest equal to the size of the
                     object this metadata holds info of completely
                     in bytes
      */
      void Copy(void* dest, const void* src) const;

      /*
        Description: Given some data of same size as the data
                     this metadata object represents, delete the 
                     data.
      */
      void Delete(void* data) const;

      /*
        Description: Given a src void pointer(that is ultimately
                     the same type as the type of data this metadata
                     object represents), make a copy of the source
                     and return it as a void pointer.
      */
      template <typename Type>
      void* NewCopy(const Type& src) const
      {
          void* data = new char[m_Size];
          std::memcpy(data,reinterpret_cast<void*>(src),m_Size);
          return data;
      }

      /*
        Description: Hand some data to the user equal to the size
                     in bytes of the data type this metadata instance
                     represents.
      */
      void* New(void) const;

  private:
      typedef std::vector<Member*>              Members;
      typedef std::map<const char*,Function*>   Methods;
      typedef std::set<const char*>             Conversions;

      const char*     m_Name;        //name of the class being reflected
      size_t          m_Size;        //total size of the class
      bool            m_IsPrimitive; //determines whether or not the Metadata is a primitive type
      const Metadata* m_Parent;      //pointer to parent class in hierarchy if available.
      Members         m_Members;     //vector that holds data of all class members
      Methods         m_Methods;     //map that holds data of all class methods
      Conversions     m_Conversions; //set that holds all possible other types this refered type can convert to
};


template <typename Type>
void Metadata::AddMember(std::string name, unsigned offset)
{
    //Every Type must have a default constructor
    Member* temp = new Member(name,offset,META(*(static_cast<Type*>(0))));
    m_Members.push_back(temp);
    printf("Adding member %s\n", name.c_str());
}


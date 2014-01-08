#pragma once

#include <map>
#include <string>
#include "Metadata.h"

class MetaManager
{
  public:
      static void registerMeta(const Metadata* meta)
      {
          MetaMap& metas = getMetas();
          metas[meta->name()] = meta;
      }

      static const Metadata* get(const char* name)
      {
          const MetaMap& metas = getMetas();
          MetaMap::const_iterator meta = metas.find(name);
          return meta == metas.end() ? NULL : meta->second;
      }

  private:
      typedef std::map<std::string, const Metadata*> MetaMap;

      static MetaMap& getMetas(void)
      {
          //Hidden boolean value is used to determine 
          //if metas should be initialized
          //Since we almost never access this 
          //function, it is okay to have a static
          //local variable and have that small 
          //overhead
          static MetaMap metas;
          return metas;
      }
};
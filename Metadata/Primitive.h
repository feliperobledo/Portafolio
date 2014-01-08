#pragma once

#include "Meta.h"

class Primitive
{
    private:
       DECLARE_META(Primitive)
       {
           //int conversions
           META_ADD_CONVERSION(int,double);
           META_ADD_CONVERSION(int,float);
           META_ADD_CONVERSION(int,unsigned);
           META_ADD_CONVERSION(int,long);

           //float conversions
           META_ADD_CONVERSION(float,double);
           META_ADD_CONVERSION(float,int);
           META_ADD_CONVERSION(float,unsigned);
           META_ADD_CONVERSION(float,long);

           //double conversions


           //unsigned conversions
           META_ADD_CONVERSION(unsigned,long);
           META_ADD_CONVERSION(unsigned,float);
           META_ADD_CONVERSION(unsigned,int);

           //bool conversions
           META_ADD_CONVERSION(bool,short);
           META_ADD_CONVERSION(bool,float);
           META_ADD_CONVERSION(bool,unsigned);
           META_ADD_CONVERSION(bool,char);
           META_ADD_CONVERSION(bool,short);
           META_ADD_CONVERSION(bool,double);
           META_ADD_CONVERSION(bool,int);

           //char conversions
           META_ADD_CONVERSION(char,int);
           META_ADD_CONVERSION(char,unsigned);
           META_ADD_CONVERSION(char,short);
           META_ADD_CONVERSION(char,short);

           //long conversions
           META_ADD_CONVERSION(long,float);
           META_ADD_CONVERSION(long,double);
           META_ADD_CONVERSION(long,unsigned);
           META_ADD_CONVERSION(long,int);

           //short conversions
           META_ADD_CONVERSION(short,long);
           META_ADD_CONVERSION(short,float);
           META_ADD_CONVERSION(short,double);
           META_ADD_CONVERSION(short,unsigned);
           META_ADD_CONVERSION(short,int);
       }
};
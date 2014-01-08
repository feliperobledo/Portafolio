#pragma once

#include <vector>
#include "RefVariant.h"

/*
 * Description:
 *   This holds a pointer to a function. This function
 *   will be bound to a specific metadata.
 */
class Function
{
    /***********************************************************
                     Public Dummy Declarations
    ************************************************************/
    public:
        struct BaseObject1 {};
        struct BaseObject2 {};
        struct ChildObject : public BaseObject1 {};       
        struct GenericMultiClass : public BaseObject1, public BaseObject2 {};
        

    /***********************************************************
        Public typedef declarations for function and Methods
    ************************************************************/
        //Coat that specifiesa function at global scope        
        typedef void (*StaticFunc) (void);
        typedef void (BaseObject1::*ObjectMethod)(void);
        typedef void (ChildObject::*InherentObjectMethod)(void);
        typedef void (GenericMultiClass::*DoubleInherentObjectMethod)(void);

    /***********************************************************
              Public Union for Function Definition
    ************************************************************/
    public:
        union FunctionPointer
        {
            StaticFunc staticFunc;
            ObjectMethod objectMethod;
            InherentObjectMethod inherentObjectMethod;
            DoubleInherentObjectMethod DoubleInherentObjectMethod;
        };

    /***********************************************************
           Fuction Constructors For Non Const Methods
    ************************************************************/
    public:
        //Constructor for methods taking void and returning void
        template <typename ObjectType>
        Function(void (ObjectType::*Method)(void))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
        }

        //Constructor for methods taking 0 arguments and returning something
        template <typename ObjectType, typename ReturnType>
        Function(ReturnType (ObjectType::*Method)(void))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
        }

        //Constructor for methods taking 1 argument and returning void
        template <typename ObjectType, typename A1>
        Function(void (ObjectType::*Method)(A1))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
        }

        //Constructor for methods taking 1 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1>
        Function(ReturnType (ObjectType::*Method)(A1))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
        }

        //Constructor for methods taking 2 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2>
        Function(ReturnType (ObjectType::*Method)(A1,A2))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
        }

        //Constructor for methods taking 3 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
        }

        //Constructor for methods taking 4 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
        }

        //Constructor for methods taking 5 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
        }

        //Constructor for methods taking 6 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
        }

        //Constructor for methods taking 7 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6,typename A7>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
            m_Args.push_back(META_TYPE(A7));
        }

        //Constructor for methods taking 8 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6,typename A7, typename A8>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7,A8))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
            m_Args.push_back(META_TYPE(A7));
            m_Args.push_back(META_TYPE(A8));
        }

        //Constructor for methods taking 9 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6,typename A7, typename A8, typename A9>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7,A8,A9))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
            m_Args.push_back(META_TYPE(A7));
            m_Args.push_back(META_TYPE(A8));
            m_Args.push_back(META_TYPE(A9));
        }

        //Constructor for methods taking 10 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6,typename A7, typename A8, typename A9, typename A10>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7,A8,A9,A10))
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
            m_Args.push_back(META_TYPE(A7));
            m_Args.push_back(META_TYPE(A8));
            m_Args.push_back(META_TYPE(A9));
            m_Args.push_back(META_TYPE(A10));
        }

    /***********************************************************
           Fuction Constructors For Const Methods
    ************************************************************/
    public:
        //Constructor for methods taking void and returning void
        template <typename ObjectType>
        Function(void (ObjectType::*Method)(void) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
        }

        //Constructor for methods taking 0 arguments and returning something
        template <typename ObjectType, typename ReturnType>
        Function(ReturnType (ObjectType::*Method)(void) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
        }

        //Constructor for methods taking 1 argument and returning void
        template <typename ObjectType, typename A1>
        Function(void (ObjectType::*Method)(A1) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
        }

        //Constructor for methods taking 1 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1>
        Function(ReturnType (ObjectType::*Method)(A1) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
        }

        //Constructor for methods taking 2 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2>
        Function(ReturnType (ObjectType::*Method)(A1,A2) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
        }

        //Constructor for methods taking 3 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
        }

        //Constructor for methods taking 4 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
        }

        //Constructor for methods taking 5 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
        }

        //Constructor for methods taking 6 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
        }

        //Constructor for methods taking 7 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6,typename A7>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
            m_Args.push_back(META_TYPE(A7));
        }

        //Constructor for methods taking 8 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6,typename A7, typename A8>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7,A8) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
            m_Args.push_back(META_TYPE(A7));
            m_Args.push_back(META_TYPE(A8));
        }

        //Constructor for methods taking 9 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6,typename A7, typename A8, typename A9>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7,A8,A9) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
            m_Args.push_back(META_TYPE(A7));
            m_Args.push_back(META_TYPE(A8));
            m_Args.push_back(META_TYPE(A9));
        }

        //Constructor for methods taking 10 argument and with a return value
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6,typename A7, typename A8, typename A9, typename A10>
        Function(ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7,A8,A9,A10) const)
        {
            m_Function.objectMethod = reinterpret_cast<ObjectMethod>(Method);
            m_Args.push_back(META_TYPE(A1));
            m_Args.push_back(META_TYPE(A2));
            m_Args.push_back(META_TYPE(A3));
            m_Args.push_back(META_TYPE(A4));
            m_Args.push_back(META_TYPE(A5));
            m_Args.push_back(META_TYPE(A6));
            m_Args.push_back(META_TYPE(A7));
            m_Args.push_back(META_TYPE(A8));
            m_Args.push_back(META_TYPE(A9));
            m_Args.push_back(META_TYPE(A10));
        }


    /***********************************************************
                   Utility Function Methods
    ************************************************************/
    public:
        unsigned GetArgCount(void) const
        {
            return m_Args.size();
        }

    /***********************************************************
                         Fuction Destructor
    ************************************************************/
    public:
        //Destructor
        ~Function(void) 
        {
        }

    /***********************************************************
             Function operator() for Non Const Methods       
    ************************************************************/
    public:
        //Calling a method with no arguments and no return
        template <typename ObjectType>
        void operator()(ObjectType& obj) const
        { 
            typedef void (ObjectType::*MethodSignature)(void);//Create the signature
            RefVariant caller(obj);                           //Wrap caller in a variant
            RefVariant retrn(*reinterpret_cast<int*>(0));     //Build dummy return for simple method
            CallHelper helper;                                //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller, retrn,NULL,0);//"Call" the function
        }

        //Calling a method with no arguments and return
        template <typename ObjectType, typename ReturnType>
        void operator()(ObjectType& obj, ReturnType& retVar) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(void);//Create the signature
            RefVariant caller(obj);                                 //Wrap caller in a variant
            RefVariant retrn(retVar);                               //Wrap variable to store return type in a variant
            CallHelper helper;                                      //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller, retrn,NULL,0);//"Call" the function
        }

        //Method with 1 argument and a return
        template <typename ObjectType, typename ReturnType, typename A1>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1);//Create the signature
            RefVariant caller(obj);                               //Wrap caller in a variant
            RefVariant retrn(retVar);                             //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1) } ;

            CallHelper helper;                                                    //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller, retrn,params,1);//"Call" the function
        }

        //Method with 2 arguments and a return
        template <typename ObjectType, typename ReturnType, typename A1, typename A2>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1, A2& par2) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1,A2);//Create the signature
            RefVariant caller(obj);                                  //Wrap caller in a variant
            RefVariant retrn(retVar);                                //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1,par2))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1),
                                    RefVariant(par2)} ;

            CallHelper helper;                                                   //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller,retrn,params,2);//"Call" the function
        }

        //Method with 3 arguments and a return
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1,A2& par2,A3& par3) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1,A2,A3);//Create the signature
            RefVariant caller(obj);                                     //Wrap caller in a variant
            RefVariant retrn(retVar);                                   //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1,par2,par3))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1),
                                    RefVariant(par2),
                                    RefVariant(par3) };

            CallHelper helper;                                                   //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller,retrn,params,3);//"Call" the function
        }

        //Method with 4 arguments and a return
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1,A2& par2,A3& par3,A4& par4) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1,A2,A3,A4);//Create the signature
            RefVariant caller(obj);                                     //Wrap caller in a variant
            RefVariant retrn(retVar);                                   //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1,par2,par3,par4))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1),
                                    RefVariant(par2),
                                    RefVariant(par3),
                                    RefVariant(par4)};

            CallHelper helper;                                                   //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller,retrn,params,4);//"Call" the function
        }

        //Method with 5 arguments and a return
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1,A2& par2,A3& par3,A4& par4,A5& par5) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1,A2,A3,A4,A5);//Create the signature
            RefVariant caller(obj);                                     //Wrap caller in a variant
            RefVariant retrn(retVar);                                   //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1,par2,par3,par4,par5))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1),
                                    RefVariant(par2),
                                    RefVariant(par3),
                                    RefVariant(par4),
                                    RefVariant(par5)};

            CallHelper helper;                                                   //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller,retrn,params,5);//"Call" the function
        }

        //Method with 6 arguments and a return
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1,A2& par2,A3& par3,A4& par4,A5& par5,A6& par6) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1,A2,A3,A4,A5,A6);//Create the signature
            RefVariant caller(obj);                                     //Wrap caller in a variant
            RefVariant retrn(retVar);                                   //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1,par2,par3,par4,par5,par6))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1),
                                    RefVariant(par2),
                                    RefVariant(par3),
                                    RefVariant(par4),
                                    RefVariant(par5),
                                    RefVariant(par6)};

            CallHelper helper;                                                   //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller,retrn,params,6);//"Call" the function
        }

        //Method with 7 arguments and a return
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6, typename A7>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1,A2& par2,A3& par3,A4& par4,A5& par5,A6& par6,A7& par7) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1,A2,A3,A4,A5,A6,A7);//Create the signature
            RefVariant caller(obj);                                     //Wrap caller in a variant
            RefVariant retrn(retVar);                                   //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1,par2,par3,par4,par5,par6,par7))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1),
                                    RefVariant(par2),
                                    RefVariant(par3),
                                    RefVariant(par4),
                                    RefVariant(par5),
                                    RefVariant(par6),
                                    RefVariant(par7)};

            CallHelper helper;                                                   //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller,retrn,params,7);//"Call" the function
        }

        //Method with 8 arguments and a return
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6, typename A7, typename A8>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1,A2& par2,A3& par3,A4& par4,A5& par5,A6& par6,A7& par7,A8& par8) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1,A2,A3,A4,A5,A6,A7,A8);//Create the signature
            RefVariant caller(obj);                                     //Wrap caller in a variant
            RefVariant retrn(retVar);                                   //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1,par2,par3,par4,par5,par6,par7,par8))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1),
                                    RefVariant(par2),
                                    RefVariant(par3),
                                    RefVariant(par4),
                                    RefVariant(par5),
                                    RefVariant(par6),
                                    RefVariant(par7),
                                    RefVariant(par8)};

            CallHelper helper;                                                   //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller,retrn,params,8);//"Call" the function
        }

        //Method with 9 arguments and a return
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6, typename A7, typename A8,typename A9>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1,A2& par2,A3& par3,A4& par4,A5& par5,A6& par6,A7& par7,A8& par8,A9& par9) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1,A2,A3,A4,A5,A6,A7,A8,A9);//Create the signature
            RefVariant caller(obj);                                     //Wrap caller in a variant
            RefVariant retrn(retVar);                                   //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1,par2,par3,par4,par5,par6,par7,par8,par9))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1),
                                    RefVariant(par2),
                                    RefVariant(par3),
                                    RefVariant(par4),
                                    RefVariant(par5),
                                    RefVariant(par6),
                                    RefVariant(par7),
                                    RefVariant(par8)
                                    RefVariant(par9)};

            CallHelper helper;                                                   //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller,retrn,params,9);//"Call" the function
        }

        //Method with 10 arguments and a return
        template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3, typename A4, typename A5, typename A6, typename A7, typename A8,typename A9, typename A10>
        void operator()(ObjectType& obj, ReturnType& retVar,A1& par1,A2& par2,A3& par3,A4& par4,A5& par5,A6& par6,A7& par7,A8& par8,A9& par9,A10& par10) const
        { 
            typedef ReturnType (ObjectType::*MethodSignature)(A1,A2,A3,A4,A5,A6,A7,A8,A9,A10);//Create the signature
            RefVariant caller(obj);                                     //Wrap caller in a variant
            RefVariant retrn(retVar);                                   //Wrap variable to store return type in a variant

            //Verify Param are of function argument types
            if(!SameParamTypes(par1,par2,par3,par4,par5,par6,par7,par8,par9,par10))
                return;

            //Else, construct an argument list
            RefVariant params[] = { RefVariant(par1),
                                    RefVariant(par2),
                                    RefVariant(par3),
                                    RefVariant(par4),
                                    RefVariant(par5),
                                    RefVariant(par6),
                                    RefVariant(par7),
                                    RefVariant(par8)
                                    RefVariant(par9)
                                    RefVariant(par10)};

            CallHelper helper;                                                   //Create the call helper
            helper.MethodCall<MethodSignature>(m_Function,caller,retrn,params,10);//"Call" the function
        }

    /***********************************************************
             Function private type identification helpers
    ************************************************************/
    private: 
        template <typename A1>
        bool SameParamTypes(A1&) const
        {
            return META_TYPE(A1) == m_Args[0];
        }

        template <typename A1, typename A2>
        bool SameParamTypes(A1&,A2&) const
        {
            const Metadata* args[] = { META_TYPE(A1), 
                                       META_TYPE(A2) };

            for(unsigned i = 0; i < m_Args.size(); ++i)
            {
                if(args[i] != m_Args[i])
                    return false;
            }

            return true;
        }

        template <typename A1, typename A2, typename A3>
        bool SameParamTypes(A1&,A2&,A3&) const
        {
            const Metadata* args[] = { META_TYPE(A1), 
                                       META_TYPE(A2),
                                       META_TYPE(A3) };

            for(unsigned i = 0; i < m_Args.size(); ++i)
            {
                if(args[i] != m_Args[i])
                    return false;
            }

            return true;
        }

        template <typename A1, typename A2, typename A3,typename A4>
        bool SameParamTypes(A1&,A2&,A3&,A4&) const
        {
            const Metadata* args[] = { META_TYPE(A1), 
                                       META_TYPE(A2),
                                       META_TYPE(A3),
                                       META_TYPE(A4)};

            for(unsigned i = 0; i < m_Args.size(); ++i)
            {
                if(args[i] != m_Args[i])
                    return false;
            }

            return true;
        }

        template <typename A1, typename A2, typename A3,typename A4,typename A5>
        bool SameParamTypes(A1&,A2&,A3&,A4&,A5&) const
        {
            const Metadata* args[] = { META_TYPE(A1), 
                                       META_TYPE(A2),
                                       META_TYPE(A3),
                                       META_TYPE(A4),
                                       META_TYPE(A5)};

            for(unsigned i = 0; i < m_Args.size(); ++i)
            {
                if(args[i] != m_Args[i])
                    return false;
            }

            return true;
        }

        template <typename A1, typename A2, typename A3,typename A4,typename A5,typename A6>
        bool SameParamTypes(A1&,A2&,A3&,A4&,A5&,A6&) const
        {
            const Metadata* args[] = { META_TYPE(A1), 
                                       META_TYPE(A2),
                                       META_TYPE(A3),
                                       META_TYPE(A4),
                                       META_TYPE(A5),
                                       META_TYPE(A6)};

            for(unsigned i = 0; i < m_Args.size(); ++i)
            {
                if(args[i] != m_Args[i])
                    return false;
            }

            return true;
        }

        template <typename A1, typename A2, typename A3,typename A4,typename A5,typename A6,typename A7>
        bool SameParamTypes(A1&,A2&,A3&,A4&,A5&,A6&,A7&) const
        {
            const Metadata* args[] = { META_TYPE(A1), 
                                       META_TYPE(A2),
                                       META_TYPE(A3),
                                       META_TYPE(A4),
                                       META_TYPE(A5),
                                       META_TYPE(A6),
                                       META_TYPE(A7)};

            for(unsigned i = 0; i < m_Args.size(); ++i)
            {
                if(args[i] != m_Args[i])
                    return false;
            }

            return true;
        }

        template <typename A1, typename A2, typename A3,typename A4,typename A5,typename A6,typename A7, typename A8>
        bool SameParamTypes(A1&,A2&,A3&,A4&,A5&,A6&,A7&,A8&) const
        {
            const Metadata* args[] = { META_TYPE(A1), 
                                       META_TYPE(A2),
                                       META_TYPE(A3),
                                       META_TYPE(A4),
                                       META_TYPE(A5),
                                       META_TYPE(A6),
                                       META_TYPE(A7),
                                       META_TYPE(A8)};

            for(unsigned i = 0; i < m_Args.size(); ++i)
            {
                if(args[i] != m_Args[i])
                    return false;
            }

            return true;
        }

        template <typename A1, typename A2, typename A3,typename A4,typename A5,typename A6,typename A7, typename A8,typename A9>
        bool SameParamTypes(A1&,A2&,A3&,A4&,A5&,A6&,A7&,A8&,A9&) const
        {
            const Metadata* args[] = { META_TYPE(A1), 
                                       META_TYPE(A2),
                                       META_TYPE(A3),
                                       META_TYPE(A4),
                                       META_TYPE(A5),
                                       META_TYPE(A6),
                                       META_TYPE(A7),
                                       META_TYPE(A8),
                                       META_TYPE(A9)};

            for(unsigned i = 0; i < m_Args.size(); ++i)
            {
                if(args[i] != m_Args[i])
                    return false;
            }

            return true;
        }

        template <typename A1, typename A2, typename A3,typename A4,typename A5,typename A6,typename A7, typename A8,typename A9, typename A10>
        bool SameParamTypes(A1&,A2&,A3&,A4&,A5&,A6&,A7&,A8&,A9&,A10&) const
        {
            const Metadata* args[] = { META_TYPE(A1), 
                                       META_TYPE(A2),
                                       META_TYPE(A3),
                                       META_TYPE(A4),
                                       META_TYPE(A5),
                                       META_TYPE(A6),
                                       META_TYPE(A7),
                                       META_TYPE(A8),
                                       META_TYPE(A9),
                                       META_TYPE(10)};

            for(unsigned i = 0; i < m_Args.size(); ++i)
            {
                if(args[i] != m_Args[i])
                    return false;
            }

            return true;
        }
    /***********************************************************
                     Function private typedefs
    ************************************************************/
    private:
        typedef std::vector<const Metadata*> ArgumentData;

    /***********************************************************
                     Function Private Members
    ************************************************************/
    private:
        FunctionPointer m_Function;
        ArgumentData m_Args;

    /***********************************************************
        Function private helper class (for calling method)
    ************************************************************/
    private:        
        //This class receives all of the data needed to call
        //the function given to it by the Function class.        
        class CallHelper
        {
            /***********************************************************
                  CallHelper Indirection Method for Call Deduction
            ************************************************************/
            public:                    
                template <typename Signature> //already a pointer to function
                void MethodCall(const FunctionPointer& method,
                                RefVariant& caller,
                                RefVariant& ret,
                                RefVariant* args,
                                unsigned argCount)
                {
                    Call( reinterpret_cast<Signature>(const_cast<FunctionPointer&>(method).objectMethod),
                          caller,ret,args,argCount);
                }

            /***********************************************************
                           CallHelper Call Methods
            ************************************************************/
            private:                
                template <typename ObjectType>
                void Call( void (ObjectType::*Method)(void),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    CALL_FN( caller.GetValue<ObjectType*>(), Method)();
                }

                template <typename ObjectType, typename ReturnType>
                void Call( ReturnType (ObjectType::*Method)(void),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)();
                }

                template <typename ObjectType, typename ReturnType, typename A1>
                void Call( ReturnType (ObjectType::*Method)(A1),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()) );
                }

                template <typename ObjectType, typename ReturnType, typename A1, typename A2>
                void Call( ReturnType (ObjectType::*Method)(A1,A2),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()),
                                                                          *(args[1].GetValue<A2*>()) 
                                                                        );                         
                }

                template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3>
                void Call( ReturnType (ObjectType::*Method)(A1,A2,A3),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()),
                                                                          *(args[1].GetValue<A2*>()),
                                                                          *(args[2].GetValue<A3*>())
                                                                        );                         
                }

                template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3,typename A4>
                void Call( ReturnType (ObjectType::*Method)(A1,A2,A3,A4),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()),
                                                                          *(args[1].GetValue<A2*>()),
                                                                          *(args[2].GetValue<A3*>()),
                                                                          *(args[3].GetValue<A4*>())
                                                                        );                         
                }

                template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3,typename A4,typename A5>
                void Call( ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()),
                                                                          *(args[1].GetValue<A2*>()),
                                                                          *(args[2].GetValue<A3*>()),
                                                                          *(args[3].GetValue<A4*>()),
                                                                          *(args[4].GetValue<A5*>())
                                                                        );                         
                }

                template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3,typename A4,typename A5,typename A6>
                void Call( ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()),
                                                                          *(args[1].GetValue<A2*>()),
                                                                          *(args[2].GetValue<A3*>()),
                                                                          *(args[3].GetValue<A4*>()),
                                                                          *(args[4].GetValue<A5*>()),
                                                                          *(args[5].GetValue<A6*>())
                                                                        );                         
                }

                template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3,typename A4,typename A5,typename A6,typename A7>
                void Call( ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()),
                                                                          *(args[1].GetValue<A2*>()),
                                                                          *(args[2].GetValue<A3*>()),
                                                                          *(args[3].GetValue<A4*>()),
                                                                          *(args[4].GetValue<A5*>()),
                                                                          *(args[5].GetValue<A6*>()),
                                                                          *(args[6].GetValue<A7*>())
                                                                        );                         
                }

                template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3,typename A4,typename A5,typename A6,typename A7,typename A8>
                void Call( ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7,A8),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()),
                                                                          *(args[1].GetValue<A2*>()),
                                                                          *(args[2].GetValue<A3*>()),
                                                                          *(args[3].GetValue<A4*>()),
                                                                          *(args[4].GetValue<A5*>()),
                                                                          *(args[5].GetValue<A6*>()),
                                                                          *(args[6].GetValue<A7*>()),
                                                                          *(args[7].GetValue<A8*>())
                                                                        );                         
                }

                template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3,typename A4,typename A5,typename A6,typename A7,typename A8,typename A9>
                void Call( ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7,A8,A9),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()),
                                                                          *(args[1].GetValue<A2*>()),
                                                                          *(args[2].GetValue<A3*>()),
                                                                          *(args[3].GetValue<A4*>()),
                                                                          *(args[4].GetValue<A5*>()),
                                                                          *(args[5].GetValue<A6*>()),
                                                                          *(args[6].GetValue<A7*>()),
                                                                          *(args[7].GetValue<A8*>()),
                                                                          *(args[8].GetValue<A9*>())
                                                                        );                         
                }

                template <typename ObjectType, typename ReturnType, typename A1, typename A2, typename A3,typename A4,typename A5,typename A6,typename A7,typename A8,typename A9,typename A10>
                void Call( ReturnType (ObjectType::*Method)(A1,A2,A3,A4,A5,A6,A7,A8,A9,A10),
                           RefVariant& caller,
                           RefVariant& ret,
                           RefVariant* args,
                           unsigned argCount)
                {
                    *(ret.GetValue<ReturnType*>()) = 
                        CALL_FN( caller.GetValue<ObjectType*>(), Method)( *(args[0].GetValue<A1*>()),
                                                                          *(args[1].GetValue<A2*>()),
                                                                          *(args[2].GetValue<A3*>()),
                                                                          *(args[3].GetValue<A4*>()),
                                                                          *(args[4].GetValue<A5*>()),
                                                                          *(args[5].GetValue<A6*>()),
                                                                          *(args[6].GetValue<A7*>()),
                                                                          *(args[7].GetValue<A8*>()),
                                                                          *(args[8].GetValue<A9*>()),
                                                                          *(args[9].GetValue<A10*>())
                                                                        );                         
                }
        };
};
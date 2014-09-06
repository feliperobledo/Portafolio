// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  An interface to implement a custom serializer.
//  Every custom serializer is composed of an object store where all data
//  is stored for the lifetime of the serializer. Al data is cached and then
//  eliminated once the
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
// -----------------------------------------------------------------------------
#ifndef ISERIALIZER_H
#define ISERIALIZER_H

#include <QString>
#include <QException>
#include <QByteArray>
#include <exception>
#include <QQueue>

namespace Serializer
{
    class ISerializer
    {
    //Exception class to handle parse errors
    public:
        class ParseError
        {
        public:
          enum ErrorType
          {
              FILE_NOT_FOUND,
              PARSE_ERROR,
              UNEXPECTED_CHAR,
              END_OF_FILE,
              TOTAL
          };

        private:
          ErrorType m_Error;
          QString m_Description;

        public:
          ParseError (ErrorType error,
                      const QString &errStr) : m_Error(error),
                                               m_Description (errStr) {}
          ParseError(const ParseError& rhs) : m_Error(rhs.m_Error),
                                              m_Description(rhs.m_Description) {}

          const char *Description() const throw()
          {
              QByteArray ba = m_Description.toLocal8Bit();
              return ba.constData();
          }
        };


    //Object Store definition
    public:
        //Every serialize has a way to store their data
        class IDataObject
        {
        public:
            IDataObject() {}
            virtual const void* GetDataStore() const = 0;
            virtual void Close() = 0;
            virtual ~IDataObject() {  }
        };

    //ISerializer public interface
    public:
        ISerializer();

        virtual ~ISerializer()
        {
            delete m_ObjectStore;
        }

        //virtual methods
        virtual bool Open(const QString& filename) throw() = 0;
        virtual bool Parse() throw() = 0;

        //Settors and Gettors
        void ObjectStore(IDataObject* objectStore) { m_ObjectStore = objectStore; }
        const IDataObject* ObjectStore() const { return m_ObjectStore; }

        //error-handling methods
        bool HasErrors() const;
        ParseError GetError();

    private:
        //Every serializer stores data in a different way
        IDataObject* m_ObjectStore;

        //For every false, this will contain an error
        QQueue<ParseError> m_ErrorQueue;

    protected:
        void AddError(const ParseError& newError);

    };
}

#endif // ISERIALIZER_H

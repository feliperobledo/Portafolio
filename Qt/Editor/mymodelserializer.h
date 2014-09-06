#ifndef MYMODELSERIALIZER_H
#define MYMODELSERIALIZER_H

#include "ISerializer.h"
#include <QString>
#include <QVector>
#include <QVariant>

namespace SampleModelSerializer
{
    class MyModelSerializer : public Serializer::ISerializer
    {
    public:
        //Class that holds vertex data
        class MyDataHolder : public Serializer::ISerializer::IDataObject
        {
        public:
            struct VertexData
            {
                QVariant vVertSize;
                QVariant vColSize;
                QVector<QVariant> m_vertices;
                QVector<QVariant> m_indices;
            };

        public:
            virtual const void* GetDataStore() const;
            void Close();
            ~MyDataHolder() { Close(); }

        private:
            VertexData m_DataConfig;

        };

    public:
        MyModelSerializer();
        virtual bool Open(const QString& filename) throw();
        virtual bool Parse() throw();
    private:
    };

}

#endif // MYMODELSERIALIZER_H

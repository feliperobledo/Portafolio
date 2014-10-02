// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  An object that holds all the data for an attribute window. Can be queried
//  for data to display on the view.
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
// -----------------------------------------------------------------------------
#include "attribmodel.h"
#include "../engineComponents/model.h"
#include "../engineComponents/transform.h"

AttribModel::AttribModel(QObject *parent) :
    QAbstractTableModel(parent)
{
}

int AttribModel::rowCount(const QModelIndex &) const
{
    //The number of elements we have on the model
    return m_Data.size();
}

int AttribModel::columnCount(const QModelIndex &) const
{
    //The attribute model will only have 2 columns
    return 2;
}

QVariant AttribModel::data(const QModelIndex &index, int role) const
{
    //NEED TO CHANGE THIS!

    //We are only here to display data.
    if (role == Qt::DisplayRole)
    {
       QHash<QString,Attribute>::const_iterator iter = GetRowIter(index.row());

       //Display the data based on the if displaying the name or the data
       if(index.column() == 0)
       {
           return QVariant(iter.key());
       }
       else if(index.column() == 1)
       {

           //This should not be here. The model
           if(iter->m_IsList)
           {
               QString strList;
               QList<QVariant> list = iter->m_Data.toList();

               QList<QVariant>::iterator iter = list.begin();

               while(iter != list.end())
               {
                   strList.push_back(iter->toString());
                   ++iter;
                   if(iter != list.end())
                       strList.push_back(',');
               }

               return strList;
           }
           else
           {
               return iter->m_Data;
           }
       }

    }
    return QVariant();
}

QVariant AttribModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (role == Qt::DisplayRole)
    {
        if (orientation == Qt::Horizontal)
        {
            switch (section)
            {
            case 0:
                return QString("Attribute Name");
            case 1:
                return QString("Value");
            }
        }
    }
    return QVariant();
}

bool AttribModel::setData(const QModelIndex & index, const QVariant & value, int role)
{
    if (role == Qt::EditRole)
    {
        //save value from editor to member m_gridData
        QHash<QString,Attribute>::iterator iter = GetRowIter(index.row());

        //The first column is the name
        if(index.column() == 0)
        {
            //If the key does already exist, then re-add the attribute value
            //with the new key
            QString newKey = value.toString();
            if(m_Data.find(newKey) != m_Data.end())
            {
                Attribute keyVal = iter.value();          //copy
                m_Data.remove(iter.key());                //remove
                m_Data.insert(newKey,keyVal);             //re-insert
            }
        }
        else if(index.column() == 1)
        {
            iter.value().m_Data = value;

            //Something, like the Transform and Model, must care about
            //the change of data.
            emit dataChanged(iter.key(),value);
        }

        //for presentation purposes only: build and emit a joined string
        QString result;

        iter = m_Data.begin();
        for(;iter != m_Data.end();++iter)
        {
            result += iter.key();
            result += QString(" ");
            result += iter.value().m_Data.toString();
        }

        emit editCompleted( result );
    }
    return true;
}

Qt::ItemFlags AttribModel::flags(const QModelIndex & index) const
{
    return Qt::ItemIsEditable | QAbstractTableModel::flags(index);
}

QHash<QString,AttribModel::Attribute>& AttribModel::GetData()
{
    return m_Data;
}

QString AttribModel::GetAttributeType(const QString& name) const
{
    return m_Data.find(name).value().m_Type;
}

// -----------------------------------------------------------------------------

void AttribModel::SetToEngineData(Transform*)
{
    QVariant n1, n2, n3;

    //Set the tranlation first first
    //this->m_Data;

    //Set the rotation

    //set the scale
}

void AttribModel::SetToEngineData(Model* model)
{
    Q_UNUSED(model);
}

// -----------------------------------------------------------------------------

QHash<QString,AttribModel::Attribute>::iterator AttribModel::GetRowIter(size_t index)
{
    QHash<QString,Attribute>::iterator iter = m_Data.begin();
    for(size_t i = 0; i < index && iter != m_Data.end(); ++i,++iter);
    return iter;
}

QHash<QString,AttribModel::Attribute>::const_iterator AttribModel::GetRowIter(size_t index) const
{
    QHash<QString,Attribute>::const_iterator iter = m_Data.begin();
    for(size_t i = 0; i < index && iter != m_Data.end(); ++i,++iter);
    return iter;
}

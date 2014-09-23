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
#ifndef ATTRIBMODEL_H
#define ATTRIBMODEL_H

#include <QAbstractTableModel>
#include <QHash>
#include <QString>

class Component;
class Transform;
class Model;

class AttribModel : public QAbstractTableModel
{
    Q_OBJECT
public:
    struct Attribute
    {
        bool m_IsList;
        size_t m_ListSize;
        QVariant m_Data;
        QString m_Type;
    };

    typedef AttribModel::Attribute ModelAttribute;

    explicit AttribModel(QObject *parent = 0);

    void Initialize();

    int rowCount(const QModelIndex &parent = QModelIndex()) const ;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    bool setData(const QModelIndex & index, const QVariant & value, int role = Qt::EditRole);
    Qt::ItemFlags flags(const QModelIndex & index) const ;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const;

    QHash<QString,Attribute>& GetData();
    QString GetAttributeType(const QString &name) const;

    //Series of methods specialized to set the data of the editor to the data
    //of the components that need a visual representation
    void SetToEngineData(Transform*);
    void SetToEngineData(Model*);

signals:
    void editCompleted(const QString &);
    void dataChanged(const QString&,const QVariant&);

public slots:

private:
    QHash<QString,Attribute> m_Data;

private:
    QHash<QString,AttribModel::Attribute>::iterator GetRowIter(size_t index);
    QHash<QString,AttribModel::Attribute>::const_iterator GetRowIter(size_t index) const;
};

#endif // ATTRIBMODEL_H

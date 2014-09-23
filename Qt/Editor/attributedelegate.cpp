// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  A class used to define how items on the attribute editor are to be displayed
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
// -----------------------------------------------------------------------------
#include "attributedelegate.h"
#include "attributeeditor.h"
#include "attribmodel.h"
#include <QList>
#include <QComboBox>
#include <QDoubleSpinBox>
#include <QSpinBox>
#include <QLineEdit>
#include <QCheckBox>

AttributeDelegate::AttributeDelegate(QObject *parent) :
    QItemDelegate(parent)
{
}

void AttributeDelegate::Initialize()
{
    //Init construct functions
    m_EditorLibrary["bool"] = &AttributeDelegate::EditorConstruct_ComboBox;
    m_EditorLibrary["double"] = &AttributeDelegate::EditorConstruct_DoubleSpinBox;
    m_EditorLibrary["int"] = &AttributeDelegate::EditorConstruct_SpinBox;
    m_EditorLibrary["String"] = &AttributeDelegate::EditorConstruct_LineEdit;
    m_EditorLibrary["vec2"] = &AttributeDelegate::EditorConstruct_ListEdit2;
    m_EditorLibrary["vec3"] = &AttributeDelegate::EditorConstruct_ListEdit3;
    m_EditorLibrary["vec4"] = &AttributeDelegate::EditorConstruct_ListEdit4;

}

bool AttributeDelegate::editorEvent(QEvent *event,
                                    QAbstractItemModel *model,
                                    const QStyleOptionViewItem &option,
                                    const QModelIndex &index)
{
    Q_UNUSED(event);Q_UNUSED(model);Q_UNUSED(option);Q_UNUSED(index);
    return false;
}

//Called when doubled clicked on a box
QWidget* AttributeDelegate::createEditor(QWidget *parent,
                                         const QStyleOptionViewItem &option,
                                         const QModelIndex &index) const
{
    Q_UNUSED(option);

    //allow editing only if the first data column is being selected
    if(index.column() == 1)
    {
        const AttribModel* model = dynamic_cast<const AttribModel*>(index.model());
        QModelIndex prevIndex = model->index(index.row(),index.column() - 1);
        QString editName(prevIndex.data().toString());
        QString editType(model->GetAttributeType(editName));

        QWidget* editor = (this->*m_EditorLibrary[editType])(index.data());
        editor->setParent(parent);

        return editor;
    }
    return NULL;
}

void AttributeDelegate::setEditorData(QWidget *editor, const QModelIndex &index) const
{
    if(editor != NULL)
    {
        if(dynamic_cast<QCheckBox*>(editor) != NULL)
        {
            EditorSetData(dynamic_cast<QCheckBox*>(editor),      index);
        }
        else if(dynamic_cast<QDoubleSpinBox*>(editor) != NULL)
        {
            EditorSetData(dynamic_cast<QDoubleSpinBox*>(editor), index);
        }
        else if(dynamic_cast<QSpinBox*>(editor) != NULL)
        {
            EditorSetData(dynamic_cast<QSpinBox*>(editor),       index);
        }
        else if(dynamic_cast<AttributeEditor*>(editor) != NULL)
        {
            EditorSetData(dynamic_cast<AttributeEditor*>(editor),index);
        }
        else if(dynamic_cast<QLineEdit*>(editor) != NULL)
        {
            EditorSetData(dynamic_cast<QLineEdit*>(editor),      index);
        }

    }
}

void AttributeDelegate::setModelData(QWidget* editor,
                                     QAbstractItemModel* model,
                                     const QModelIndex& index) const
{
    if(editor != NULL)
    {
        if(dynamic_cast<QCheckBox*>(editor) != NULL)
        {
            SetModelData(dynamic_cast<QCheckBox*>(editor),model,index);
        }
        else if(dynamic_cast<QDoubleSpinBox*>(editor) != NULL)
        {
            SetModelData(dynamic_cast<QDoubleSpinBox*>(editor),model, index);
        }
        else if(dynamic_cast<QSpinBox*>(editor) != NULL)
        {
            SetModelData(dynamic_cast<QSpinBox*>(editor),model,index);
        }
        else if(dynamic_cast<AttributeEditor*>(editor) != NULL)
        {
            AttributeDelegate::list list;
            SetModelData(dynamic_cast<AttributeEditor*>(editor),model,index, list);
        }
        else if(dynamic_cast<QLineEdit*>(editor) != NULL)
        {
            SetModelData(dynamic_cast<QLineEdit*>(editor),model,index);
        }

    }
}

// -----------------------------------------------------------------------------
void AttributeDelegate::commitAndCloseEditor()
{

}

// -----------------------------------------------------------------------------

QWidget* AttributeDelegate::EditorConstruct_ComboBox(const QVariant &) const
{
    return new QCheckBox();
}

QWidget* AttributeDelegate::EditorConstruct_DoubleSpinBox(const QVariant&) const
{
    return new QDoubleSpinBox();
}

QWidget* AttributeDelegate::EditorConstruct_SpinBox(const QVariant&) const
{
    return new QSpinBox();
}

QWidget* AttributeDelegate::EditorConstruct_LineEdit(const QVariant&) const
{
    //This should probably be my own
    return new QLineEdit();
}

QWidget* AttributeDelegate::EditorConstruct_ListEdit2(const QVariant& data) const
{
    const size_t listSize = 2;
    AttributeEditor* attrEdit = NewAttributeEditor(listSize);
    attrEdit->HoldData(data);
    return attrEdit;
}

QWidget* AttributeDelegate::EditorConstruct_ListEdit3(const QVariant& data) const
{
    const size_t listSize = 3;
    AttributeEditor* attrEdit = NewAttributeEditor(listSize);
    attrEdit->HoldData(data);
    return attrEdit;
}

QWidget* AttributeDelegate::EditorConstruct_ListEdit4(const QVariant& data) const
{
    const size_t listSize = 4;
    AttributeEditor* attrEdit = NewAttributeEditor(listSize);
    attrEdit->HoldData(data);
    return attrEdit;
}

AttributeEditor* AttributeDelegate::NewAttributeEditor(size_t n) const
{
    AttributeEditor* editor = new AttributeEditor(QString("List"));
    editor->SetListSize(n);

    connect(editor,SIGNAL(editingFinished()),
            this,SLOT(commitAndCloseEditor()));

    editor->Initialize();

    return editor;
}

// -----------------------------------------------------------------------------

void AttributeDelegate::EditorSetData(QCheckBox *checkBox, const QModelIndex &index) const
{
    bool value = index.model()->data(index, Qt::EditRole).toBool();
    checkBox->setChecked(value);
}

void AttributeDelegate::EditorSetData(QDoubleSpinBox *spinBox, const QModelIndex &index) const
{
    double value = index.model()->data(index, Qt::EditRole).toInt();
    spinBox->setValue(value);
}

void AttributeDelegate::EditorSetData(QSpinBox *spinBox, const QModelIndex &index) const
{
    int value = index.model()->data(index, Qt::EditRole).toInt();
    spinBox->setValue(value);
}

void AttributeDelegate::EditorSetData(QLineEdit *lineEdit, const QModelIndex &index) const
{
    QString value = index.model()->data(index, Qt::EditRole).toString();
    lineEdit->setText(value);
}

void AttributeDelegate::EditorSetData(AttributeEditor *vecEdit, const QModelIndex &index) const
{
    QString value = index.model()->data(index, Qt::EditRole).toString();
    vecEdit->setText(value);
}

// -----------------------------------------------------------------------------

void AttributeDelegate::SetModelData(QCheckBox *checkBox,QAbstractItemModel* model, const QModelIndex &index) const
{
    model->setData(index, checkBox->isChecked(), Qt::EditRole);
}

void AttributeDelegate::SetModelData(QDoubleSpinBox *doubleSpinBox,QAbstractItemModel* model, const QModelIndex &index) const
{
    doubleSpinBox->interpretText();
    double value = doubleSpinBox->value();
    model->setData(index, value, Qt::EditRole);
}

void AttributeDelegate::SetModelData(QSpinBox *spinBox,QAbstractItemModel* model, const QModelIndex &index) const
{
    spinBox->interpretText();
    int value = spinBox->value();
    model->setData(index, value, Qt::EditRole);
}

void AttributeDelegate::SetModelData(QLineEdit *lineEdit,QAbstractItemModel* model, const QModelIndex &index) const
{
    QString value = lineEdit->text();
    model->setData(index, value, Qt::EditRole);
}

void AttributeDelegate::SetModelData(AttributeEditor *lineEdit,QAbstractItemModel* model,
                                     const QModelIndex &index, AttributeDelegate::list) const
{
    QString value;

    if(lineEdit->text().length() != 0)
    {
        value = lineEdit->text();
    }
    else//If the user clicks outside instead of hitting enter, use the previous value
    {
        value = lineEdit->GetHeldData().toString();
    }

    QList<QVariant> valList;

    //Add the numbers, one by one, to this list that has the actual data
    int currIndex = 0;
    for(size_t i = 0; i < lineEdit->ListSize(); ++i,++currIndex)
    {
        QString currNum("");
        while(currIndex < value.length() &&
              (value[currIndex] != '\n' && value[currIndex] != ','))
        {
            currNum.push_back(value[currIndex]);
            ++currIndex;
        }
        QVariant temp(currNum);
        valList.push_back(temp);
    }


    model->setData(index,valList, Qt::EditRole);
}


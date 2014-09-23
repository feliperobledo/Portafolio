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
#ifndef ATTRIBUTEDELEGATE_H
#define ATTRIBUTEDELEGATE_H

#include <QItemDelegate>
#include <QMap>

class AttributeEditor;
class QCheckBox;
class QDoubleSpinBox;
class QSpinBox;
class QLineEdit;

class AttributeDelegate : public QItemDelegate
{
    Q_OBJECT
public:
    struct list{};

    typedef QWidget* (AttributeDelegate::*EditorConstruct)(const QVariant&) const;
    typedef void (AttributeDelegate::*EditorSet)(QWidget *editor, const QModelIndex &index) const;

    typedef QMap<QString,EditorConstruct> EditorConstructors;
    typedef QMap<QString,EditorSet> EditorSettors;

    explicit AttributeDelegate(QObject *parent = 0);

    void Initialize();

    bool editorEvent(QEvent *event,
                     QAbstractItemModel *model,
                     const QStyleOptionViewItem &option,
                     const QModelIndex &index);

    QWidget* createEditor(QWidget *parent,
                          const QStyleOptionViewItem &option,
                          const QModelIndex &index) const;

    void setEditorData(QWidget *editor, const QModelIndex &index) const;

    void setModelData(QWidget* editor,
                      QAbstractItemModel* model,
                      const QModelIndex& index) const;

signals:

public slots:
    void commitAndCloseEditor();

private:

    EditorConstructors m_EditorLibrary;
    QString* m_CurrEditorType;

    QWidget* EditorConstruct_ComboBox(const QVariant&) const;
    QWidget* EditorConstruct_DoubleSpinBox(const QVariant&) const;
    QWidget* EditorConstruct_SpinBox(const QVariant&) const;
    QWidget* EditorConstruct_LineEdit(const QVariant&) const;
    QWidget* EditorConstruct_ListEdit2(const QVariant&) const;
    QWidget* EditorConstruct_ListEdit3(const QVariant&) const;
    QWidget* EditorConstruct_ListEdit4(const QVariant&) const;

    void EditorSetData(QCheckBox *editor, const QModelIndex &index) const;
    void EditorSetData(QDoubleSpinBox *editor, const QModelIndex &index) const;
    void EditorSetData(QSpinBox *editor, const QModelIndex &index) const;
    void EditorSetData(QLineEdit *editor, const QModelIndex &index) const;
    void EditorSetData(AttributeEditor *editor, const QModelIndex &index) const;

    void SetModelData(QCheckBox *editor,QAbstractItemModel* model, const QModelIndex &index) const;
    void SetModelData(QDoubleSpinBox *editor,QAbstractItemModel* model, const QModelIndex &index) const;
    void SetModelData(QSpinBox *editor,QAbstractItemModel* model, const QModelIndex &index) const;
    void SetModelData(QLineEdit *editor,QAbstractItemModel* model, const QModelIndex &index) const;
    void SetModelData(AttributeEditor *editor,QAbstractItemModel* model, const QModelIndex &index, list) const;

    AttributeEditor* NewAttributeEditor(size_t n) const;


};

#endif // ATTRIBUTEDELEGATE_H

// -----------------------------------------------------------------------------
//  Author: Felipe Robledo
//
//  This class defines the behavior of how data in the attribute editor can be
//  edited, which depends on the type.
//
//  Copyright (C) 2013 DigiPen Institute of Technology.
//  Reproduction or disclosure of this file or its contents without
//  the prior written consent of DigiPen Institute of Technology is
//  prohibited.
// -----------------------------------------------------------------------------
#ifndef ATTRIBUTEEDITOR_H
#define ATTRIBUTEEDITOR_H

#include <QLineEdit>
#include <QMap>
#include <QString>
#include <QVariant>

class AttributeEditor : public QLineEdit
{
    Q_OBJECT
public:
    //Where parent is the index box
    explicit AttributeEditor(QString type, QWidget *parent = 0);

    void Initialize();
    void HoldData(const QVariant &data);
    QVariant GetHeldData();
    void SetListSize(size_t n);
    size_t ListSize();

signals:
    void editingFinished();

public slots:
    void handleNewData(const QString& text);
    void handleErrors();

protected:
    void keyPressEvent(QKeyEvent * event);

private:
    size_t m_ListSize;
    QString m_EditType;
    QString m_CurrLine;
    QString m_PrevData;

    bool ParseForErrors(const QString& newData);

};

#endif // ATTRIBUTEEDITOR_H

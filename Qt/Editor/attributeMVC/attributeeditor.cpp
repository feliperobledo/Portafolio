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
#include "attributeeditor.h"
#include <QKeyEvent>
#include <QDebug>

AttributeEditor::AttributeEditor(QString type, QWidget *parent) :
    QLineEdit(parent),
    m_ListSize(0),
    m_EditType(type)
{
    setEchoMode(QLineEdit::Normal);
}

void AttributeEditor::Initialize()
{
    connect(this,SIGNAL(editingFinished()),
            this,SLOT(handleErrors()));

    //Override default behavior
    //disconnect(this,SIGNAL(textChanged(QString)),
    //           this,SLOT(setText(QString)));
}

void AttributeEditor::HoldData(const QVariant& data)
{
    m_PrevData = data.toString();
    m_CurrLine = m_PrevData;
    setText(m_PrevData);
}

QVariant AttributeEditor::GetHeldData()
{
    return m_PrevData;
}

void AttributeEditor::SetListSize(size_t n)
{
    m_ListSize = n;
}

size_t AttributeEditor::ListSize()
{
    return m_ListSize;
}

void AttributeEditor::keyPressEvent(QKeyEvent * event)
{
    QLineEdit::keyPressEvent(event);

    //Only parse the text if it is a released key
    switch(event->type())
    {
        case QEvent::KeyPress:
        {
            m_CurrLine = displayText();
            break;
        }
        case QEvent::CursorChange:
        {
            //Move the cursor
        }
        default:
        {
            qDebug() << "That event is not supported";
        }
    }
}
// -----------------------------------------------------------------------------

//Don't know which change will happen first, this one or setText
void AttributeEditor::handleNewData(const QString &text)
{
    bool textIsFine = ParseForErrors(text);
    if(!textIsFine)
    {
        //Don't know if I really have to do this
        setText(m_PrevData);
        return;
    }
    setText(text);
}

void AttributeEditor::handleErrors()
{
    //Do text parsing for correctness here...
    emit textChanged(m_CurrLine);
}

bool AttributeEditor::ParseForErrors(const QString& newData)
{
    Q_UNUSED(newData);
    return true;
}

/*
 *   This file is part of dtt, a Daily Task Tracker
 *   Copyright 2017 Shashwat Dixit <shashwatdixit124@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 3 of the
 *   License, or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "subtasklist.h"
#include "subtask.h"

#include <QObject>
#include <QAbstractListModel>

SubTaskList::SubTaskList(QObject *parent) : QAbstractListModel(parent)
{
}

SubTaskList::~SubTaskList()
{
}

QVariant SubTaskList::data(const QModelIndex& index, int role) const
{
	if (index.row() < 0 || index.row() >= m_subTasks.count())
		return QVariant();
	SubTask *t = m_subTasks[index.row()];
	if(role == ID)
		return t->id();
	else if(role == DESCRIPTION)
		return t->description();
	else if(role == CREATEDON)
		return t->createdOn().toString("MMMM dd , yyyy");
	else if(role == UPDATEDON)
		return t->updatedOn().toString("MMMM dd , yyyy");
	else if(role == STATUS)
		return t->status();
	return QVariant();
}

QList<SubTask *> SubTaskList::subTasks()
{
	return m_subTasks;
}

int SubTaskList::rowCount(const QModelIndex& parent) const
{
	Q_UNUSED(parent);
	return m_subTasks.count();
}

void SubTaskList::add(SubTask *st)
{
	if(st->status() != SubTask::PENDING)
		return;
	beginInsertRows(QModelIndex(), 0 , 0);
	m_subTasks.push_front(st);
	endInsertRows();
}

void SubTaskList::update(SubTask *st)
{
	if(st->status() != SubTask::PENDING)
		return;

	for(int i = 0;i<rowCount();i++)
	{
		SubTask *temp = m_subTasks[i];
		if(temp->id() == st->id()) {
			beginRemoveRows(QModelIndex(), i , i);
			endRemoveRows();
			beginInsertRows(QModelIndex(), i , i);
			endInsertRows();
			break;
		}
	}
}

void SubTaskList::remove(SubTask *st)
{
	if(st->status() != SubTask::INVALID)
		return;
	for(int i = 0;i<rowCount();i++)
	{
		SubTask *temp = m_subTasks[i];
		if(temp->id() == st->id()) {
			m_subTasks.removeAt(i);
			beginRemoveRows(QModelIndex(), i , i);
			endRemoveRows();
			break;
		}
	}
}

QHash<int, QByteArray> SubTaskList::roleNames() const
{
	QHash<int, QByteArray> roles;
	roles[ID] = "_ST_id";
	roles[DESCRIPTION] = "_ST_description";
	roles[CREATEDON] = "_ST_createdon";
	roles[UPDATEDON] = "_ST_updatedon";
	roles[STATUS] = "_ST_status";
	return roles;
}

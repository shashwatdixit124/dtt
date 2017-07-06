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

#include "completedtasks.h"
#include "task.h"
#include "taskmanager.h"

#include <QAbstractListModel>
#include <QObject>
#include <QList>

CompletedTasks::CompletedTasks(TaskManager *parent) : QAbstractListModel(parent)
{
	foreach(Task *t, parent->tasks())
	{
		if(t->status() == Task::COMPLETED)
			m_tasks.push_front(t);
	}
	beginInsertRows(QModelIndex(), 0 , rowCount()-1);
	endInsertRows();
	connect(parent,&TaskManager::taskStepped,this,&CompletedTasks::updateAdd);
	connect(parent,&TaskManager::taskDeleted,this,&CompletedTasks::updateDelete);
}

CompletedTasks::~CompletedTasks()
{
}

QVariant CompletedTasks::data(const QModelIndex& index, int role) const
{
	if (index.row() < 0 || index.row() >= m_tasks.count())
		return QVariant();
	Task *t = m_tasks[index.row()];
	if(role == ID)
		return t->id();
	else if(role == TITLE)
		return t->title();
	else if(role == DESCRIPTION)
		return t->description();
	else if(role == SCORE)
		return t->score();
	else if(role == TAG)
		return t->tag();
	else if(role == CREATEDON)
		return t->createdOn().toString("MMMM dd , yyyy");
	else if(role == UPDATEDON)
		return t->updatedOn().toString("MMMM dd , yyyy");
	else if(role == STATUS)
		return t->status();
	return QVariant();
}

int CompletedTasks::rowCount(const QModelIndex& parent) const
{
	Q_UNUSED(parent);
	return m_tasks.count();
}

void CompletedTasks::updateAdd(Task *t)
{
	if(t->status() != Task::COMPLETED)
		return;
	beginInsertRows(QModelIndex(), 0 , 0);
	m_tasks.push_front(t);
	endInsertRows();
}

void CompletedTasks::updateDelete(Task *t)
{
	if(t->status() != Task::COMPLETED)
		return;
	for(int i = 0;i<rowCount();i++)
	{
		Task *tt = m_tasks[i];
		if(tt->id() == t->id()) {
			m_tasks.removeAt(i);
			beginRemoveRows(QModelIndex(), i , i);
			endRemoveRows();
			break;
		}
	}
}

QHash<int, QByteArray> CompletedTasks::roleNames() const
{
	QHash<int, QByteArray> roles;
	roles[ID] = "_T_id";
	roles[TITLE] = "_T_title";
	roles[DESCRIPTION] = "_T_description";
	roles[SCORE] = "_T_score";
	roles[TAG] = "_T_tag";
	roles[CREATEDON] = "_T_createdon";
	roles[UPDATEDON] = "_T_updatedon";
	roles[STATUS] = "_T_status";
	return roles;
}

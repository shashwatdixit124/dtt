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

#ifndef SUBTASKLIST_H
#define SUBTASKLIST_H

#include "subtask.h"

#include <QObject>
#include <QAbstractListModel>

class SubTaskList : public QAbstractListModel
{
	Q_OBJECT
public:

	enum SubTaskInfo {
		ID  = Qt::UserRole + 1,
		DESCRIPTION,
		CREATEDON,
		UPDATEDON,
		STATUS
	};

	explicit SubTaskList(QObject *parent = nullptr);
	~SubTaskList();
	int rowCount(const QModelIndex & parent = QModelIndex()) const;
	QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;
	QList<SubTask> subTasks();

	void add(SubTask);
	void update(SubTask);
	void remove(SubTask);

protected:
	QHash<int, QByteArray> roleNames() const;
	QList<SubTask> m_subTasks;

};

#endif

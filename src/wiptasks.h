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

#ifndef WIPTASKS_H
#define WIPTASKS_H

#include <QObject>
#include <QAbstractListModel>
#include <QList>

class Task;
class TaskManager;

class WipTasks : public QAbstractListModel
{
	Q_OBJECT
public:
	enum TaskInfo {
		ID  = Qt::UserRole + 1,
		TITLE,
		DESCRIPTION,
		PROGRESS,
		TAG,
		CREATEDON,
		UPDATEDON,
		STATUS
	};

	explicit WipTasks(TaskManager *parent);
	~WipTasks();
	int rowCount(const QModelIndex & parent = QModelIndex()) const;
	QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

public Q_SLOTS:
	void updateAdd(Task *);
	void updateStep(Task *);
	void updateDelete(Task *);

protected:
	QHash<int, QByteArray> roleNames() const;
	QList<Task*> m_tasks;

};

#endif


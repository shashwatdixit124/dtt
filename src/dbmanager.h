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

#ifndef DBMANAGER_H
#define DBMANAGER_H

#include "task.h"
#include "subtask.h"

#include <QObject>
#include <QMap>
#include <QtSql/QSqlDatabase>

class DBManager : public QObject
{
	Q_OBJECT
public:
	explicit DBManager(QObject* parent = nullptr);
	~DBManager();

	QList<Task> tasks();

	Task& task(quint16);

	void addTask(Task);
	void addSubTask(SubTask);
	void stepTask(quint16);
	void deleteTask(quint16);
	void deleteSubTask(quint16);

Q_SIGNALS:
	void createdTask(Task);
	void createdSubTask(SubTask);
	void stepped(Task);
	void deletedTask(Task);
	void deletedSubTask(SubTask);

protected:
	bool openDatabase();
	bool closeDatabase();
	bool createDatabase();
	void loadDatabase();
	quint16 loadTasks();
	quint16 loadSubTasks();
	void matchTasksWithSubTasks();

private:
	QSqlDatabase* m_db;
	bool isDbOpen;
	quint16 m_maxTaskId;
	quint16 m_maxSubTaskId;
	QString m_dbPath;
	QString m_dbName;
	QMap<quint16,Task> m_tasks;
	QMap<quint16,SubTask> m_subTasks;
};

#endif

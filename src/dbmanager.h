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

#include <QObject>
#include <QList>
#include <QtSql/QSqlDatabase>

class Task;
class SubTask;

class DBManager : public QObject
{
	Q_OBJECT
public:
	explicit DBManager(QObject* parent = nullptr);
	~DBManager();

	QList<Task*> tasks();
	QList<SubTask*> subTasks();

	bool addTask(Task *);
	bool toggleComplete(Task *);
	bool toggleBookmark(Task *);
	bool deleteTask(Task *);

	bool addSubTask(SubTask *);
	bool stepSubTask(SubTask *);
	bool deleteSubTask(SubTask *);

protected:
	bool openDatabase();
	bool closeDatabase();
	bool createDatabase();

private:
	QSqlDatabase* m_db;
	bool isDbOpen;
	QString m_dbPath;
	QString m_dbName;
};

#endif

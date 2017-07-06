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

#ifndef TASKMANAGER_H
#define TASKMANAGER_H

#include "task.h"

#include <QObject>
#include <QMap>
#include <QList>
#include <QAbstractListModel>
#include <QQmlEngine>
#include <QJSEngine>

class DBManager;
class PendingTasks;
class WipTasks;
class CompletedTasks;

class TaskManager : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QAbstractListModel* pendingTasks READ pendingTasks CONSTANT)
	Q_PROPERTY(QAbstractListModel* wipTasks READ wipTasks CONSTANT)
	Q_PROPERTY(QAbstractListModel* completedTasks READ completedTasks CONSTANT)
	Q_PROPERTY(quint16 currentTask READ currentTask WRITE setCurrentTask NOTIFY currentTaskChanged)
	Q_PROPERTY(QAbstractListModel* subTasks READ subTasks CONSTANT)
	Q_PROPERTY(int maxYValue READ maxYValue CONSTANT)
	Q_PROPERTY(QList<int> pending7Day READ pending7Day CONSTANT)
	Q_PROPERTY(QList<int> wip7Day READ wip7Day CONSTANT)
	Q_PROPERTY(QList<int> completed7Day READ completed7Day CONSTANT)
public:
	explicit TaskManager(QObject* parent = nullptr);
	~TaskManager();

	QAbstractListModel* pendingTasks();
	QAbstractListModel* wipTasks();
	QAbstractListModel* completedTasks();
	QAbstractListModel* subTasks();

	quint16 currentTask();
	void setCurrentTask(quint16);

	int maxYValue();
	QList<int> pending7Day();
	QList<int> wip7Day();
	QList<int> completed7Day();

	Q_INVOKABLE void addTask(QString,QString,quint16,QString);
	Q_INVOKABLE void stepTask(quint16);
	Q_INVOKABLE void deleteTask(quint16);

	static QObject* taskmanager_singleton(QQmlEngine *engine, QJSEngine *scriptEngine);

Q_SIGNALS:
	void updateGraph();
	void currentTaskChanged();

protected Q_SLOTS:
	void load7day();

private:
	DBManager* m_db;
	PendingTasks* m_pending;
	WipTasks* m_wip;
	CompletedTasks* m_completed;
	quint16 m_currTask;
	int m_maxYValue;
	QList<int> m_pending7Day;
	QList<int> m_wip7Day;
	QList<int> m_completed7Day;

};

#endif

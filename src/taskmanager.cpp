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

#include "taskmanager.h"
#include "task.h"
#include "dbmanager.h"
#include "pendingtasks.h"
#include "wiptasks.h"
#include "completedtasks.h"

#include <QObject>

TaskManager::TaskManager(QObject* parent) : QObject(parent) , m_db(new DBManager(this))
{
	m_pending = new PendingTasks(m_db,this);
	m_wip = new WipTasks(m_db,this);
	m_completed = new CompletedTasks(m_db,this);
}

TaskManager::~TaskManager()
{
	m_pending->deleteLater();
	m_wip->deleteLater();
	m_completed->deleteLater();
	m_db->deleteLater();
}

QAbstractListModel * TaskManager::pendingTasks()
{
	return m_pending;
}

QAbstractListModel * TaskManager::wipTasks()
{
	return m_wip;
}

QAbstractListModel * TaskManager::completedTasks()
{
	return m_completed;
}

void TaskManager::addTask(QString title, QString desc, quint16 score, QString tag)
{
	if(title.isEmpty())
		return;
	Task t;
	t.setTitle(title);
	t.setDescription(desc);
	t.setScore(score);
	t.setTag(tag);
	t.setStatus(Task::PENDING);
	m_db->addTask(t);
}

void TaskManager::stepTask(quint16 id)
{
	m_db->stepTask(id);
}

void  TaskManager::deleteTask(quint16 id)
{
	m_db->deleteTask(id);
}

QObject * TaskManager::taskmanager_singleton(QQmlEngine* engine, QJSEngine* scriptEngine)
{
	Q_UNUSED(engine)
	Q_UNUSED(scriptEngine)

	TaskManager *manager = new TaskManager();
	return manager;
}

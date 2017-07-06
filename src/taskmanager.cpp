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
#include <QDate>
#include <QDebug>

TaskManager::TaskManager(QObject* parent) : QObject(parent) , m_db(new DBManager(this)) , m_currTask(0)
{
	m_pending = new PendingTasks(m_db,this);
	m_wip = new WipTasks(m_db,this);
	m_completed = new CompletedTasks(m_db,this);
	connect(m_db,&DBManager::createdTask,this,&TaskManager::load7day);
	connect(m_db,&DBManager::stepped,this,&TaskManager::load7day);
	connect(m_db,&DBManager::deletedTask,this,&TaskManager::load7day);
	for(int i = 0;i<7;i++)
	{
		m_pending7Day.push_back(0);
		m_wip7Day.push_back(0);
		m_completed7Day.push_back(0);
	}
	load7day();
}

TaskManager::~TaskManager()
{
	m_pending->deleteLater();
	m_wip->deleteLater();
	m_completed->deleteLater();
	m_db->deleteLater();
}

quint16 TaskManager::currentTask()
{
	return m_currTask;
}

void TaskManager::setCurrentTask(quint16 id)
{
	m_currTask = id;
	emit currentTaskChanged();
}

QAbstractListModel* TaskManager::subTasks()
{
	Task t = m_db->task(m_currTask);
	if(t.status() == Task::INVALID)
		return;

	return t.subTasks();
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

int TaskManager::maxYValue()
{
	return m_maxYValue;
}

QList<int> TaskManager::pending7Day()
{
	return m_pending7Day;
}

QList<int> TaskManager::wip7Day()
{
	return m_wip7Day;
}

QList<int> TaskManager::completed7Day()
{
	return m_completed7Day;
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

void TaskManager::load7day()
{
	QDate today = QDate::currentDate();
	QList<Task> allTasks = m_db->tasks();
	m_maxYValue = 10;
	for(int i = 0;i<7;i++)
	{
		m_pending7Day[i] = 0;
		m_wip7Day[i] = 0;
		m_completed7Day[i] = 0;
	}
	foreach (Task t, allTasks) {
		int i = t.createdOn().daysTo(today);
		int j = t.updatedOn().daysTo(today);
		if(i < 7 && t.status() == Task::PENDING)
		{
			m_pending7Day[i] += t.score();
			if(m_pending7Day[i] > m_maxYValue)
				m_maxYValue = m_pending7Day[i];
		}
		if(j < 7)
		{
			if(t.status() == Task::WIP) {
				m_wip7Day[j] += t.score();
				if(m_wip7Day[j] > m_maxYValue)
					m_maxYValue = m_wip7Day[j];
			}
			else if(t.status() == Task::COMPLETED) {
				m_completed7Day[j] += t.score();
				if(m_completed7Day[j] > m_maxYValue)
					m_maxYValue = m_completed7Day[j];
			}
		}
	}

	emit updateGraph();
}

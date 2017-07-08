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
#include "subtasklist.h"
#include "dbmanager.h"
#include "pendingtasks.h"
#include "wiptasks.h"
#include "completedtasks.h"

#include <QObject>
#include <QList>
#include <QMap>
#include <QDate>
#include <QDebug>

TaskManager::TaskManager(QObject* parent) : QObject(parent) , m_db(new DBManager(this)) ,
	m_currTask(0) , m_maxSubTaskId(0) , m_maxTaskId(0)
{
	QList<Task*> tasks = m_db->tasks();
	foreach(Task* t, tasks) {
		if(t->id() > m_maxTaskId)
			m_maxTaskId = t->id();
		m_tasks.insert(t->id(),t);
	}

	QList<SubTask*> subTasks = m_db->subTasks();
	foreach (SubTask* s, subTasks) {
		if(s->id() > m_maxSubTaskId)
			m_maxSubTaskId = s->id();
		m_subTasks.insert(s->id(),s);
		m_tasks[s->parentId()]->addSubTask(s);
	}

	m_pending = new PendingTasks(this);
	m_wip = new WipTasks(this);
	m_completed = new CompletedTasks(this);

	for(int i = 0;i<7;i++)
	{
		m_pending7Day.push_back(0);
		m_completed7Day.push_back(0);
	}
	load7day();
}

TaskManager::~TaskManager()
{
	m_pending->deleteLater();
	m_wip->deleteLater();
	m_completed->deleteLater();

	foreach (SubTask * s, m_deletedSubTasks) {
		delete s;
	}

	foreach (Task * t, m_deletedTasks) {
		delete t;
	}

	foreach (SubTask *s, m_subTasks.values()) {
		delete s;
	}

	foreach (Task *t, m_tasks.values()) {
		delete t;
	}

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
	Task *t = m_tasks[m_currTask];
	if(!t)
			return nullptr;
	if(t->status() == Task::INVALID)
		return nullptr;

	return t->list();
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

QList<int> TaskManager::completed7Day()
{
	return m_completed7Day;
}

QList<Task *> TaskManager::tasks()
{
	return m_tasks.values();
}


QString TaskManager::taskTitle(quint16 id)
{
	Task *t = m_tasks.value(id);
	if(!t)
		return QString();
	return t->title();
}

QString TaskManager::taskDescription(quint16 id)
{
	Task *t = m_tasks.value(id);
	if(!t)
		return QString();
	return t->description();
}

QString TaskManager::taskTag(quint16 id)
{
	Task *t = m_tasks.value(id);
	if(!t)
		return QString();
	return t->tag();
}

quint16 TaskManager::taskProgress(quint16 id)
{
	Task *t = m_tasks.value(id);
	if(!t)
		return 0;
	return t->progress();
}

QString TaskManager::taskCreatedOn(quint16 id)
{
	Task *t = m_tasks.value(id);
	if(!t)
		return QString();
	return t->createdOn().toString("MMM dd");
}

QString TaskManager::taskUpdatedOn(quint16 id)
{
	Task *t = m_tasks.value(id);
	if(!t)
		return QString();
	return t->updatedOn().toString("MMM dd");
}

int TaskManager::taskStatus(quint16 id)
{
	Task *t = m_tasks.value(id);
	if(!t)
		return 3;
	return t->status();
}

void TaskManager::addTask(QString title, QString desc, QString tag)
{
	if(title.isEmpty())
		return;
	Task *t = new Task();
	t->setId(++m_maxTaskId);
	t->setTitle(title);
	t->setDescription(desc);
	t->setTag(tag);
	t->setCreatedOn(QDate::currentDate());
	t->setUpdatedOn(QDate());
	t->setStatus(Task::PENDING);
	if(!m_db->addTask(t))
		return;

	m_tasks.insert(t->id(),t);
	emit taskAdded(t);
	load7day();
}

void TaskManager::stepTask(quint16 id)
{
	Task *t = m_tasks[id];
	if(!t)
		return;
	if(!m_db->stepTask(t))
		return;

	t->setUpdatedOn(QDate::currentDate());
	emit taskStepped(t);
	load7day();
}

void  TaskManager::deleteTask(quint16 id)
{
	Task *t = m_tasks[id];
	if(!t)
		return;

	QList<SubTask *> subs = t->subTasks();
	foreach (SubTask *s, subs) {
		deleteSubTask(s->id());
	}

	if(t->subTasks().count() > 0)
		return;

	if(!m_db->deleteTask(t))
		return;

	m_tasks.remove(t->id());

	if(t->id() == m_maxTaskId)
	{
		m_maxTaskId = 0;
		foreach (Task *t, m_tasks.values()) {
			if(t->id() > m_maxTaskId)
				m_maxTaskId = t->id();
		}
	}

	m_deletedTasks.push_back(t);
	emit taskDeleted(t);
	load7day();
}

void TaskManager::addSubTask(quint16 taskid, QString description)
{
	if(description.isEmpty())
		return;

	Task *t = m_tasks[taskid];
	if(!t)
		return;

	SubTask *s = new SubTask();
	s->setId(++m_maxSubTaskId);
	s->setDescription(description);
	s->setParentId(taskid);
	s->setCreatedOn(QDate::currentDate());
	s->setUpdatedOn(QDate());
	s->setStatus(SubTask::PENDING);

	if(!m_db->addSubTask(s))
		return;

	t->addSubTask(s);
	m_subTasks.insert(s->id(),s);
	emit subTaskListUpdated();
	load7day();
}

void TaskManager::stepSubTask(quint16 id)
{
	SubTask *s = m_subTasks[id];
	if(!s)
		return;

	Task *t = m_tasks[s->parentId()];
	if(!t)
		return;

	if(!m_db->stepSubTask(s))
		return;

	s->setStatus(SubTask::COMPLETED);
	s->setUpdatedOn(QDate::currentDate());
	t->stepSubTask(s);
	emit subTaskListUpdated();
	load7day();
}

void TaskManager::deleteSubTask(quint16 id)
{
	SubTask *s = m_subTasks[id];
	if(!s)
		return;

	Task *t = m_tasks[s->parentId()];
	if(!t)
		return;

	if(!m_db->deleteSubTask(s))
		return;

	t->removeSubTask(s);
	m_subTasks.remove(s->id());

	if(s->id() == m_maxSubTaskId)
	{
		m_maxSubTaskId = 0;
		foreach (SubTask *s, m_subTasks.values()) {
			if(s->id() > m_maxSubTaskId)
				m_maxSubTaskId = t->id();
		}
	}

	m_deletedSubTasks.push_back(s);
	emit subTaskListUpdated();
	load7day();
}

void TaskManager::load7day()
{
	QDate today = QDate::currentDate();
	QList<Task*> allTasks = m_tasks.values();
	m_maxYValue = 10;
	for(int i = 0;i<7;i++)
	{
		m_pending7Day[i] = 0;
		m_completed7Day[i] = 0;
	}
	foreach (Task *t, allTasks) {
		QList<SubTask*> subTasks = t->subTasks();
		if(subTasks.count() > 0) {
			foreach (SubTask* s, subTasks) {
				int i = s->createdOn().daysTo(today);
				int j = s->updatedOn().daysTo(today);
				if(i < 7)
				{
					m_pending7Day[i] += 1;
					if(m_pending7Day[i] > m_maxYValue)
						m_maxYValue = m_pending7Day[i];
				}
				if(j < 7)
				{
					if(s->status() == SubTask::COMPLETED) {
						m_completed7Day[j] += 1;
						if(m_completed7Day[j] > m_maxYValue)
							m_maxYValue = m_completed7Day[j];
					}
				}
			}
		}
		else {
			int i = t->createdOn().daysTo(today);
			int j = t->updatedOn().daysTo(today);
			if(i < 7)
			{
				m_pending7Day[i] += 1;
				if(m_pending7Day[i] > m_maxYValue)
					m_maxYValue = m_pending7Day[i];
			}
			if(j < 7)
			{
				if(t->status() == Task::COMPLETED) {
					m_completed7Day[j] += 1;
					if(m_completed7Day[j] > m_maxYValue)
						m_maxYValue = m_completed7Day[j];
				}
			}
		}
	}

	emit updateGraph();
}

QObject * TaskManager::taskmanager_singleton(QQmlEngine* engine, QJSEngine* scriptEngine)
{
	Q_UNUSED(engine)
	Q_UNUSED(scriptEngine)

	TaskManager *manager = new TaskManager();
	return manager;
}

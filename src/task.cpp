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

#include "task.h"
#include "subtask.h"
#include "subtasklist.h"

#include <QObject>
#include <QDate>
#include <QDebug>

Task::Task() : m_status(INVALID) , m_createdOn(QDate::currentDate()) , m_updatedOn(QDate()) , m_list(new SubTaskList())
{
}

Task::~Task()
{
	m_list->deleteLater();
}

quint16 Task::id() const
{
	return m_id;
}

QString Task::title() const
{
	return m_title;
}

QString Task::description() const
{
	return m_description;
}

QString Task::tag() const
{
	return m_tag;
}

QDate Task::createdOn() const
{
	return m_createdOn;
}

QDate Task::updatedOn() const
{
	return m_updatedOn;
}

Task::Status Task::status() const
{
	return m_status;
}

quint8 Task::progress() const
{
	QList<SubTask*> subtasks = subTasks();
	quint16 nOT = subtasks.count();
	if(nOT == 0) {
		if(status() == Task::COMPLETED)
			return 100;
		else
			return 0;
	}
	else {
		quint16 compTasks = 0;
		foreach (SubTask *s , subtasks) {
			if(s->status() == SubTask::COMPLETED)
				compTasks++;
		}
		quint8 prog = (compTasks * 100 ) / nOT;
		return prog;
	}
}

void Task::setId(quint16 id)
{
	m_id = id;
}

void Task::setTitle(QString title)
{
	m_title = title;
}

void Task::setDescription(QString desc)
{
	m_description = desc;
}

void Task::setTag(QString tag)
{
	m_tag = tag;
}

void Task::setCreatedOn(QDate date)
{
	m_createdOn = date;
}

void Task::setUpdatedOn(QDate date)
{
	m_updatedOn = date;
}

void Task::setStatus(Task::Status status)
{
	m_status = status;
}

QList<SubTask*> Task::subTasks() const
{
	return m_list->subTasks();
}

SubTaskList* Task::list()
{
	return m_list;
}

void Task::addSubTask(SubTask *st)
{
	if(st->parentId() != id())
		return;

	m_list->add(st);
}

void Task::stepSubTask(SubTask *st)
{
	if(st->parentId() != id())
		return;

	m_list->update(st);
}

void Task::removeSubTask(SubTask *st)
{
	if(st->parentId() != id())
		return;

	m_list->remove(st);
}

void Task::print()
{
	qDebug() << "___ Task No " << id() << " ___" ;
	qDebug() << " Title : " << title();
	qDebug() << " Description : " << description();
	qDebug() << " progress : " << progress();
	qDebug() << " Tag : " << tag();
	qDebug() << " Created On : " << createdOn();
	qDebug() << " Updated On : " << updatedOn();
	qDebug() << " Status : " << status();
	if(m_list->rowCount() == 0)
		qDebug() << " No SubTasks Listed " ;
	else {
		qDebug() << " SubTasks " ;
		foreach(SubTask *st, subTasks())
		{
			qDebug() << st->description();
		}
	}
}

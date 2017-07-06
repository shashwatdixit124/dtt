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

#include <QObject>
#include <QDate>

Task::Task() : m_status(INVALID) , m_createdOn(QDate::currentDate()) , m_updatedOn(QDate())
{
}

Task::~Task()
{
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

quint16 Task::score() const
{
	return m_score;
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

void Task::setScore(quint16 score)
{
	m_score = score;
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

void Task::addSubTask(SubTask st)
{
	m_subtasks.push_back(st);
}

void Task::removeSubTask(SubTask st)
{
	if(st.parentId() != id())
		return;

	QList<SubTask> temp = subtasks();
	for(int i=0; i<temp.count() ; i++) {
		if(st.id() == temp.value(i) && temp.value(i).status() != SubTask::INVALID) {
			m_subtasks.removeAt(i);
			break;
		}
	}
}

void Task::print()
{
	qDebug() << "___ Task No " << id() << " ___" ;
	qDebug() << " Title : " << title();
	qDebug() << " Description : " << description();
	qDebug() << " Score : " << score();
	qDebug() << " Tag : " << tag();
	qDebug() << " Created On : " << createdOn();
	qDebug() << " Updated On : " << updatedOn();
	qDebug() << " Status : " << status();
	if(m_subtasks.count() == 0)
		qDebug() << " No SubTasks Listed " ;
	else {
		qDebug() << " SubTasks " ;
		foreach (SubTask st, m_subtasks) {
			qDebug() << st.description() ;
		}
	}
}

QList<SubTask> Task::subtasks() const
{
	return m_subtasks;
}

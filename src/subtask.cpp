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

#include "subtask.h"

#include <QObject>
#include <QDate>

SubTask::SubTask() : m_status(INVALID) , m_id(-1) , m_parentId(-1)
{}

SubTask::~SubTask()
{}

quint16 SubTask::id() const
{
	return m_id;
}

QString SubTask::description() const
{
	return m_description;
}

QDate SubTask::createdOn() const
{
	return m_createdOn;
}

QDate SubTask::updatedOn() const
{
	return m_updatedOn;
}

quint16 SubTask::parentId() const
{
	return m_parentId;
}

SubTask::Status SubTask::status() const
{
	return m_status;
}

void SubTask::setId(quint16 id)
{
	m_id = id;
}

void SubTask::setDescription(QString desc)
{
	m_description = desc;
}

void SubTask::setCreatedOn(QDate date)
{
	m_createdOn = date;
}

void SubTask::setUpdatedOn(QDate date)
{
	m_updatedOn = date;
}

void SubTask::setParentId(quint16 parentid)
{
	m_parentId = parentid;
}

void SubTask::setStatus(Status s)
{
	m_status = s;
}

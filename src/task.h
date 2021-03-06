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

#ifndef TASK_H
#define TASK_H

#include "subtask.h"

#include <QObject>
#include <QDate>
#include <QDebug>
#include <QList>

class SubTaskList;

class Task
{
public:
	explicit Task();
	~Task();

	enum Status {
		PENDING,
		COMPLETED,
		INVALID
	};

	quint16 id() const;
	QString title() const;
	QString description() const;
	QString tag() const;
	QDate createdOn() const;
	QDate updatedOn() const;
	Status status() const;
	bool bookmarked() const;
	quint8 progress() const;

	void setId(quint16);
	void setTitle(QString);
	void setDescription(QString);
	void setTag(QString);
	void setCreatedOn(QDate);
	void setUpdatedOn(QDate);
	void setStatus(Status);
	void setBookmarked(bool);

	QList<SubTask*> subTasks() const;
	SubTaskList* list();

	void addSubTask(SubTask*);
	void stepSubTask(SubTask *);
	void removeSubTask(SubTask*);

	void print();

protected:
	quint16 m_id;
	QString m_title;
	QString m_description;
	QString m_tag;
	QDate m_createdOn;
	QDate m_updatedOn;
	Status m_status;
	bool m_bookmarked;
	SubTaskList* m_list;

};

Q_DECLARE_METATYPE(Task)

#endif

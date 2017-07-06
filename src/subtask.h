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

#ifndef SUBTASK_H
#define SUBTASK_H

#include <QObject>
#include <QDate>

class SubTask
{
public:
	explicit SubTask();
	~SubTask();

	enum Status
	{
		INVALID = 0,
		PENDING,
		COMPLETED
	};

	quint16 id() const;
	QString description() const;
	QDate createdOn() const;
	QDate completedOn() const;
	quint16 parentId() const;
	Status status() const;

	void setId(quint16 id);
	void setDescription(QString desc);
	void setCreatedOn(QDate date);
	void setCompletedOn(QDate date);
	void setParentId(quint16 parentid);
	void setStatus(Status);

private:
	quint16 m_id;
	QString m_description;
	QDate m_createdOn;
	QDate m_completedOn;
	quint16 m_parentId;
	Status m_status;

};

Q_DECLARE_METATYPE(SubTask)

#endif

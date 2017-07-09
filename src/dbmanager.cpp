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

#include "dbmanager.h"
#include "task.h"
#include "subtask.h"

#include <QObject>
#include <QList>

#include <QDir>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>

#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

DBManager::DBManager(QObject* parent) : QObject(parent) , isDbOpen(false)
{
	QString dirPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
	m_dbPath = dirPath + QDir::separator() + ".dtt" + QDir::separator();
	m_dbName = "dtt.sqlite";
	QFileInfo dbInfo(m_dbPath+m_dbName);
	if(!dbInfo.exists()) {
		if(!createDatabase())
			return;
	}
	if(openDatabase()){
		isDbOpen = true;
	}
}

DBManager::~DBManager()
{
	if(isDbOpen)
		closeDatabase();
}

QList<Task *> DBManager::tasks()
{
	QList<Task*> tasks;
	if(!isDbOpen)
		return tasks;
	QSqlQuery query(*m_db);
	QString q = "SELECT rowid, * FROM Tasks";
	if(!query.exec(q)) {
		qDebug() << this << "cannot load tasks" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return tasks;
	}
	quint16 row = 0;
	while(query.next())
	{
		Task *t = new Task();
		row = query.value(0).toInt();
		t->setId(row);
		t->setTitle(query.value(1).toString());
		t->setDescription(query.value(2).toString());
		t->setTag(query.value(3).toString());
		t->setCreatedOn(query.value(4).toDate());
		t->setUpdatedOn(query.value(5).toDate());
		t->setStatus(Task::Status(query.value(6).toInt()));
		t->setBookmarked(query.value(7).toBool());
		tasks.push_back(t);
	}
	return tasks;
}

QList<SubTask *> DBManager::subTasks()
{
	QList<SubTask *> subTasks;
	if(!isDbOpen)
		return subTasks;
	QSqlQuery query(*m_db);
	QString q = "SELECT rowid, * FROM SubTasks";
	if(!query.exec(q)) {
		qDebug() << this << "cannot load subtasks" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return subTasks;
	}
	quint16 row = 0;
	while(query.next())
	{
		SubTask *s = new SubTask();
		row = query.value(0).toInt();
		s->setId(row);
		s->setDescription(query.value(1).toString());
		s->setCreatedOn(query.value(2).toDate());
		s->setUpdatedOn(query.value(3).toDate());
		s->setParentId(query.value(4).toInt());
		s->setStatus(SubTask::Status(query.value(5).toInt()));
		subTasks.push_back(s);
	}
	return subTasks;
}

bool DBManager::addTask(Task * t)
{
	if(!isDbOpen || t->status() == Task::INVALID)
		return false;

	QSqlQuery query(*m_db);
	QString q = "INSERT INTO Tasks Values (:title , :description , :tag , :createdon , :updatedon , :status , :bookmarked)" ;
	query.prepare(q);
	query.bindValue(":title",t->title());
	query.bindValue(":description",t->description());
	query.bindValue(":tag",t->tag());
	query.bindValue(":createdon",t->createdOn().toString("yyyy-MM-dd"));
	query.bindValue(":updatedon",t->updatedOn().toString("yyyy-MM-dd"));
	query.bindValue(":status",t->status());
	query.bindValue(":bookmarked",t->bookmarked());
	if(!query.exec()) {
		qDebug() << this << "cannot create task" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return false;
	}
	return true;
}

bool DBManager::toggleComplete(Task *t)
{
	if(!isDbOpen || t->status() == Task::INVALID)
		return false;

	QSqlQuery query(*m_db);

	Task::Status newStatus = t->status() == Task::PENDING ? Task::COMPLETED : Task::PENDING;

	QString q = "UPDATE Tasks SET updatedon = :updatedon , status = :status WHERE rowid = :id" ;
	query.prepare(q);
	query.bindValue(":id",t->id());
	query.bindValue(":updatedon",QDate::currentDate().toString("yyyy-MM-dd"));
	query.bindValue(":status",newStatus);
	if(!query.exec())
	{
		qDebug() << this << "cannot update task" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return false;
	}
	return true;
}

bool DBManager::toggleBookmark(Task *t)
{
	if(!isDbOpen)
		return false;

	QSqlQuery query(*m_db);

	QString q = "UPDATE Tasks SET bookmarked = :bookmarked WHERE rowid = :id" ;
	query.prepare(q);
	query.bindValue(":id",t->id());
	query.bindValue(":bookmarked",!t->bookmarked());
	if(!query.exec())
	{
		qDebug() << this << "cannot update task" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return false;
	}
	return true;
}

bool DBManager::deleteTask(Task *t)
{
	if(!isDbOpen || t->status() == Task::INVALID)
		return false;

	QSqlQuery query(*m_db);

	QString q = "DELETE FROM Tasks WHERE rowid = :id" ;
	query.prepare(q);
	query.bindValue(":id",t->id());
	if(!query.exec())
	{
		qDebug() << this << "cannot delete task" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return false;
	}
	return true;
}

bool DBManager::addSubTask(SubTask *st)
{
	if(!isDbOpen || st->status() == SubTask::INVALID)
		return false;

	QSqlQuery query(*m_db);
	QString q = "INSERT INTO SubTasks Values (:description , :createdon , :updatedon , :parentid , :status)" ;
	query.prepare(q);
	query.bindValue(":description",st->description());
	query.bindValue(":createdon",st->createdOn().toString("yyyy-MM-dd"));
	query.bindValue(":updatedon",st->updatedOn().toString("yyyy-MM-dd"));
	query.bindValue(":parentid",st->parentId());
	query.bindValue(":status",st->status());
	if(!query.exec()) {
		qDebug() << this << "cannot create subtask" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return false;
	}
	return true;
}

bool DBManager::stepSubTask(SubTask *s)
{
	if(!isDbOpen || s->status() != SubTask::PENDING)
		return false;

	QSqlQuery query(*m_db);

	QString q = "UPDATE SubTasks SET updatedon = :updatedon , status = :status WHERE rowid = :id" ;
	query.prepare(q);
	query.bindValue(":id",s->id());
	query.bindValue(":updatedon",QDate::currentDate().toString("yyyy-MM-dd"));
	query.bindValue(":status",SubTask::COMPLETED);
	if(!query.exec())
	{
		qDebug() << this << "cannot update sub task" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return false;
	}
	return true;
}

bool DBManager::deleteSubTask(SubTask *s)
{
	if(!isDbOpen || s->status() == SubTask::INVALID)
		return false;

	QSqlQuery query(*m_db);

	QString q = "DELETE FROM SubTasks WHERE rowid = :id" ;
	query.prepare(q);
	query.bindValue(":id",s->id());
	if(!query.exec())
	{
		qDebug() << this << "cannot delete subtask" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return false;
	}
	return true;
}

bool DBManager::openDatabase()
{
	m_db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
	m_db->setDatabaseName(m_dbPath + m_dbName);
	if(!m_db->open()) {
		qDebug() << this << "cannot open Database Tasks" ;
		return false;
	}
	return true;
}

bool DBManager::closeDatabase()
{
	m_db->close();
	return true;
}

bool DBManager::createDatabase()
{
	if(!QDir(m_dbPath).exists())
		QDir().mkdir(m_dbPath);
	QFile dbFile(m_dbPath+m_dbName);
	dbFile.open(QFile::ReadWrite);
	dbFile.close();

	QFileInfo dbInfo(m_dbPath);
	if(!dbInfo.exists()) {
		qDebug() << this << "Cannot Create file " << m_dbName << " in " << m_dbPath ;
		return false;
	}

	QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE","create-database-temporary");
	db.setDatabaseName(m_dbPath+m_dbName);
	if(!db.open()) {
		qDebug() << this << "cannot open Database Tasks" ;
		return false;
	}

	QSqlQuery query(db);
	QString q = "CREATE TABLE Tasks (title TEXT NOT NULL, description TEXT, tag VARCHAR(15), createdon DATE NOT NULL, updatedon DATE , status INTEGER , bookmarked BOOLEAN)";

	if(!query.exec(q))
	{
		qDebug() << this << "cannot create table Tasks" ;
		qDebug() << "ERROR : " << db.lastError().text();
		return false;
	}

	q = "CREATE TABLE SubTasks (desc TEXT , createdon DATE , updatedon DATE , taskid INTEGER , status INTEGER , FOREIGN KEY(taskid) REFERENCES Tasks(rowid))";

	if(!query.exec(q))
	{
		qDebug() << this << "cannot create table SubTasks" ;
		qDebug() << "ERROR : " << db.lastError().text();
		return false;
	}

	db.close();
	return true;
}

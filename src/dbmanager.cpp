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

#include <QObject>
#include <QDir>
#include <QFile>
#include <QList>
#include <QDebug>
#include <QFileInfo>
#include <QStandardPaths>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

DBManager::DBManager(QObject* parent) : QObject(parent) , isDbOpen(false) , m_rowid(0)
{
	QString dirPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
	m_dbPath = dirPath + QDir::separator() + ".dtt" + QDir::separator();
	QFileInfo dbInfo(m_dbPath+"tasks.sqlite");
	if(!dbInfo.exists()) {
		if(!createDatabase())
			return;
	}
	if(openDatabase()){
		isDbOpen = true;
		loadDatabase();
	}
}

DBManager::~DBManager()
{
	if(isDbOpen)
		closeDatabase();
}

QList<Task> DBManager::tasks()
{
	return m_tasks.values();
}

void DBManager::addTask(Task t)
{
	if(!isDbOpen)
		return;
	t.setCreatedOn(QDate::currentDate());
	t.setUpdatedOn(QDate());
	QSqlQuery query(*m_db);
	QString q = "INSERT INTO Tasks Values (:title , :description , :score , :tag , :createdon , :updatedon , :status)" ;
	query.prepare(q);
	query.bindValue(":title",t.title());
	query.bindValue(":description",t.description());
	query.bindValue(":score",t.score());
	query.bindValue(":tag",t.tag());
	query.bindValue(":createdon",t.createdOn().toString("yyyy-MM-dd"));
	query.bindValue(":updatedon",t.updatedOn().toString("yyyy-MM-dd"));
	query.bindValue(":status",t.status());
	if(!query.exec()) {
		qDebug() << this << "cannot create task" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return;
	}
	t.setId(++m_rowid);
	m_tasks.insert(m_rowid,t);
	emit createdTask(t);
}

void DBManager::stepTask(quint16 id)
{
	Task t = m_tasks.value(id);
	if(t.status() == Task::INVALID)
		return;
	if(t.status() == Task::COMPLETED)
		return;
	if(t.status() == Task::PENDING) {
		t.setStatus(Task::WIP);
	}
	else if(t.status() == Task::WIP) {
		t.setStatus(Task::COMPLETED);
	}
	QSqlQuery query(*m_db);

	QString q = "UPDATE Tasks SET updatedon = :updatedon , status = :status WHERE rowid = :id" ;
	query.prepare(q);
	query.bindValue(":id",t.id());
	query.bindValue(":updatedon",QDate::currentDate().toString("yyyy-MM-dd"));
	query.bindValue(":status",t.status());
	if(!query.exec())
	{
		qDebug() << this << "cannot update task" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return;
	}
	t.setUpdatedOn(QDate::currentDate());
	m_tasks[t.id()] = t;
	emit stepped(t);
}

void DBManager::deleteTask(quint16 id)
{
	Task t = m_tasks.value(id);
	if(t.status() == Task::INVALID)
		return;
	QSqlQuery query(*m_db);
	
	QString q = "DELETE FROM Tasks WHERE rowid = :id" ;
	query.prepare(q);
	query.bindValue(":id",t.id());
	if(!query.exec())
	{
		qDebug() << this << "cannot delete task" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return;
	}
	m_tasks.remove(t.id());
	emit deletedTask(t);
}

bool DBManager::openDatabase()
{
	m_db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
	m_db->setDatabaseName(m_dbPath + "tasks.sqlite");
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
	QFile dbFile(m_dbPath+"tasks.sqlite");
	dbFile.open(QFile::ReadWrite);
	dbFile.close();

	QFileInfo dbInfo(m_dbPath);
	if(!dbInfo.exists()) {
		qDebug() << this << "Cannot Create file tasks.sqlite in " << m_dbPath ;
		return false;
	}

	QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE","create-database-temporary");
	db.setDatabaseName(m_dbPath+"tasks.sqlite");
	if(!db.open()) {
		qDebug() << this << "cannot open Database Tasks" ;
		return false;
	}
	
	QSqlQuery query(db);
	QString q = "CREATE TABLE Tasks (title VARCHAR(50) NOT NULL, description TEXT, score INTEGER NOT NULL, tag VARCHAR(15), createdon DATE NOT NULL, updatedon DATE , status INTEGER)";
	
	if(!query.exec(q))
	{
		qDebug() << this << "cannot create table Tasks" ;
		qDebug() << "ERROR : " << db.lastError().text();
		return false;
	}
	db.close();
	return true;
}

bool DBManager::loadDatabase()
{
	QSqlQuery query(*m_db);
	QString q = "SELECT rowid, * FROM Tasks";
	if(!query.exec(q)) {
		qDebug() << this << "cannot load tasks" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return false;
	}
	quint16 row = 0;
	while(query.next())
	{
		Task t;
		row = query.value(0).toInt();
		t.setId(row);
		t.setTitle(query.value(1).toString());
		t.setDescription(query.value(2).toString());
		t.setScore(query.value(3).toInt());
		t.setTag(query.value(4).toString());
		t.setCreatedOn(query.value(5).toDate());
		t.setUpdatedOn(query.value(6).toDate());
		t.setStatus(Task::Status(query.value(7).toInt()));
		m_tasks.insert(t.id(),t);
	}
	m_rowid = row;
	return true;
}

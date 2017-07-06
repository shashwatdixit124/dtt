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
#include <QDir>
#include <QFile>
#include <QList>
#include <QDebug>
#include <QFileInfo>
#include <QStandardPaths>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>

DBManager::DBManager(QObject* parent) : QObject(parent) , isDbOpen(false) , m_maxSubTaskId(0) , m_maxTaskId(0)
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

Task& DBManager::task(quint16 id)
{
	foreach (Task t, m_tasks.values()) {
		if(t.id() == id)
			return t;
	}
}

void DBManager::addTask(Task t)
{
	if(!isDbOpen || t.status() == Task::INVALID)
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
	t.setId(++m_maxTaskId);
	m_tasks.insert(m_maxTaskId,t);
	emit createdTask(t);
}

void DBManager::addSubTask(SubTask st)
{
	if(!isDbOpen || st.status() == SubTask::INVALID)
		return;
	st.setCreatedOn(QDate::currentDate());
	st.setUpdatedOn(QDate());
	QSqlQuery query(*m_db);
	QString q = "INSERT INTO SubTasks Values (:description , :createdon , :updatedon , :parentid , :status)" ;
	query.prepare(q);
	query.bindValue(":description",st.description());
	query.bindValue(":createdon",st.createdOn().toString("yyyy-MM-dd"));
	query.bindValue(":updatedon",st.updatedOn().toString("yyyy-MM-dd"));
	query.bindValue(":parentid",st.parentId());
	query.bindValue(":status",st.status());
	if(!query.exec()) {
		qDebug() << this << "cannot create subtask" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return;
	}
	st.setId(++m_maxSubTaskId);
	m_subTasks.insert(m_maxSubTaskId,st);
	emit createdSubTask(st);
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

void DBManager::deleteSubTask(quint16 id)
{
	SubTask t = m_subTasks.value(id);
	if(t.status() == SubTask::INVALID)
		return;
	QSqlQuery query(*m_db);

	QString q = "DELETE FROM SubTasks WHERE rowid = :id" ;
	query.prepare(q);
	query.bindValue(":id",t.id());
	if(!query.exec())
	{
		qDebug() << this << "cannot delete subtask" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return;
	}
	m_subTasks.remove(t.id());
	emit deletedSubTask(t);
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
	QString q = "CREATE TABLE Tasks (title VARCHAR(50) NOT NULL, description TEXT, score INTEGER NOT NULL, tag VARCHAR(15), createdon DATE NOT NULL, updatedon DATE , status INTEGER)";

	if(!query.exec(q))
	{
		qDebug() << this << "cannot create table Tasks" ;
		qDebug() << "ERROR : " << db.lastError().text();
		return false;
	}

	q = "CREATE TABLE SubTasks (desc TEXT , createdon DATE , completedon DATE , taskid INTEGER , status INTEGER , FOREIGN KEY(taskid) REFERENCES Tasks(rowid))";

	if(!query.exec(q))
	{
		qDebug() << this << "cannot create table SubTasks" ;
		qDebug() << "ERROR : " << db.lastError().text();
		return false;
	}

	db.close();
	return true;
}

void DBManager::loadDatabase()
{
	m_maxTaskId = loadTasks();
	m_maxSubTaskId = loadSubTasks();
	if(m_maxTaskId > 0 && m_maxSubTaskId > 0)
		matchTasksWithSubTasks();
}

quint16 DBManager::loadTasks()
{
	QSqlQuery query(*m_db);
	QString q = "SELECT rowid, * FROM Tasks";
	if(!query.exec(q)) {
		qDebug() << this << "cannot load tasks" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return 0;
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
	return row;
}

quint16 DBManager::loadSubTasks()
{
	QSqlQuery query(*m_db);
	QString q = "SELECT rowid, * FROM SubTasks";
	if(!query.exec(q)) {
		qDebug() << this << "cannot load subtasks" ;
		qDebug() << "ERROR : " << m_db->lastError().text();
		return 0;
	}
	quint16 row = 0;
	while(query.next())
	{
		SubTask st;
		row = query.value(0).toInt();
		st.setId(row);
		st.setDescription(query.value(1).toString());
		st.setCreatedOn(query.value(2).toDate());
		st.setUpdatedOn(query.value(3).toDate());
		st.setParentId(query.value(4).toInt());
		st.setStatus(SubTask::Status(query.value(5).toInt()));
		m_subTasks.insert(st.id(),st);
	}
	return row;
}

void DBManager::matchTasksWithSubTasks()
{
	foreach (SubTask st, m_subTasks) {
		if(st.status() != SubTask::INVALID)
			m_tasks[st.parentId()].addSubTask(st);
	}
}

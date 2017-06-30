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

#include <QApplication>
#include <QQmlApplicationEngine>

int main(int argc, char* argv[])
{
	QApplication a(argc,argv);
	a.setApplicationName("Daily Task Tracker");
	a.setOrganizationName("dtt");
	a.setOrganizationDomain("https://github.com/shashwatdixit124/dtt");
	a.setApplicationVersion("1.0");

	qmlRegisterSingletonType<TaskManager>("api.dtt",1,0,"Dtt",TaskManager::taskmanager_singleton);

	QQmlApplicationEngine engine;
	engine.load(QUrl("qrc:/resources/Main.qml"));

	a.exec();
	return 0;
}

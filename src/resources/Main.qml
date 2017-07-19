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

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Window 2.0
import api.dtt 1.0

ApplicationWindow { id: root
	visible: true
	minimumWidth: 720
	minimumHeight: 480
	width: 980
	height: 640
	x:(Screen.width-980)/2
	y:(Screen.height-640)/2
	flags: Qt.FramelessWindowHint

	FontLoader { id: fontawesome; source: "qrc:/resources/fontawesome-webfont.ttf" }

	property string textColor: "#f6f6f6"

	Rectangle { id: titleBar
		anchors.top: parent.top
		width: parent.width
		height: 40
		color: "#2980b9"

		property int activeTab: 0

		AppControls { id: appControls
			anchors.fill: parent
			onClose: Qt.quit()
			onMinimized: root.showMinimized()
			onDrag: {
				root.x += dragX
				root.y += dragY
			}
		}

		Row {
			anchors.top: parent.top
			anchors.left: parent.left
			height: parent.height
			width: parent.width

			IPCButton {
				text: qsTr("DASHBOARD")
				radius: 0
				shadow: false
				active: titleBar.activeTab == 0
				activeColor: "#fff"
				width: 200
				onClicked: {
					titleBar.activeTab = 0
				}
			}

			IPCButton {
				text: qsTr("PROGRESS")
				radius: 0
				shadow: false
				active: titleBar.activeTab == 1
				activeColor: "#fff"
				width: 200
				onClicked: {
					titleBar.activeTab = 1
				}
			}
		}
	}

	Item { id: taskViewGrid
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: titleBar.bottom
		anchors.bottom: statusBar.top
		property int cardWidth : 300
		visible: titleBar.activeTab == 0

		DashboardActionPanel {
			anchors.top: parent.top
			height: 80

			onAddTaskClicked: {
				createTaskPopup.show()
			}
			onZoomInClicked: {
				if(taskViewGrid.cardWidth < 700)
					taskViewGrid.cardWidth += 100
			}
			onZoomOutClicked: {
				if(taskViewGrid.cardWidth > 300)
					taskViewGrid.cardWidth -= 100
			}
			onShowBookmarks: {
				 taskList.tasks = Dtt.bookmarkedTasks
			}
			onShowTasks: {
				taskList.tasks = Dtt.pendingTasks

			}
		}

		TaskList { id: taskList
			width: parent.width
			height: parent.height - 80
			anchors.bottom: parent.bottom
			cardWidth: parent.cardWidth
			tasks: Dtt.pendingTasks
			onTaskClicked: showTaskPopup.show()
			columns: (root.width)/(cardWidth+20)
		}
	}

	ProgressGraph { id: graph
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: titleBar.bottom
		anchors.bottom: statusBar.top
		visible: titleBar.activeTab == 1
	}	

	CreateTaskPopup { id: createTaskPopup }

	ShowTaskPopup { id: showTaskPopup }

	StatusBar { id: statusBar
		width:parent.width
		height: 24
		anchors.bottom: parent.bottom
		onSizeChanged: {
			root.width += sizeX
			root.height += sizeY
		}
	}
}

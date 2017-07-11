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
import QtGraphicalEffects 1.0
import api.dtt 1.0

Item {
	signal addTaskClicked
	signal zoomInClicked
	signal zoomOutClicked
	signal showTasks
	signal showBookmarks

	Row {
		height: parent.height - 40
		width: parent.width - 40
		anchors.centerIn: parent
		spacing: 30
		IPCButton {
			height: parent.height
			width: 150
			text: qsTr("\uf067  Add Task")
			radius: width / 2
			shadow: false
			onClicked: addTaskClicked()
		}
		IPCButton {
			height: parent.height
			width: 150
			text: qsTr("\uf00e  Zoom In")
			radius: width / 2
			shadow: false
			onClicked: {
				zoomInClicked()
			}
		}
		IPCButton {
			height: parent.height
			width: 150
			text: qsTr("\uf010  Zoom Out")
			radius: width / 2
			shadow: false
			onClicked: {
				zoomOutClicked()
			}
		}
		IPCButton {
			property bool show: false
			height: parent.height
			width: 150
			text: qsTr("\uf02e  Show Bookmarks")
			radius: width / 2
			shadow: false
			active: show
			onClicked: {
				show = !show
				if(show) {
					showBookmarks()
				}
				else {
					showTasks()
				}
			}
		}
	}
}

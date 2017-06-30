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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import api.dtt 1.0

Popup { id: item
	height: 290
	width: 500
	x: (parent.width - width)/2
	y: (parent.height - height)/2
	modal: true

	function show()
	{
		taskTitle.focus = true
		open()
	}

	property string pallete : "#2980b9"
	FontLoader { id: awesome; source: "qrc:/resources/fontawesome-webfont.ttf" }

	background: Item{
		implicitHeight: 400
		implicitWidth: 500
		Rectangle { id: popupBack
			anchors.fill: parent
		}
		DropShadow { 
			anchors.fill: popupBack
			source: popupBack
			horizontalOffset: 0
			verticalOffset: 0
			radius: 16
			samples: 32
			color: "#60000000"
			transparentBorder: true
		}
	}

	contentItem: Item {
		anchors.fill: parent

		Column { id: formCol
			width: parent.width - 50
			height: parent.height - 50
			anchors.centerIn: parent
			spacing: 10
			TextField { id: taskTitle
				height: 40
				width: parent.width
				font.pixelSize: 16
				placeholderText: qsTr(" Title")
				background: Rectangle {
					implicitHeight: 40
					implicitWidth: 400
					color: parent.activeFocus ? "transparent" : "#f6f6f6"
					border.color: item.pallete
					border.width: parent.activeFocus ? 2 : 0
				}
			}
			TextField { id: taskDescription
				height: 40
				width: parent.width
				font.pixelSize: 16
				placeholderText: qsTr(" Description")
				background: Rectangle {
					implicitHeight: 40
					implicitWidth: 400
					color: parent.activeFocus ? "transparent" : "#f6f6f6"
					border.color: item.pallete
					border.width: parent.activeFocus ? 2 : 0
				}
			}
			TextField { id: taskScore
				height: 40
				width: parent.width
				font.pixelSize: 16
				placeholderText: qsTr(" Score")
				background: Rectangle {
					implicitHeight: 40
					implicitWidth: 400
					color: parent.activeFocus ? "transparent" : "#f6f6f6"
					border.color: item.pallete
					border.width: parent.activeFocus ? 2 : 0
				}
			}
			TextField { id: taskTag
				height: 40
				width: parent.width
				font.pixelSize: 16
				placeholderText: qsTr(" Tag")
				background: Rectangle {
					implicitHeight: 40
					implicitWidth: 400
					color: parent.activeFocus ? "transparent" : "#f6f6f6"
					border.color: item.pallete
					border.width: parent.activeFocus ? 2 : 0
				}
			}
			IPCButton { id: createBtn
				shadow: false
				radius: 0
				height: 40
				icon: qsTr("\uf0c7")
				text: qsTr("Save")
				onClicked:{
					if(taskTitle.text != "")
					{
						Dtt.addTask(taskTitle.text,taskDescription.text,taskScore.text,taskTag.text)
						taskTitle.text = ""
						taskDescription.text = ""
						taskScore.text = ""
						taskTag.text = ""
						close()
					}
				}
			}
		}
	}
}

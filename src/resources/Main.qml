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
import QtQuick.Controls 2.0
import QtQuick.Window 2.0

ApplicationWindow { id: root
	visible: true
	minimumWidth: 720
	minimumHeight: 480
	x:(Screen.width-720)/2
	y:(Screen.height-480)/2

	FontLoader { id: linea_basic_elaboration; source: "qrc:/resources/linea-basic-elaboration-10.ttf" }

	property string textColor: "#555"

	Rectangle { id: actions
		color: "#f7f7f7"
		width: parent.width
		height: 40

		Item { id: appName
			anchors.left: parent.left
			height: parent.height
			width: 200

			Text {
				color: root.textColor
				font.pixelSize: 16
				font.weight: Font.Light
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 20
				text: qsTr("DASHBOARD")
			}

		}

		Row {
			anchors.right: parent.right
			height: parent.height

			Item {
				height: parent.height
				width: height

				Text {
					color: root.textColor
					font.pixelSize: 24
					font.family: linea_basic_elaboration.name
					anchors.centerIn: parent
					text: qsTr("\ue02d")

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						onClicked: createTaskPopup.open()
					}
				}
			}
		}
	}

	Popup { id: createTaskPopup
		y: (parent.height - height)/2
		x: (parent.width - width)/2
		height: 300
		width: 400
		modal: true
	}

}

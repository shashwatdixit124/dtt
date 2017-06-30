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
import QtGraphicalEffects 1.0
import api.dtt 1.0

ApplicationWindow { id: root
	visible: true
	minimumWidth: 920
	minimumHeight: 640
	x:(Screen.width-920)/2
	y:(Screen.height-640)/2
	flags: Qt.FramelessWindowHint

	FontLoader { id: linea_basic_elaboration; source: "qrc:/resources/linea-basic-elaboration-10.ttf" }

	property string textColor: "#f6f6f6"

	Rectangle { id: titleBar
		anchors.top: parent.top
		width: parent.width
		height: 40
		color: "#2980b9"

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
			width: height
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
						onClicked: createTaskPopup.show()
					}
				}
			}
		}
	}


	Flickable {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: titleBar.bottom
		anchors.bottom: statusBar.top
		contentWidth: 940
		clip: true

		ScrollBar.horizontal: ScrollBar {}

		Row { id: taskViewGrid
			anchors.fill: parent
			anchors.margins: 20
			spacing: 20

			Item { id: pendingTaskViewer
				width: 300
				height: parent.height
				clip: true
				ListView { id:pendingTasks
					anchors.fill: parent
					model: Dtt.pendingTasks
					spacing: 20
					delegate: taskCard
				}
			}
			Item { id: wipTaskViewer
				width: 300
				height: parent.height
				clip: true
				ListView { id:wipTasks
					anchors.fill: parent
					model: Dtt.wipTasks
					spacing: 20
					delegate: taskCard
				}
			}
			Item { id: completedTaskViewer
				width: 300
				height: parent.height
				clip: true
				ListView { id:completedTasks
					anchors.fill: parent
					model: Dtt.completedTasks
					spacing: 20
					delegate: taskCard
				}
			}
		}
	}
	
	Component { id: taskCard
		Rectangle {
			border.color: _T_status == 0 ? "#ccc" : _T_status == 1 ? "#2980b9" : "#27ae60"
			radius: 3
			width: parent.width
			height: titleBlk.height + descBlk.height + scoreandtagBlk.height + 40
			Item { id: titleBlk
				width: parent.width - 40
				height: title.text != "" ? title.implicitHeight + 10 : 0
				anchors.top: parent.top
				anchors.topMargin: 10
				Text { id: title
					text: _T_title
					width: parent.width - 20
					font.pixelSize: 16
					anchors.centerIn: parent
					wrapMode: Text.WordWrap
				}
			}
			Item { id: menu
				property bool open: false
				anchors.top: parent.top
				anchors.left: titleBlk.right
				height: 40
				width: 40
				Text {
					font.pixelSize: 16
					text: qsTr("\uf0c9")
					anchors.centerIn: parent
				}
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: menu.open = !menu.open
				}
			}
			Item { id: descBlk
				width: parent.width
				height: desc.text != "" ? desc.implicitHeight + 10 : 0
				anchors.top: titleBlk.bottom
				anchors.topMargin: 10
				Text { id: desc
					text: _T_description
					width: parent.width - 20
					font.pixelSize: 14
					font.weight: Font.Light
					anchors.centerIn: parent
					wrapMode: Text.WordWrap
				}
			}
			Item { id: scoreandtagBlk
				width: parent.width
				height: scoreBlk.height
				anchors.top: descBlk.bottom
				anchors.topMargin: 10
				Row {
					width: parent.width - 20
					height: scoreBlk.height
					anchors.centerIn: parent
					spacing: 10
					Rectangle { id: scoreBlk
						color: "#F9BF3B"
						width: score.implicitWidth + 20
						height: 20
						Text { id: score
							text: _T_score
							width: parent.width - 20
							font.pixelSize: 14
							font.weight: Font.Light
							wrapMode: Text.WordWrap
							anchors.centerIn: parent
						}
					}
					Rectangle { id: tagBlk
						color: "#e7e7e7"
						width: tag.text != "" ? tag.implicitWidth + 20 : 0
						height: 20
						Text { id: tag
							text: _T_tag != "" ? qsTr("\uf02b  ") + _T_tag : ""
							width: parent.width - 20
							font.pixelSize: 14
							anchors.centerIn: parent
							font.weight: Font.Light
							wrapMode: Text.WordWrap
						}
					}
				}
			}
			Item {
				visible: menu.open
				width: 100
				height: 80
				anchors.right: parent.right
				anchors.top: menu.bottom
				Rectangle { id: menuBox
					anchors.fill: parent
					IPCButton {
						text: qsTr("step")
						color: "transparent"
						textColor: "#555"
						width: parent.width
						radius: 0
						shadow: false
						anchors.top: parent.top
						onClicked:{
							Dtt.stepTask(_T_id)
						}
					}
					IPCButton {
						text: qsTr("delete")
						color: "transparent"
						textColor: "#555"
						width: parent.width
						radius: 0
						shadow: false
						anchors.bottom: parent.bottom
						onClicked:{
							Dtt.deleteTask(_T_id)
						}
					}
				}
				DropShadow { id: dropMenuBox
					anchors.fill: menuBox
					source: menuBox
					horizontalOffset: 0
					verticalOffset: 0
					radius: 8
					samples: 17
					color: "#30000000"
					transparentBorder: true
				}
			}
		}
	}
	
	StatusBar { id: statusBar
		width:parent.width
		height: 24
		anchors.bottom: parent.bottom
		onSizeChanged: {
			root.width += sizeX
			root.height += sizeY
		}
	}

	CreateTaskPopup { id: createTaskPopup }

}

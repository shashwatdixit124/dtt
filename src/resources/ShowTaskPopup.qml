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
	height: 400
	width: 640
	x: (parent.width - width)/2
	y: (parent.height - height)/2
	modal: true

	property int taskid: 0
	property string title: "Dtt"
	property int progress: 5

	function show()
	{
		open()
	}

	property string pallete : "#2980b9"
	FontLoader { id: awesome; source: "qrc:/resources/fontawesome-webfont.ttf" }

	background: Item{
		implicitHeight: 400
		implicitWidth: 500

		Rectangle { id: popupBack
			anchors.fill: parent
//			radius: 5
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
		clip:true

		Row {
			anchors.fill: parent
			clip: true

			Item { id: progressShow
				width: 300
				height: parent.height
				Column {
					anchors.fill: parent
					Item {
						height: parent.height - 280
						width: parent.width
						Text { id: taskTitle
							text: item.title
							anchors.centerIn: parent
							font.pixelSize: 20
							elide: Text.ElideRight
							width: implicitWidth > parent.width - 20 ? parent.width - 20 : implicitWidth
						}
					}
					Item { id: taskProgress
						height: 200
						width: 200
						anchors.horizontalCenter: parent.horizontalCenter

						TaskProgress {
							anchors.centerIn: parent
							progress: 70//item.progress
							height: parent.height - 20
							width: parent.width - 20
						}
					}
					Item { id:actionBlk
						height: 80
						width: parent.width
						property bool btnshow: true
						IPCButton {
							shadow: false
							radius: 0
							anchors.centerIn: parent
							text: qsTr("Add Sub Tasks")
							visible: parent.btnshow
							onClicked: actionBlk.btnshow = false
						}

						Row {
							visible: !actionBlk.btnshow
							width: parent.width - 20
							height: 40
							anchors.centerIn: parent
							TextField { id: subTaskInput
								height: 40
								width: parent.width - 80
								font.pixelSize: activeFocus ? 16 : 14
								placeholderText: qsTr(" Sub Task")
								background: Rectangle {
									implicitHeight: 40
									implicitWidth: 400
									color: parent.activeFocus ? "transparent" : "#f6f6f6"
									border.color: item.pallete
									border.width: parent.activeFocus ? 2 : 0
								}
							}
							IPCButton {
								height: 40
								width: 40
								icon: qsTr("\uf067")
								active: true
								radius: 0
								onClicked: {
									if(subTaskInput.text == "")
										return;
									Dtt.addSubTask(item.taskid,subTaskInput.text)
									actionBlk.btnshow = true
								}
							}
							IPCButton {
								height: 40
								width: 40
								icon: qsTr("\uf00d")
								active: true
								radius: 0
								onClicked: actionBlk.btnshow = true
							}
						}

					}
				}
				Rectangle { id: subTaskDetail
					color: item.pallete//"#f7f7f7"
					width: parent.width
					height: parent.height
					visible: false
					anchors.centerIn: parent
					clip: true

					property string desc
					property int status: 1
					property string createdon
					property string updatedon

					Column {
						anchors.fill: parent
						Item {
							width: parent.width
							height: 40
							Text {
								color: "#f6f6f6"
								font.pixelSize: 12
								text: subTaskDetail.status == 1 ? subTaskDetail.createdon : subTaskDetail.createdon + " - " + subTaskDetail.updatedon
								anchors.centerIn: parent
								width: parent.width - 20
							}
						}
						Item {
							width: parent.width
							height: 40
							Text {
								color: "#f6f6f6"
								font.pixelSize: 12
								text: subTaskDetail.status == 1 ? "Status : PENDING" : "Status : COMPLETED"
								anchors.centerIn: parent
								width: parent.width - 20
							}
						}
						Item {
							width: parent.width
							height: parent.height - 80
							Text {
								color: "#f6f6f6"
								font.pixelSize: 16
								text: subTaskDetail.desc
								width: parent.width - 20
								height: parent.height - 20
								anchors.centerIn: parent
								wrapMode: Text.WordWrap
							}
						}
					}

					IPCButton {
						icon: qsTr("\uf00d")
						shadow: false
						radius: 0
						onClicked: subTaskDetail.visible = false
						anchors.right: parent.right
						anchors.top: parent.top
					}
				}
			}

			Rectangle { id: subTaskShow
				width: 340
				height: parent.height
				color: "#fcfcfc"

				ListView { id: listView
					anchors.fill: parent
					anchors.margins: 20
					delegate: subTaskDelegate
					spacing: 10

					Connections {
						target: Dtt
						onCurrentTaskChanged: listView.model = Dtt.subTasks
					}
					Component { id: subTaskDelegate
						Row {
							height: 40
							width: parent.width
							clip: true
							Rectangle {
								height: parent.height
								width: 5
								color: _ST_status == 1 ? "#2980b9" : _ST_status == 0 ? "#333" : "#27ae60"
							}
							Item {
								height: parent.height
								width: _ST_status == 2 ? parent.width - 45 : parent.width - 85
								Text {
									font.pixelSize: 14
									width: parent.width - 20
									elide: Text.ElideMiddle
									anchors.centerIn: parent
									text: _ST_description
								}
								MouseArea {
									anchors.fill: parent
									cursorShape: Qt.PointingHandCursor
									onClicked: {
										subTaskDetail.desc = _ST_description
										subTaskDetail.status = _ST_status
										subTaskDetail.createdon = _ST_createdon
										subTaskDetail.updatedon = _ST_updatedon
										subTaskDetail.visible = true
									}
								}
							}
							IPCButton {
								visible: _ST_status != 2
								height: parent.height
								width: 40
								radius: 0
								shadow: false
								icon: qsTr("\uf00c")
								color: "#fff"
								textColor: "#555"
								onClicked: Dtt.stepSubTask(_ST_id)
							}
							IPCButton {
								height: parent.height
								width: 40
								radius: 0
								shadow: false
								icon: qsTr("\uf1f8")
								color: "#fff"
								textColor: "#555"
								onClicked: Dtt.deleteSubTask(_ST_id)
							}
						}
					}
				}
			}

		}
	}
}

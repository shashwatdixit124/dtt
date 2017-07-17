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
	property int progress: 0
	property int status: 2

	function init()
	{
		taskid = Dtt.currentTask
		title = Dtt.taskTitle(taskid)
		progress = Dtt.taskProgress(taskid)
		status = Dtt.taskStatus(taskid)
	}

	function show()
	{
		init()
		subTaskDetail.init()
		actionBlk.btnshow = true
		open()
	}

	property string pallete : "#2980b9"
	FontLoader { id: awesome; source: "qrc:/resources/fontawesome-webfont.ttf" }

	background: Item{
		implicitHeight: 400
		implicitWidth: 500

		MouseArea {
			anchors.fill: parent
		}

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
						height: parent.height / 2  - 50
						width: parent.width
						TaskDescriptionView { id: tdview
							boxHeight: parent.height
							boxWidth: parent.width
							boxColor: "#fff"
							taskFontSize: 18
							descriptionFontSize: 14
							title: Dtt.taskTitle(Dtt.currentTask)
							description: Dtt.taskDescription(Dtt.currentTask)
							anchors.centerIn: parent
						}
					}
					Item {
						height: parent.height / 2 + 50
						width: height
						anchors.horizontalCenter: parent.horizontalCenter

						Connections {
							target: Dtt
							onSubTaskListUpdated: item.progress = Dtt.taskProgress(Dtt.currentTask)
						}

						TaskProgress { id: taskProgress
							anchors.centerIn: parent
							progress: item.progress
							height: 200
							width: 200
						}
					}
				}
				Rectangle { id: subTaskDetail
					color: "#f5f5f5"
					width: parent.width
					height: parent.height
					visible: false
					anchors.centerIn: parent
					clip: true

					property int id: -1
					property string textcolor: "transparent"
					property string desc
					property int status: 1
					property string createdon
					property string updatedon

					function init()
					{
						subTaskDetail.visible = false
						subTaskDetail.id = -1
						subTaskDetail.color = "#f5f5f5"
						subTaskDetail.textcolor = "transparent"
					}

					IPCButton {
						icon: qsTr("\uf00d")
						color: subTaskDetail.color
						textColor: subTaskDetail.textcolor
						height: 40
						width: 40
						shadow: false
						radius: 0
						onClicked: {
							subTaskDetail.id = -1
							subTaskDetail.color = "#f5f5f5"
							subTaskDetail.visible = false
						}
						anchors.left: parent.left
						anchors.top: parent.top
					}

					Column {
						width: parent.width - 40
						height: parent.height - 40
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.bottom: parent.bottom
						Rectangle {
							width: parent.width
							height: 40
							color: subTaskDetail.textcolor
							radius: height/2
							Text {
								color: subTaskDetail.color
								font.pixelSize: 12
								text: subTaskDetail.status == 1 ? subTaskDetail.createdon : subTaskDetail.createdon + " - " + subTaskDetail.updatedon
								anchors.centerIn: parent
								width: parent.width - 20
							}
						}
						Item {
							width: parent.width
							height: parent.height - 80
							Text {
								color: subTaskDetail.textcolor
								font.pixelSize: 16
								text: subTaskDetail.desc
								width: parent.width - 20
								height: parent.height - 20
								anchors.centerIn: parent
								wrapMode: Text.WordWrap
								onLinkActivated: Qt.openUrlExternally(link)
							}
						}						
						Item {
							width: parent.width
							height: 40
							Text {
								color: subTaskDetail.textcolor
								font.pixelSize: 12
								text: subTaskDetail.status == 1 ? "Status : PENDING" : "Status : COMPLETED"
								anchors.centerIn: parent
								width: parent.width - 20
							}
						}
					}
				}
			}

			Rectangle { id: subTaskShow
				width: 340
				height: parent.height
				color: "#fcfcfc"

				Item {
					width: parent.width
					height: parent.height - actionBlk.height
					anchors.top: parent.top
					clip: true

					ListView { id: listView
						anchors.fill: parent
						anchors.topMargin: 20
						anchors.bottomMargin: 20
						anchors.rightMargin: 20
						delegate: subTaskDelegate
						spacing: 10
						currentIndex: count-1
						ScrollBar.vertical: ScrollBar{
							anchors.left: parent.right
							anchors.leftMargin: 5
							active: true
							onActiveChanged: active = true
						}

						Connections {
							target: Dtt
							onCurrentTaskChanged: listView.model = Dtt.subTasks
						}
					}

					Component { id: subTaskDelegate
						Row {
							height: 40
							width: parent.width
							clip: true
							Item {
								height: 20
								anchors.verticalCenter: parent.verticalCenter
								width: 10
								clip: true
								Rectangle { id: statuscolor
									height: parent.height
									width: height
									radius: width/2
									anchors.right: parent.right
									property string textcolor: subTaskDetail.id === _ST_id ? _ST_status == 1 ? "#555" : _ST_status == 0 ? "#fff" : "#f9f9f9" : "transparent"
									color: subTaskDetail.id === _ST_id ? _ST_status == 1 ? "#f5f5f5" : _ST_status == 0 ? "#333" : "#27ae60" : "transparent"
								}
							}
							Item {
								height: parent.height
								width: item.status == 1 ? parent.width - 5 : _ST_status == 2 ? parent.width - 45 : parent.width - 85
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
										subTaskDetail.id = _ST_id
										subTaskDetail.textcolor = statuscolor.textcolor
										subTaskDetail.color = statuscolor.color
										subTaskDetail.desc = _ST_description
										subTaskDetail.status = _ST_status
										subTaskDetail.createdon = _ST_createdon
										subTaskDetail.updatedon = _ST_updatedon
										subTaskDetail.visible = true
									}
								}
							}
							IPCButton {
								visible: _ST_status != 2 && item.status != 1
								height: visible ? parent.height : 0
								width: 40
								radius: 0
								shadow: false
								icon: qsTr("\uf00c")
								color: "#fff"
								textColor: "#555"
								onClicked: {
									subTaskDetail.init()
									Dtt.stepSubTask(_ST_id)
								}
							}
							IPCButton {
								visible: item.status != 1
								height: visible ? parent.height : 0
								width: 40
								radius: 0
								shadow: false
								icon: qsTr("\uf1f8")
								color: "#fff"
								textColor: "#555"
								onClicked: {
									subTaskDetail.init()
									Dtt.deleteSubTask(_ST_id)
								}
							}
						}
					}

					Text {
						visible: listView.count === 0
						text: qsTr("No SubTasks")
						font.pixelSize: 30
						font.weight: Font.Light
						color: "#bbb"
						anchors.centerIn: parent
					}
				}
				Item { id:actionBlk
					anchors.bottom: parent.bottom
					height: item.status == 1 ? 0 : 80
					visible: item.status == 1 ? false : true
					width: parent.width
					property bool btnshow: true
					IPCButton {
						shadow: false
						radius: 0
						anchors.centerIn: parent
						text: qsTr("Add Sub Tasks")
						visible: parent.btnshow
						onClicked: {
							actionBlk.btnshow = false
							subTaskInput.text = ""
							subTaskInput.forceActiveFocus()
						}
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
							onAccepted: {
								if(subTaskInput.text == "")
									return;
								Dtt.addSubTask(item.taskid,subTaskInput.text)
								actionBlk.btnshow = true
							}
						}
						IPCButton {
							height: 40
							width: 40
							icon: qsTr("\uf067")
							active: true
							radius: 0
							shadow: false
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
							shadow: false
							onClicked: {
								actionBlk.btnshow = true
							}
						}
					}

				}
			}

		}
	}
}

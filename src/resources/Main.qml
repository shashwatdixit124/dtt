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
import QtCharts 2.0
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
		property int widthFactor : (cardWidth/100 - 3)*2
		property int titleFontSize : 16 + widthFactor
		property int descFontSize : 14 + widthFactor
		property int dateFontSize : 12 + widthFactor
		visible: titleBar.activeTab == 0

		Item {
			anchors.top: parent.top
			height: 80

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
					onClicked: createTaskPopup.show()
				}
				IPCButton {
					height: parent.height
					width: 150
					text: qsTr("\uf00e  Zoom In")
					radius: width / 2
					shadow: false
					onClicked: {
						if(taskViewGrid.cardWidth < 700)
							taskViewGrid.cardWidth += 100
					}
				}
				IPCButton {
					height: parent.height
					width: 150
					text: qsTr("\uf010  Zoom Out")
					radius: width / 2
					shadow: false
					onClicked: {
						if(taskViewGrid.cardWidth > 300)
							taskViewGrid.cardWidth -= 100
					}
				}
			}

		}

		Flickable {
			contentWidth: parent.cardWidth*3 + 40 + 40
			clip: true
			width: parent.width
			height: parent.height - 80
			anchors.bottom: parent.bottom

			ScrollBar.horizontal: ScrollBar {}

			Row {
				anchors.fill: parent
				anchors.margins: spacing
				spacing: 20

				Item { id: pendingTaskViewer
					width: taskViewGrid.cardWidth
					height: parent.height
					ListView { id:pendingTasks
						anchors.fill: parent
						model: Dtt.pendingTasks
						spacing: 20
						delegate: taskCard
					}
				}
				Item { id: wipTaskViewer
					width: taskViewGrid.cardWidth
					height: parent.height
					ListView { id:wipTasks
						anchors.fill: parent
						model: Dtt.wipTasks
						spacing: 20
						delegate: taskCard
					}
				}
				Item { id: completedTaskViewer
					width: taskViewGrid.cardWidth
					height: parent.height
					ListView { id:completedTasks
						anchors.fill: parent
						model: Dtt.completedTasks
						spacing: 20
						delegate: taskCard
					}
				}
			}
		}

	}

	Item { id: graph
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: titleBar.bottom
		anchors.bottom: statusBar.top
		visible: titleBar.activeTab == 1

		ChartView { id: graphChart
			title: "Last 7 Days"
			anchors.fill: parent
			antialiasing: true

			function createGraph()
			{
				removeAllSeries();
				yAxis.max = Dtt.maxYValue

				createSeries(LineSeries,"Pending",xAxis,yAxis);
				createSeries(LineSeries,"WIP",xAxis,yAxis);
				createSeries(LineSeries,"Completed",xAxis,yAxis);

				series("Pending").color = "#aaa"
				series("Pending").pointsVisible = true
				series("Pending").append(1,Dtt.pending7Day[6])
				series("Pending").append(2,Dtt.pending7Day[5])
				series("Pending").append(3,Dtt.pending7Day[4])
				series("Pending").append(4,Dtt.pending7Day[3])
				series("Pending").append(5,Dtt.pending7Day[2])
				series("Pending").append(6,Dtt.pending7Day[1])
				series("Pending").append(7,Dtt.pending7Day[0])

				series("WIP").color = "#2980b9"
				series("WIP").pointsVisible = true
				series("WIP").append(1,Dtt.wip7Day[6])
				series("WIP").append(2,Dtt.wip7Day[5])
				series("WIP").append(3,Dtt.wip7Day[4])
				series("WIP").append(4,Dtt.wip7Day[3])
				series("WIP").append(5,Dtt.wip7Day[2])
				series("WIP").append(6,Dtt.wip7Day[1])
				series("WIP").append(7,Dtt.wip7Day[0])

				series("Completed").color = "#27ae60"
				series("Completed").pointsVisible = true
				series("Completed").append(1,Dtt.completed7Day[6])
				series("Completed").append(2,Dtt.completed7Day[5])
				series("Completed").append(3,Dtt.completed7Day[4])
				series("Completed").append(4,Dtt.completed7Day[3])
				series("Completed").append(5,Dtt.completed7Day[2])
				series("Completed").append(6,Dtt.completed7Day[1])
				series("Completed").append(7,Dtt.completed7Day[0])

			}

			ValueAxis {
				id: xAxis
				min: 1
				max: 7
				tickCount: 7
			}

			ValueAxis {
				id: yAxis
				min: 0
				max: Dtt.maxYValue
				tickCount: (max % 10) == 0 ? 11 : 11
			}

			Connections{
				target: Dtt
				onUpdateGraph: graphChart.createGraph()
			}

			Component.onCompleted: createGraph()
		}

	}
	
	Component { id: taskCard
		Rectangle {
			border.color: _T_status == 0 ? "#ccc" : _T_status == 1 ? "#2980b9" : "#27ae60"
			radius: 3
			width: parent.width
			height: titleBlk.height + descBlk.height + scoreandtagBlk.height + createdonBlk.height +/* updatedonBlk.height*/ + 40

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: {
					Dtt.currentTask = _T_id
					console.log()
					showTaskPopup.taskid = _T_id
					showTaskPopup.title = _T_title
					showTaskPopup.show()
				}
			}

			Item { id: titleBlk
				width: parent.width - 40
				height: title.text != "" ? title.implicitHeight + 10 : 0
				anchors.top: parent.top
				anchors.topMargin: 10
				Text { id: title
					text: _T_title
					width: parent.width - 20
					font.pixelSize: taskViewGrid.titleFontSize
					anchors.centerIn: parent
					wrapMode: Text.WordWrap
				}
			}
			Item { id: menu
				property bool open: false
				anchors.top: parent.top
				visible: _T_status != 2
				anchors.left: titleBlk.right
				height: 40
				width: 40
				Text {
					font.pixelSize: taskViewGrid.titleFontSize
					text: qsTr("\uf0c9")
					anchors.centerIn: parent
				}
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: menu.open = !menu.open
				}
			}
			Item { id: createdonBlk
				width: parent.width
				height: createdon.implicitHeight + 10
				anchors.top: titleBlk.bottom
				Text { id: createdon
					text: _T_status == 2 ? qsTr(_T_createdon + " - " + _T_updatedon) : _T_status == 1 ? _T_updatedon : _T_createdon
					width: parent.width - 20
					font.pixelSize: taskViewGrid.dateFontSize
					font.weight: Font.Light
					color: "#555"
					anchors.centerIn: parent
					wrapMode: Text.WordWrap
				}
			}
			Item { id: descBlk
				width: parent.width
				height: desc.text != "" ? desc.implicitHeight + 10 : 0
				anchors.top: createdonBlk.bottom
				anchors.topMargin: 10
				Text { id: desc
					text: _T_description
					width: parent.width - 20
					font.pixelSize: taskViewGrid.descFontSize
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
					height: 20
					anchors.centerIn: parent
					spacing: 10
					Rectangle { id: scoreBlk
						color: "#F9BF3B"
						width: score.implicitWidth + 20
						height: parent.height
						Text { id: score
							text: _T_score
							width: parent.width - 20
							font.pixelSize: taskViewGrid.descFontSize
							font.weight: Font.Light
							wrapMode: Text.WordWrap
							anchors.centerIn: parent
						}
					}
					Rectangle { id: tagBlk
						color: "#e7e7e7"
						width: tag.text != "" ? tag.implicitWidth + 20 : 0
						height: parent.height
						Text { id: tag
							text: _T_tag != "" ? qsTr("\uf02b  ") + _T_tag : ""
							width: parent.width - 20
							font.pixelSize: taskViewGrid.descFontSize
							anchors.centerIn: parent
							font.weight: Font.Light
							wrapMode: Text.WordWrap
						}
					}
				}
			}
			Item {
				visible: menu.open
				width: 100 + taskViewGrid.widthFactor*20
				height: 80 + taskViewGrid.widthFactor*10
				anchors.right: parent.right
				anchors.top: menu.bottom
				Item { id: menuBox
					anchors.fill: parent
					IPCButton {
						icon: qsTr("\uf061")
						text: qsTr("STEP")
						textFont: Qt.font({"pixelSize":taskViewGrid.descFontSize})
						iconFont: Qt.font({"pixelSize":taskViewGrid.titleFontSize})
						color: "#f4f4f4"
						textColor: "#555"
						width: parent.width
						height: parent.height / 2
						radius: 0
						shadow: false
						anchors.top: parent.top
						onClicked:{
							Dtt.stepTask(_T_id)
						}
					}
					IPCButton {
						icon: qsTr("\uf1f8")
						text: qsTr("DELETE")
						textFont: Qt.font({"pixelSize":taskViewGrid.descFontSize})
						iconFont: Qt.font({"pixelSize":taskViewGrid.titleFontSize})
						color: "#f4f4f4"
						textColor: "#555"
						width: parent.width
						height: parent.height / 2
						radius: 0
						shadow: false
						anchors.bottom: parent.bottom
						onClicked:{
							Dtt.deleteTask(_T_id)
						}
					}
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

	ShowTaskPopup { id: showTaskPopup }

}

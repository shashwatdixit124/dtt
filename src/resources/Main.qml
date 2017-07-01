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
	minimumWidth: 980
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
				width: 200
				onClicked: {
					titleBar.activeTab = 0

				}
			}

			IPCButton {
				text: qsTr("GRAPH")
				radius: 0
				shadow: false
				active: titleBar.activeTab == 1
				width: 200
				onClicked: {
					titleBar.activeTab = 1
				}
			}

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


	Flickable { id: taskViewGrid
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: titleBar.bottom
		anchors.bottom: statusBar.top
		contentWidth: 940
		clip: true
		visible: titleBar.activeTab == 0

		ScrollBar.horizontal: ScrollBar {}

		Row {
			anchors.fill: parent
			anchors.margins: 20
			spacing: 20

			Item { id: pendingTaskViewer
				width: 300
				height: parent.height
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
				ListView { id:completedTasks
					anchors.fill: parent
					model: Dtt.completedTasks
					spacing: 20
					delegate: taskCard
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

			ValueAxis {
				id: xAxis
				min: 0
				max: 6
				tickCount: 7
			}

			ValueAxis {
				id: yAxis
				min: 0
				max: Dtt.maxYValue
				tickCount: 10
			}

			Connections{
				target: Dtt
				onUpdateGraph: {
					graphChart.removeAllSeries();
					yAxis.max = Dtt.maxYValue

					graphChart.createSeries(LineSeries,"Pending",xAxis,yAxis);
					graphChart.createSeries(LineSeries,"WIP",xAxis,yAxis);
					graphChart.createSeries(LineSeries,"Completed",xAxis,yAxis);

					graphChart.series("Pending").append(0,Dtt.pending7Day[6])
					graphChart.series("Pending").append(1,Dtt.pending7Day[5])
					graphChart.series("Pending").append(2,Dtt.pending7Day[4])
					graphChart.series("Pending").append(3,Dtt.pending7Day[3])
					graphChart.series("Pending").append(4,Dtt.pending7Day[2])
					graphChart.series("Pending").append(5,Dtt.pending7Day[1])
					graphChart.series("Pending").append(6,Dtt.pending7Day[0])

					graphChart.series("WIP").append(0,Dtt.wip7Day[6])
					graphChart.series("WIP").append(1,Dtt.wip7Day[5])
					graphChart.series("WIP").append(2,Dtt.wip7Day[4])
					graphChart.series("WIP").append(3,Dtt.wip7Day[3])
					graphChart.series("WIP").append(4,Dtt.wip7Day[2])
					graphChart.series("WIP").append(5,Dtt.wip7Day[1])
					graphChart.series("WIP").append(6,Dtt.wip7Day[0])

					graphChart.series("Completed").append(0,Dtt.completed7Day[6])
					graphChart.series("Completed").append(1,Dtt.completed7Day[5])
					graphChart.series("Completed").append(2,Dtt.completed7Day[4])
					graphChart.series("Completed").append(3,Dtt.completed7Day[3])
					graphChart.series("Completed").append(4,Dtt.completed7Day[2])
					graphChart.series("Completed").append(5,Dtt.completed7Day[1])
					graphChart.series("Completed").append(6,Dtt.completed7Day[0])
				}
			}

			LineSeries {
				name: "Pending"
				axisX: xAxis
				axisY: yAxis
				XYPoint { id: pending6 ; x: 0; y: Dtt.pending7Day[6] }
				XYPoint { id: pending5 ; x: 1; y: Dtt.pending7Day[5] }
				XYPoint { id: pending4 ; x: 2; y: Dtt.pending7Day[4] }
				XYPoint { id: pending3 ; x: 3; y: Dtt.pending7Day[3] }
				XYPoint { id: pending2 ; x: 4; y: Dtt.pending7Day[2] }
				XYPoint { id: pending1 ; x: 5; y: Dtt.pending7Day[1] }
				XYPoint { id: pending0 ; x: 6; y: Dtt.pending7Day[0] }
			}
			LineSeries {
				name: "WIP"
				axisX: xAxis
				axisY: yAxis
				XYPoint { id: wip6 ; x: 0; y: Dtt.wip7Day[6] }
				XYPoint { id: wip5 ; x: 1; y: Dtt.wip7Day[5] }
				XYPoint { id: wip4 ; x: 2; y: Dtt.wip7Day[4] }
				XYPoint { id: wip3 ; x: 3; y: Dtt.wip7Day[3] }
				XYPoint { id: wip2 ; x: 4; y: Dtt.wip7Day[2] }
				XYPoint { id: wip1 ; x: 5; y: Dtt.wip7Day[1] }
				XYPoint { id: wip0 ; x: 6; y: Dtt.wip7Day[0] }
			}
			LineSeries {
				name: "Completed"
				axisX: xAxis
				axisY: yAxis
				XYPoint { id: completed6 ; x: 0; y: Dtt.completed7Day[6] }
				XYPoint { id: completed5 ; x: 1; y: Dtt.completed7Day[5] }
				XYPoint { id: completed4 ; x: 2; y: Dtt.completed7Day[4] }
				XYPoint { id: completed3 ; x: 3; y: Dtt.completed7Day[3] }
				XYPoint { id: completed2 ; x: 4; y: Dtt.completed7Day[2] }
				XYPoint { id: completed1 ; x: 5; y: Dtt.completed7Day[1] }
				XYPoint { id: completed0 ; x: 6; y: Dtt.completed7Day[0] }
			}
		}

	}
	
	Component { id: taskCard
		Rectangle {
			border.color: _T_status == 0 ? "#ccc" : _T_status == 1 ? "#2980b9" : "#27ae60"
			radius: 3
			width: parent.width
			height: titleBlk.height + descBlk.height + scoreandtagBlk.height + createdonBlk.height +/* updatedonBlk.height*/ + 40
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
				visible: _T_status != 2
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
			Item { id: createdonBlk
				width: parent.width
				height: createdon.implicitHeight + 10
				anchors.top: titleBlk.bottom
				Text { id: createdon
					text: _T_status == 2 ? qsTr(_T_createdon + " - " + _T_updatedon) : _T_createdon
					width: parent.width - 20
					font.pixelSize: 12
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

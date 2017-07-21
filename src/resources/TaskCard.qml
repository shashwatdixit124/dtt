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

Item { id: item
	signal cardClicked

	property int taskid: 0
	property string title: ""
	property string description: ""
	property string tag: ""
	property string createdon: ""
	property string updatedon: ""
	property int subtaskcount: 0
	property int progress: 0
	property bool bookmarked: false
	property int status: 2

	property int widthFactor: 0
	property int titleFontSize : 16 + widthFactor
	property int descFontSize : 14 + widthFactor
	property int dateFontSize : 12 + widthFactor

	width: parent.width
	height: !visible ? 0 : titleBlk.height + descBlk.height + scoreandtagBlk.height + createdonBlk.height + 40 + 20
	Rectangle {
		border.color: item.status == 1 ? "#2980b9" : item.progress == 100 ? "#27ae60" : "#ccc"
		radius: 3
		width: parent.width
		height: parent.height - 20
		anchors.top: parent.top

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				Dtt.currentTask = item.taskid
				item.cardClicked()
			}
		}

		Text {
			text: qsTr("\uf02e")
			font.pixelSize: 18 + item.widthFactor
			color: item.bookmarked ? "#f39c12" : "#777"
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.leftMargin: 10
			anchors.topMargin: -5
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: Dtt.toggleBookmark(item.taskid)
			}
		}

		Item { id: titleBlk
			width: parent.width - 40
			height: title.text != "" ? title.implicitHeight + 10 : 0
			anchors.top: parent.top
			anchors.topMargin: 10
			Text { id: title
				text: item.title
				width: parent.width - 20
				font.pixelSize: item.titleFontSize
				anchors.centerIn: parent
				wrapMode: Text.WordWrap
			}
		}
		Item { id: menu
			property bool open: false
			anchors.top: parent.top
			visible: item.status != 2
			anchors.left: titleBlk.right
			height: 40
			width: 40
			Text {
				font.pixelSize: item.titleFontSize
				text: qsTr("\uf0c9")
				anchors.centerIn: parent
			}
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked:{
					Dtt.currentTask = item.taskid
					menu.open = !menu.open
				}
			}
		}
		Item { id: createdonBlk
			width: parent.width
			height: createdon.implicitHeight + 10
			anchors.top: titleBlk.bottom
			Text { id: createdon
				text: item.status == 2 ? qsTr(item.createdon + " - " + item.updatedon) : item.status == 1 ? item.updatedon : item.createdon
				width: parent.width - 20
				font.pixelSize: item.dateFontSize
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
				text: item.description
				width: parent.width - 20
				font.pixelSize: item.descFontSize
				font.weight: Font.Light
				anchors.centerIn: parent
				wrapMode: Text.WordWrap
			}
		}
		Item { id: scoreandtagBlk
			width: parent.width
			height: tagBlk.height
			anchors.top: descBlk.bottom
			anchors.topMargin: 10
			Rectangle { id: tagBlk
				color: "#e7e7e7"
				width: tag.text != "" ? tag.implicitWidth + 20 : 0
				height: width == 0 ? 0 : 20
				anchors.left: parent.left
				anchors.leftMargin: 10
				Text { id: tag
					text: item.tag != "" ? qsTr("\uf02b  ") + item.tag : ""
					width: parent.width - 20
					font.pixelSize: item.descFontSize
					anchors.centerIn: parent
					font.weight: Font.Light
					wrapMode: Text.WordWrap
				}
			}
		}
		Item {
			visible: menu.open
			width: 100 + item.widthFactor*20
			height: 80 + item.widthFactor*10
			anchors.right: parent.right
			anchors.top: menu.bottom
			Item { id: menuBox
				anchors.fill: parent
				IPCButton {
					icon: qsTr("\uf061")
					text: item.status == 1 ? qsTr("REOPEN") : qsTr("CLOSE")
					textFont: Qt.font({"pixelSize":item.descFontSize})
					iconFont: Qt.font({"pixelSize":item.titleFontSize})
					color: "#f6f6f6"
					textColor: "#555"
					active: item.status != 1 ? (( item.subtaskcount > 0 && item.progress != 100) ? true : false) : false
					activeColor: "#fafafa"
					activeTextColor: "#ccc"
					width: parent.width
					height: parent.height / 2
					radius: 0
					shadow: false
					anchors.top: parent.top
					onClicked:{
						if(!active)
							Dtt.toggleComplete(item.taskid)
					}
				}
				IPCButton {
					icon: qsTr("\uf1f8")
					text: qsTr("DELETE")
					textFont: Qt.font({"pixelSize":item.descFontSize})
					iconFont: Qt.font({"pixelSize":item.titleFontSize})
					color: "#f6f6f6"
					textColor: "#555"
					width: parent.width
					height: parent.height / 2
					radius: 0
					shadow: false
					anchors.bottom: parent.bottom
					onClicked:{
						Dtt.deleteTask(item.taskid)
					}
				}
			}
		}
	}
}

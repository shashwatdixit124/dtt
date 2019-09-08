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

Rectangle { id: box
	property string title: ""
	property string description: ""
	property int taskFontSize: 22
	property int descriptionFontSize: 16
	property string boxColor: "#f9f9f9"
	property int boxHeight: 200
	property int boxWidth: 300
	property int internalHeight: titlewrapper.height + description.implicitHeight + 20
	property bool of: boxHeight < internalHeight
	height:  !of ? internalHeight : boxHeight
	width: boxWidth
	color: boxColor
	Column {
		anchors.fill: parent
		Item { id: titlewrapper
			property bool widthOF: title.implicitWidth + 40 > parent.width
			property int shouldBeWidth: title.implicitWidth + 40
			height: title.implicitHeight + 10
			width: widthOF ? parent.width : shouldBeWidth
			Text { id: title
                font.family: fontawesome.name
				font.pixelSize: box.taskFontSize
				text: box.title
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WordWrap
				width: parent.width - 39
				anchors.centerIn: parent
			}
		}
		Item {
			height: parent.height - title.implicitHeight
			width: parent.width
			Rectangle { id: descriptionBox
				width: parent.width - 40
				height: parent.height - 20
				anchors.centerIn: parent
				color: box.boxColor
				Flickable { id: descFlickable
					clip: true
					contentHeight: description.implicitHeight
					anchors.fill: parent
					ScrollBar.vertical: ScrollBar{ id: scrollbar }
					onFlickEnded: {
						if(box.of) {
							if(atYEnd) {
								shadow.visible = false
							}
							else {
								shadow.visible = true
							}
						}
						else {
							shadow.visible = false
						}
					}

					Text { id: description
						anchors.fill: parent
                        font.family: fontawesome.name
						font.pixelSize: box.descriptionFontSize
						text: box.description
						width: parent.width
						wrapMode: Text.WordWrap
					}
				}
			}
			InnerShadow { id: shadow
				visible: box.of
				anchors.fill: descriptionBox
				source: descriptionBox
				radius: 16
				samples: 32
				color: "#30000000"
				verticalOffset: -1
				horizontalOffset: 0
				Behavior on visible { NumberAnimation {} }
			}
		}
	}
}

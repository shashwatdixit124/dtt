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

Item { id: item
	width: 200
	height: 200
	clip: true

	property real progress: 0
	property string pallete : "#2980b9"
	property int fontSize: 30
	property bool shadow: true
	property int progressWidth: 25

	Rectangle { id: colorRect
		width: parent.width
		height: parent.height
		radius: width / 2
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#4ECDC4" }
			GradientStop { position: 1.0; color: "#4183D7" }
		}
	}

	Rectangle {
		anchors.top: parent.top
		width: parent.width
		height: (1 - (item.progress * 0.01)) * parent.height
		clip: true
		Behavior on height { NumberAnimation { duration: 300 ; easing.type : Easing.InCirc } }

		Rectangle {
			anchors.top: parent.top
			width: parent.width
			height: parent.parent.height
			radius: width/2
			color: "#f6f6f6"
		}
	}

	Rectangle {
		width: parent.width - item.progressWidth
		height: parent.height - item.progressWidth
		anchors.centerIn: parent
		radius: width / 2

		Text {
			anchors.centerIn: parent
			font.pixelSize: item.fontSize
			text: qsTr(item.progress+"%")
			color: item.pallete
		}

	}

}

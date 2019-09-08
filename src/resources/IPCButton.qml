/*
 *   This file is part of IPConnect
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

Item { id: btnRoot
	signal clicked

	property alias icon : btnIcon.text
	property alias iconFont: btnIcon.font

	property alias text : btnText.text
	property alias textFont: btnText.font

	property alias color : btnBack.color
	property string textColor : "#fbfbfb"

	property bool active : false
	property string activeTextColor : "#2980b9"
	property string activeColor : textColor

	property alias radius: btnBack.radius
	property alias shadow : dropBtnBack.visible
	property alias shadowRadius: dropBtnBack.radius
	property alias shadowColor: dropBtnBack.color

	height: 40
	width: content.width <  height ? height : content.width + 20

    FontLoader { id: fontawesome; source: "qrc:/resources/fontawesome-webfont.ttf" }

	Rectangle { id: btnBack
		anchors.fill: parent
		color: btnRoot.active ? btnRoot.activeColor : "#2980b9"
		radius: 4
		clip: true

		Row { id: content
			height: parent.height
			width: iconBlk.width + textBlk.width
			anchors.horizontalCenter: parent.horizontalCenter
			Item { id: iconBlk
				width: btnIcon.implicitWidth > 0 ? 30 : 0
				height: parent.height
                Text { id: btnIcon
                    font.family: fontawesome.name
					anchors.centerIn: parent
					color: active ? btnRoot.activeTextColor : btnRoot.textColor
				}
			}
			Item { id: textBlk
				width: btnText.implicitWidth
				height: parent.height
                Text { id: btnText
					font.weight: Font.Bold
                    font.family: fontawesome.name
					anchors.verticalCenter: parent.verticalCenter
					color: active ? btnRoot.activeTextColor : btnRoot.textColor
				}
			}
		}

		MouseArea { id: btnArea
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				btnRoot.clicked()
			}
		}
	}

	DropShadow { id: dropBtnBack
		anchors.fill: btnBack
		source: btnBack
		horizontalOffset: 0
		verticalOffset: 0
		radius: 8
		samples: 17
		color: "#30000000"
		transparentBorder: true
	}
}

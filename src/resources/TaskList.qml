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
import api.dtt 1.0

Item { id: item
	signal taskClicked()

	property int cardWidth: 300
	property int widthFactor : (cardWidth/100 - 3)*2
	property alias columns: listRow.columns

	property alias tasks: list1.model


	Flickable {
		contentWidth: parent.cardWidth*parent.columns + (parent.columns)*20 + 40
		clip: true
		anchors.fill: parent

		ScrollBar.horizontal: ScrollBar {}

		Row { id: listRow
			anchors.fill: parent
			anchors.margins: spacing
			spacing: 20
			signal deletePrevoiousLists
			property int columns: 1
			onColumnsChanged: {
				deletePrevoiousLists();
				createNewLists();
			}

			ListView { id: list1
				property int unique: 0
				width: item.cardWidth
				height: parent.height
				model: item.tasks
				delegate: taskCard
				onCurrentIndexChanged: currentIndex = count > 0 ? 0 : -1
				ScrollBar.vertical: ScrollBar {}
			}

			function createNewLists() {
				for(var i = 1; i < listRow.columns ; i++) {
					var object = Qt.createQmlObject(
								"import QtQuick 2.7;"+
								"import QtQuick.Controls 2.1;"+
								"ListView {"+
								"	property int unique: "+i+" ;"+
								"	width: item.cardWidth ;"+
								"	height: parent.height ;"+
								"	model: list1.model ;"+
								"	delegate: taskCard ;"+
								"	ScrollBar.vertical: ScrollBar {} "+
								"}"
								,listRow);
					listRow.deletePrevoiousLists.connect(object.destroy);
				}
			}
		}
	}
	Component { id: taskCard
		TaskCard {
			visible: parent.parent.unique === index%item.columns
			widthFactor: item.widthFactor

			taskid: _T_id
			title: _T_title
			description: _T_description
			tag: _T_tag
			createdon: _T_createdon
			updatedon: _T_updatedon
			progress: _T_progress
			subtaskcount: _T_subtaskcount
			bookmarked: _T_bookmarked
			status: _T_status

			onCardClicked: item.taskClicked()
		}
	}
}

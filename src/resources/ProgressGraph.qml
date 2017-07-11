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
import QtCharts 2.0
import api.dtt 1.0

Item { id: graph

	ChartView { id: graphChart
		title: "Last 7 Days"
		anchors.fill: parent
		antialiasing: true

		function createGraph()
		{
			removeAllSeries();
			yAxis.max = Dtt.maxYValue

			createSeries(LineSeries,"Pending",xAxis,yAxis);
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

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
		anchors.fill: parent
		antialiasing: true

		function createGraph()
		{
			yAxis.max = Dtt.maxYValue			
			series("Pending").removePoints(0,7);
			series("Completed").removePoints(0,7);

			var curdate = toms(new Date());
			var day = 24*60*60*1000;

			for( var i=6;i>=0;i--)
			{
				var x = curdate-i*day;
				var pending = Dtt.pending7Day[i];
				var completed = Dtt.completed7Day[i];
				series("Pending").insert(6-i,x,pending);
				series("Completed").insert(6-i,x,completed);
			}
		}

		DateTimeAxis {
			id:xAxis
			format: "dd MMM"
			tickCount: 7
		}

		ValueAxis {
			id: yAxis
			min: 0
			max: Dtt.maxYValue
			tickCount: 11
		}

		LineSeries {
			name: "Pending"
			axisX: xAxis
			axisY: yAxis
			color: "#aaa"
			width: 2

			XYPoint { x: toms(new Date())-24*60*60*1000*6; y:Dtt.pending7Day[6] }
			XYPoint { x: toms(new Date())-24*60*60*1000*5; y:Dtt.pending7Day[5] }
			XYPoint { x: toms(new Date())-24*60*60*1000*4; y:Dtt.pending7Day[4] }
			XYPoint { x: toms(new Date())-24*60*60*1000*3; y:Dtt.pending7Day[3] }
			XYPoint { x: toms(new Date())-24*60*60*1000*2; y:Dtt.pending7Day[2] }
			XYPoint { x: toms(new Date())-24*60*60*1000; y:Dtt.pending7Day[1] }
			XYPoint { x: toms(new Date()); y:Dtt.pending7Day[0] }
		}

		LineSeries {
			name: "Completed"
			axisX: xAxis
			axisY: yAxis
			color: "#27ae60"
			width: 2

			XYPoint { x: toms(new Date())-24*60*60*1000*6; y:Dtt.completed7Day[6] }
			XYPoint { x: toms(new Date())-24*60*60*1000*5; y:Dtt.completed7Day[5] }
			XYPoint { x: toms(new Date())-24*60*60*1000*4; y:Dtt.completed7Day[4] }
			XYPoint { x: toms(new Date())-24*60*60*1000*3; y:Dtt.completed7Day[3] }
			XYPoint { x: toms(new Date())-24*60*60*1000*2; y:Dtt.completed7Day[2] }
			XYPoint { x: toms(new Date())-24*60*60*1000; y:Dtt.completed7Day[1] }
			XYPoint { x: toms(new Date()); y:Dtt.completed7Day[0] }
		}

		Connections{
			target: Dtt
			onUpdateGraph: graphChart.createGraph()
		}
	}
	function toms(date) {
		var msecs = date.getTime();
		return msecs;
	}
}

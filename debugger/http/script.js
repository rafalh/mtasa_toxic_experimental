var DBG_LEVEL_NAMES = {}
	DBG_LEVEL_NAMES[0] = "Custom" 
	DBG_LEVEL_NAMES[1] = "Error"
	DBG_LEVEL_NAMES[2] = "Warning" 
	DBG_LEVEL_NAMES[3] = "Info"

var DBG_LEVEL_COLORS = {}
	DBG_LEVEL_COLORS[0] = "#FFFFFF" 
	DBG_LEVEL_COLORS[1] = "#FF0000" 
	DBG_LEVEL_COLORS[2] = "#FFFF00" 
	DBG_LEVEL_COLORS[3] = "#00FF00"

var needUpdateDebug = true
var needUpdateTargerList = true

function onRequestUpdate()
{

	var queryTarget = document.getElementById("queryTarget").value;
	getDebuggerHTTPRequest
	(queryTarget,needUpdateDebug,
		function(list)
		{
			if (typeof(list) == "boolean") return;
			var element = document.getElementById("maindata")
			while (element.hasChildNodes())
			{
				element.removeChild ( element.firstChild );
			}
			var queryLevelElement = document.getElementById("queryLevel");
			var selectedLevel = queryLevelElement.selectedIndex;
			queryLevelElement.style.color = DBG_LEVEL_COLORS[selectedLevel];
			var filter = document.getElementById("queryFilter").value;
			//alert(list.length)
			for (i=0;i<list.length;i++)
			{
				var debugLevel = list[i][2];
				var textcolor = DBG_LEVEL_COLORS[debugLevel];
				var location = list[i][3] + ':' + list[i][4];
				var message = list[i][1];
				var time = list[i][5];
				if (debugLevel > selectedLevel) continue;
				if (filter != "")
				{
					if ((message.toLowerCase().search(filter.toLowerCase()) == -1) &&
						(location.toLowerCase().search(filter.toLowerCase()) == -1))
							continue;
				}
				var row = document.createElement("tr");
					var cell = document.createElement("td");
					var cellText = document.createTextNode(DBG_LEVEL_NAMES[debugLevel]);
					cell.setAttribute("class", "row2");
					cell.style.color = textcolor;
					cell.appendChild(cellText);
					row.appendChild(cell);
					
					var cell = document.createElement("td");
					var cellText = document.createTextNode(location);
					cell.setAttribute("class", "row2");
					cell.style.color = textcolor;
					cell.appendChild(cellText);
					row.appendChild(cell);
					
					var cell = document.createElement("td");
					var cellText = document.createTextNode(message);
					cell.setAttribute("class", "row2");
					cell.style.color = textcolor
					cell.appendChild(cellText);
					row.appendChild(cell)
					
					var cell = document.createElement("td");
					var cellText = document.createTextNode(convertTime(time));
					cell.setAttribute("class", "row2");
					cell.style.color = textcolor;
					cell.appendChild(cellText);
					row.appendChild(cell);
					
				document.getElementById("maindata").appendChild(row);
			}
		}
	)
	setTimeout ( "onRequestUpdate()" , 7000 )
	needUpdateDebug = false
}

function setNeedUpdateDebug()
{
	needUpdateDebug = true
}

function setNeedUpdateTargerList()
{
	needUpdateTargerList = true
}

function updateTargerList()
{
	getTargerList
	(needUpdateTargerList,
		function(list)
		{
			if (typeof(list) == "boolean") return;
			var queryTarget = document.getElementById("queryTarget").value;
			var element = document.getElementById("queryTarget")
			while (element.hasChildNodes())
			{
				element.removeChild ( element.firstChild );
			}
			list.splice( 0,0, "Server");
			var tangerElement = document.getElementById("queryTarget");
			for (i = 0; i < list.length; i++)
			{
				var columnElement = document.createElement("option");
				var columnName = list[i];
				columnElement.innerHTML = columnName;
				tangerElement.appendChild ( columnElement );
				if (queryTarget == columnName)
					document.getElementById("queryTarget").selectedIndex = i;
			}
			if (list.length == 1)
				document.getElementById("queryTarget").selectedIndex = 0
		}
	)
	setTimeout ( "updateTargerList()" , 5000 )
	needUpdateTargerList = false
}


function convertTime(time)
{
	var currentTime = new Date(time)
	currentTime.setTime(time*1000);
	var month = currentTime.getMonth() + 1; if (month < 10){month = "0" + month;}
	var day = currentTime.getDate(); if (day < 10){day = "0" + day;}
	var year = currentTime.getFullYear(); if (year < 10){year = "0" + year;}
	var minute = currentTime.getMinutes(); if (minute < 10){minute = "0" + minute;}
	var godziny = currentTime.getHours(); if (godziny < 10){godziny = "0" + godziny;}
	var seconc = currentTime.getSeconds(); if (seconc < 10){seconc = "0" + seconc;}
	return month + "-" + day + "-" + year + " " + godziny + ":" + minute + ":" + seconc; 
}
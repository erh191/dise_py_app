import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Extras.Private 1.0

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14
import QtQuick.Shapes 1.14
import QtGraphicalEffects 1.0

import "../controls"

Item {

	Rectangle {
		id: rectangle
		color: "#2c313c"
		anchors.fill: parent
		
	////////////////////////////////////////////////////////////////////
	// ############## INI GAUGE 1 ######################################
	Rectangle {
		id:rect1
		width: 220
        height: 220
        anchors.top : parent.top
        anchors.topMargin: 240
        anchors.left : parent.left
        anchors.leftMargin: 40
        visible: true
        color: "#00000000"
		
		//###### Shader effect to provide gradient-based gauge #########
		ShaderEffect {
			id: gaugeA
			anchors.fill: parent
			opacity: 0.85  
			property real angleBase: -pi*0.80
			property real angle: ((1.6*pi*(gauge1.value)/80)+pi*(0.8-(1.6*100/80)))
			// ANGLE= [1.6*PI*(MEASURE)/(MAX-MIN)]+PI*(0.8-(1.6*MAX/(MAX-MIN)))
			readonly property real pi: 3.1415926535897932384626433832795
			vertexShader: "
			uniform highp mat4 qt_Matrix;
			attribute highp vec4 qt_Vertex;
			attribute highp vec2 qt_MultiTexCoord0;
			varying highp vec2 coord;
			
			void main() {
				coord = qt_MultiTexCoord0;
				gl_Position = qt_Matrix * qt_Vertex;
				}"

			fragmentShader: "
			uniform lowp float qt_Opacity;
			uniform highp float angleBase;
			uniform highp float angle;
			varying highp vec2 coord;
			void main() {
				gl_FragColor = vec4(0.0,0.0,0.0,0.0); 
				highp vec2 d=2.0*coord-vec2(1.0,1.0);
				highp float r=length(d);
				if (0.3<=r && r<=0.9) {
					highp float a=atan(d.x,-d.y);
					if (angleBase<=a && a<=angle) {
						highp float p=(a-angleBase)/(angle-angleBase);
						gl_FragColor = vec4(0,0.0,0.4+0.6*p,p) * qt_Opacity;
						}
					}
				}"
			}
		//##### END Shader effect  #####################################
		CircularGauge {
			
			Behavior on value {
				NumberAnimation {
					duration: 900
				}
			}
			id: gauge1
			width: 0.9*rect1.width
			height: 0.9*rect1.width
			maximumValue: 100
			minimumValue: 20
			value: 100
			anchors.centerIn: parent
			style: CircularGaugeStyle {
				id: style
				labelInset: outerRadius * 0.45
				labelStepSize: 10
				function degreesToRadians(degrees) {
					return degrees * (Math.PI / 180);
				}

				background: Canvas {
				
					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();
						ctx.beginPath();
						ctx.strokeStyle = "#ff8000";
						ctx.lineWidth = outerRadius * 0.1;
						ctx.arc(outerRadius, outerRadius, outerRadius - ctx.lineWidth / 2,degreesToRadians(valueToAngle(20) - 90), degreesToRadians(valueToAngle(50) - 90));
						ctx.stroke();
						ctx.beginPath();
						ctx.strokeStyle = "#ffff00";
						ctx.lineWidth = outerRadius * 0.05;
						ctx.arc(outerRadius, outerRadius, 0.75*outerRadius - ctx.lineWidth / 2,degreesToRadians(valueToAngle(20) - 90), degreesToRadians(valueToAngle(50) - 90));
						ctx.stroke();
						ctx.beginPath();
						ctx.strokeStyle = "#ff00ff";
						ctx.lineWidth = outerRadius * 0.03;
						ctx.arc(outerRadius, outerRadius, 0.85*outerRadius - ctx.lineWidth / 2,degreesToRadians(valueToAngle(20) - 90), degreesToRadians(valueToAngle(90) - 90));
						ctx.stroke();
						///
						///
						
					}
				}

				tickmark: Rectangle {
					visible: styleData.value < 20 || styleData.value % 10 == 0  // styleData.value < 3 || 
					implicitWidth: outerRadius * 0.03
					antialiasing: true
					implicitHeight: outerRadius * 0.35
					color: styleData.value <= 50 ? "#ff8000" : "#e5e5e5"
				}

				minorTickmark: Rectangle {
					visible: styleData.value > 20  //|| styleData.value % 20 == 0
					implicitWidth: outerRadius * 0.01
					antialiasing: true
					implicitHeight: outerRadius * 0.25
					color: styleData.value <= 40 ? "#ff8000" : "#e5e5e5"
				}

				tickmarkLabel:  Text {
					visible: styleData.value < 110
					font.pixelSize: Math.max(6, outerRadius * 0.15)
					text: styleData.value
					color: styleData.value <= 40 ? "#e34c22" : "#e5e5e5"
					antialiasing: true
				}
				/*
				//#################
				needle: Canvas {
					property real needleBaseWidth: 6
					property real needleLength: outerRadius 
					property real needleTipWidth: 1
					implicitWidth: needleBaseWidth
					implicitHeight: needleLength

					property real xCenter: width / 2
					property real yCenter: height / 2

					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();

						ctx.beginPath();
						ctx.moveTo(xCenter, height-30);
						ctx.lineTo(xCenter - needleBaseWidth / 2, (height-30) - needleBaseWidth / 2);
						ctx.lineTo(xCenter - needleTipWidth / 2, 0);
						//ctx.lineTo(xCenter, yCenter - needleLength-30);
						ctx.lineTo(xCenter, 0);
						ctx.closePath();
						ctx.fillStyle = Qt.rgba(0, 0.9, 0, 0.9);
						ctx.fill();

						
						ctx.beginPath();
						ctx.moveTo(xCenter, height-30)
						ctx.lineTo(width, height-30 - needleBaseWidth / 2);
						ctx.lineTo(xCenter + needleTipWidth / 2, 0);
						ctx.lineTo(xCenter, 0);
						ctx.closePath();
						ctx.fillStyle = Qt.lighter(Qt.rgba(0, 0.7, 0, 0.9));
						ctx.fill();
						
					}
				}
				//##################
				*/
				needle: Rectangle {
					y: outerRadius * -0.3
					implicitWidth: outerRadius * 0.05
					implicitHeight: outerRadius * 0.7
					antialiasing: true
					color: "#00ff00"
				}
				
				foreground: Item {
					Rectangle {
					}
				}

			}
			Rectangle {
				id:rectsg1
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter 
				//y: 220
				width: 0.26*gauge1.width
				height: 0.13*gauge1.width
				color: "#00000000"
				Text {
					id:textgauge1
					anchors.horizontalCenter: parent.horizontalCenter
					y: 0.3*gauge1.width
					text: Math.floor(gauge1.value)
					font.family: "Helvetica"
					font.pointSize: Math.max(6, parent.width * 0.4)
					color: gauge1.value <= 50 ? "#ffff00" : "#e5e5e5"
				}
			}
			//
			Rectangle {
				id:rectsg1a
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter 
				//y: 220
				width: 0.26*gauge1.width
				height: 0.13*gauge1.width
				color: "#00000000"
				Text {
					id:textgauge1a
					anchors.horizontalCenter: parent.horizontalCenter
					y: -10
					text: "°C"
					font.family: "Helvetica"
					font.pointSize: Math.max(6, parent.width * 0.4)
					color: "#e5e5e5"
				}
			}
			Label {
                text: "Motor Temp"
                color: "#00A5FF"
                font.pointSize: 16
                anchors.bottom: gauge1.top
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
		}
	
	}
	// ############## FIN GAUGE 1  #####################################
	
	////////////////////////////////////////////////////////////////////
	
	// ############## INI GAUGE 2  #####################################
	Rectangle {
		id:rect2
		width: 355
        height: 355
        anchors.top : parent.top
        anchors.topMargin: 150
        anchors.left : parent.left
        anchors.leftMargin: 260
        visible: true
        color: "#00000000"
		
		//###### Shader effect to provide gradient-based gauge #########
		ShaderEffect {
			id: shader2
			anchors.fill: parent
			opacity: 0.85  
			property real angleBase: -pi*0.80
			property real angle: ((1.6*pi*(gauge2.value)/(gauge2.maximumValue-gauge2.minimumValue))+pi*(0.8-(1.6*gauge2.maximumValue/(gauge2.maximumValue-gauge2.minimumValue))))
			// ANGLE= [1.6*PI*(MEASURE)/(MAX-MIN)]+PI*(0.8-(1.6*MAX/(MAX-MIN)))
			readonly property real pi: 3.1415926535897932384626433832795
			vertexShader: "
			uniform highp mat4 qt_Matrix;
			attribute highp vec4 qt_Vertex;
			attribute highp vec2 qt_MultiTexCoord0;
			varying highp vec2 coord;
			
			void main() {
				coord = qt_MultiTexCoord0;
				gl_Position = qt_Matrix * qt_Vertex;
				}"

			fragmentShader: "
			uniform lowp float qt_Opacity;
			uniform highp float angleBase;
			uniform highp float angle;
			varying highp vec2 coord;
			void main() {
				gl_FragColor = vec4(0.0,0.0,0.0,0.0); 
				highp vec2 d=2.0*coord-vec2(1.0,1.0);
				highp float r=length(d);
				if (0.6<=r && r<=0.9) {
					highp float a=atan(d.x,-d.y);
					if (angleBase<=a && a<=angle) {
						highp float p=(a-angleBase)/(angle-angleBase);
						gl_FragColor = vec4(0,0.0,0.4+0.6*p,p) * qt_Opacity;
						}
					}
				}"
			}
		//##### END Shader effect  #####################################
		CircularGauge {
			
			Behavior on value {
				NumberAnimation {
					duration: 900
				}
			}
			id: gauge2
			width: 0.9*rect2.width
			height: 0.9*rect2.width
			maximumValue: 200
			minimumValue: 0
			value: 100
			anchors.centerIn: parent
			style: CircularGaugeStyle {
				id: style2
				labelInset: outerRadius * 0.22
				labelStepSize: 20
				minorTickmarkInset :45
				tickmarkInset : 6
				minorTickmarkCount : 5
				tickmarkStepSize : 20
				function degreesToRadians(degrees) {
					return degrees * (Math.PI / 180);
				}

				background: Canvas {
				
					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();
						/*
						ctx.beginPath();
						ctx.strokeStyle = "#ff8000";
						ctx.lineWidth = outerRadius * 0.1;
						ctx.arc(outerRadius, outerRadius, outerRadius - ctx.lineWidth / 2,degreesToRadians(valueToAngle(20) - 90), degreesToRadians(valueToAngle(50) - 90));
						ctx.stroke();
						ctx.beginPath();
						ctx.strokeStyle = "#ffff00";
						ctx.lineWidth = outerRadius * 0.05;
						ctx.arc(outerRadius, outerRadius, 0.75*outerRadius - ctx.lineWidth / 2,degreesToRadians(valueToAngle(20) - 90), degreesToRadians(valueToAngle(50) - 90));
						ctx.stroke();
						*/
						ctx.beginPath();
						ctx.strokeStyle = "#f0f0f0";
						ctx.lineWidth = outerRadius * 0.02;
						ctx.arc(outerRadius, outerRadius, 1*outerRadius - ctx.lineWidth / 2,degreesToRadians(valueToAngle(0) - 90), degreesToRadians(valueToAngle(gauge2.maximumValue) - 90));
						ctx.stroke();
						
						ctx.beginPath();
						ctx.strokeStyle = "#f0f0f0";
						ctx.lineWidth = outerRadius * 0.02;
						ctx.arc(outerRadius, outerRadius, 0.67*outerRadius - ctx.lineWidth / 2,degreesToRadians(valueToAngle(0) - 90), degreesToRadians(valueToAngle(gauge2.maximumValue) - 90));
						ctx.stroke();
						
					}
				}

				
				tickmark: Rectangle {
					visible: styleData.value > 0  //|| styleData.value % 20 == 0  // styleData.value < 3 || 
					implicitWidth: outerRadius * 0.03
					antialiasing: true
					implicitHeight: outerRadius * 0.05
					color: styleData.value <= 50 ? "#ffff00" : "#ffff00"
				}
				

				minorTickmark: Rectangle {
					visible: styleData.value > 0 //styleData.value < 20  //|| styleData.value % 1 == 0
					implicitWidth: outerRadius * 0.05
					antialiasing: true
					implicitHeight: outerRadius * 0.07
					color: styleData.value < gauge2.value ? "#00ff00" : "#404040"
					
				}

				tickmarkLabel:  Text {
					visible: styleData.value > 0
					font.pixelSize: Math.max(6, outerRadius * 0.12)
					text: styleData.value
					color: styleData.value <= 40 ? "#e0e0e0" : "#e0e0e0"
					antialiasing: true
				}
				//#################
				needle: Canvas {
					property real needleBaseWidth: 10
					property real needleLength: outerRadius
					property real needleTipWidth: 1
					property real needleShort: outerRadius*0.6
					implicitWidth: needleBaseWidth
					implicitHeight: needleLength

					property real xCenter: width / 2
					property real yCenter: height / 2

					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();

						ctx.beginPath();
						ctx.moveTo(xCenter, height-needleShort);
						ctx.lineTo(xCenter - needleBaseWidth / 2, (height-needleShort) - needleBaseWidth / 2);
						ctx.lineTo(xCenter - needleTipWidth / 2, 0);
						//ctx.lineTo(xCenter, yCenter - needleLength-needleShort);
						ctx.lineTo(xCenter, 0);
						ctx.closePath();
						ctx.fillStyle = Qt.rgba(0, 0.9, 0, 0.9);
						ctx.fill();

						
						ctx.beginPath();
						ctx.moveTo(xCenter, height-needleShort)
						ctx.lineTo(width, height-needleShort - needleBaseWidth / 2);
						ctx.lineTo(xCenter + needleTipWidth / 2, 0);
						ctx.lineTo(xCenter, 0);
						ctx.closePath();
						ctx.fillStyle = Qt.lighter(Qt.rgba(0, 0.7, 0, 0.9));
						ctx.fill();
						
					}
				}
				//##################
				foreground: Item {
					Rectangle {
					}
				}

			}
			Rectangle {
				id:rectsg2
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter 
				//y: 220
				width: 0.26*gauge2.width
				height: 0.13*gauge2.width
				color: "#00000000"
				Text {
					id:textgauge2
					anchors.horizontalCenter: parent.horizontalCenter
					y: 70
					text: Math.floor(gauge2.value)
					font.family: "Helvetica"
					font.pointSize: Math.max(6, parent.width * 0.4)
					color:"#e5e5e5"
				}
			}
			//
			Rectangle {
				id:rectsg2a
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter 
				//y: 220
				width: 0.26*gauge2.width
				height: 0.13*gauge2.width
				color: "#00000000"
				Text {
					id:textgauge2a
					anchors.horizontalCenter: parent.horizontalCenter
					y: -10
					text: "Km/h"
					font.family: "Helvetica"
					font.pointSize: Math.max(6, parent.width * 0.4)
					color: "#e5e5e5"
				}
			}
			Label {
                text: "Speed"
                color: "#00A5FF"
                font.pointSize: 16
                anchors.bottom: gauge2.top
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
		}
	
	}
	// ############## FIN GAUGE  2  ####################################
	
	Rectangle {
        width: 200
        height: 200
        anchors.top : parent.top
        anchors.topMargin: 250
        anchors.left : parent.left
        anchors.leftMargin: 620
        visible: true
        color: "#00000000"
        CircularSlider {
                id: progressIndicator
                hideProgress: true
                hideTrack: true
                width: parent.width
                height: parent.height
                interactive: false
                minValue: 0
                maxValue: 8000
                value: 0.5//inputSlider.value
                startAngle: 0
                endAngle: 270
                rotation: 225

                Repeater {
                    model: 72
                    Rectangle {
                        id: indicator
                        width: 5
                        height: 20
                        radius: width / 2
                        //color: indicator.angle > progressIndicator.angle ? "#16171C" : "#7CFF6E"
                        color: indicator.angle > progressIndicator.endAngle ? "#00000000" : (indicator.angle > progressIndicator.angle ? "#282A36" : "#7CFF6E")
                        readonly property real angle: index * 5
                        transform: [
                            Translate {
                                x: progressIndicator.width / 2 - width / 2
                            },
                            Rotation {
                                origin.x: progressIndicator.width / 2
                                origin.y: progressIndicator.height / 2
                                angle: indicator.angle
                            }
                        ]
                    }
                }
                
            }
            Label {
				anchors.centerIn: parent
				font.pointSize: 20
				color: "#FEFEFE"
				text: Number((progressIndicator.value).toFixed(1)).toString().padStart(1, '0')
				//text : indicator.angle
           }
           Rectangle {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter 
				//y: 220
				width: 0.26*parent.width
				height: 0.13*parent.width
				color: "#00000000"
				Text {
					anchors.horizontalCenter: parent.horizontalCenter
					y: 0.45*parent.width
					text: "RPMS"
					font.family: "Helvetica"
					font.pointSize: Math.max(6, parent.width * 0.3)
					color: "#e5e5e5"
				}
			}
			Label {
				text: "RPM"
				color: "#00A5FF"
				font.pointSize: 16
				anchors.bottom: progressIndicator.top
				anchors.bottomMargin: 10
				anchors.horizontalCenter: parent.horizontalCenter
			}
        }
		/////////hazard lights////////
	Rectangle {
        width: 100
        height: 100
        anchors.top : parent.top
        anchors.topMargin: 25
        anchors.left : parent.left
        anchors.leftMargin: 390
        visible: true
        color: "#00000000"
        CircularSlider {
            hideProgress: true
            hideTrack: true
            width: parent.width
            height: parent.height
            handleColor: "#6272A4"
            handleWidth: 32
            handleHeight: 32
            minValue: 0
            maxValue: 1000
            interactive: false
            Behavior on value {
				NumberAnimation {
					duration: 900
				}
			}

            // Custom progress Indicator
            Item {
                anchors.fill: parent
                anchors.margins: 5
                Rectangle{
                    id: mask
                    anchors.fill: parent
                    radius: width / 4
                    color: "#282A36"
                    border.width: 5
                    border.color: "#44475A"
                }

                Item {
                    anchors.fill: mask
                    anchors.margins: 5
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: mask
                    }
                    Button {
						id: lightsButton
						QtObject{
							property color colorDefault: "#D0D0D0"
							property color colorMouseOver: "#E4E4E4"
							property color colorPressed: "#7C7C7C"
							id: internal
							property var dynamicColor:
							if(lightsButton.down){
								lightsButton.down ? colorPressed : colorDefault
							} else {
								lightsButton.hovered ? colorMouseOver : colorDefault
							}
						}
                        height: parent.height
                        width: parent.width
						background: Rectangle {
							color: internal.dynamicColor
						}
                    }
					Image {
                        id: icon1
                        anchors.fill: parent
                        source: "../../images/svg_images/hazard_lights.png"
                    }
                }

            }

        }
    }
	Rectangle {
        width: 140
        height: 140
        anchors.top : parent.top
        anchors.topMargin: 25
        anchors.left : parent.left
        anchors.leftMargin: 80
        visible: true
        color: "#00000000"
		
		CircularSlider {
            id: slider3
            handleVerticalOffset: -30
            trackWidth: 5
            trackColor: "#FEFEFE"
            width: parent.width
            height: parent.height
            minValue: 0
            maxValue: 12
            //value: customSlider.value*12
            snap: true
            stepSize: 1
            hideProgress: true
            hideTrack: true
            interactive: false
            Behavior on value {
				NumberAnimation {
					duration: 900
				}
			}
            /// Custom Handle
            handle: Item {
                id: item3
                width: 24
                height: 24
                Shape {
                    anchors.fill: parent
                    rotation: 180
                    ShapePath {
                        strokeWidth: 1
                        strokeColor: "#FF5555"
                        fillColor: "#FF5555"
                        startX: item.width / 2
                        startY: 0

                        PathLine { x: 0; y: item.height }
                        PathLine { x: item.width; y: item.height }
                        PathLine { x: item.width/2; y: 0 }
                    }
                }
                transform: Translate {
                    x: (slider3.handleWidth - width) / 2
                    y: (slider3.handleHeight - height) / 2
                }
            }
            /// Inner Circle
            Rectangle {
                color: "#232323"
                width: 140
                height: width
                radius: width / 2
                anchors.centerIn: parent
            }
            /// Outer Dial
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: "#fefefe"
                border.width: 4
                radius: width / 2
            }
        }
		Button {
			QtObject{
				property color colorDefault: "#232323"
				property color colorMouseOver: "#5F5F5F"
				property color colorPressed: "#707070"
				id: internalEngine
				property var dynamicColor:
				if(engine.down){
					engine.down ? colorPressed : colorDefault
				} else {
					engine.hovered ? colorMouseOver : colorDefault
				}
			}
			id: engine
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter
			implicitWidth: 100
			implicitHeight: 70
				x: 400
				y: 475
				background: Rectangle {
                width: 130
                height: width
                radius: width / 2
                anchors.centerIn: parent
				color: internalEngine.dynamicColor
			}
		}
        Rectangle {
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter 
			//y: 220
			width: 0.26*parent.width
			height: 0.13*parent.width
			color: "#00000000"
			Text {
				anchors.horizontalCenter: parent.horizontalCenter
				y: 0.080
				text: "Start/Stop"
				font.family: "Helvetica"
				font.pointSize: Math.max(6, parent.width * 0.2)
				color: "#e5e5e5"
			}
			Text {
				//anchors.horizontalCenter: parent.horizontalCenter
				y: 20
				text: "Engine"
				font.family: "Helvetica"
				font.pointSize: Math.max(6, parent.width * 0.2)
				color: "#e5e5e5"
			}
		}
    }
	/////////open door indicator////////
	Rectangle {
        width: 75
        height: 75
        anchors.top : parent.top
        anchors.topMargin: 55
        anchors.left : parent.left
        anchors.leftMargin: 680
        visible: true
        color: "#00000000"
        CircularSlider {
            id: customSlider2
            hideProgress: true
            hideTrack: true
            width: parent.width
            height: parent.height

            handleColor: "#6272A4"
            handleWidth: 32
            handleHeight: 32
            minValue: 0
            maxValue: 1000
            interactive: false
            Behavior on value {
				NumberAnimation {
					duration: 900
				}
			}

            // Custom progress Indicator
            Item {
                anchors.fill: parent
                anchors.margins: 5
                Rectangle{
                    id: mask2
                    anchors.fill: parent
                    radius: width / 4
                    color: "#282A36"
                    border.width: 5
                    border.color: "#44475A"
                }

                Item {
                    anchors.fill: mask2
                    anchors.margins: 5
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: mask2
                    }
                    Button {
						id: doorIndicator
						QtObject{
							property color colorDefault: "#D0D0D0"
							property color colorMouseOver: "#E4E4E4"
							property color colorPressed: "#7C7C7C"
							id: internalDoor
							property var dynamicColor:
							if(doorIndicator.down){
								doorIndicator.down ? colorPressed : colorDefault
							} else {
								doorIndicator.hovered ? colorMouseOver : colorDefault
							}
						}
                        height: parent.height  //customSlider.value / customSlider.maxValue
                        width: parent.width
						background: Rectangle {
							color: internalDoor.dynamicColor
						}
                    }
					Image {
                        id: icon2
                        anchors.fill: parent
                        source: "../../images/svg_images/door.png"
                    }
                }

            }

        }
    }

	Rectangle {
    	width: 400
        height: 75
        anchors.top : parent.top
        anchors.topMargin: 540
        anchors.left : parent.left
        anchors.leftMargin: 250
        visible: true
        color: "#00000000"
		id:gauge4
		Rectangle {
            color: "#232323"
            width: 400
            height: 75
            anchors.centerIn: parent

        }
        /// Outer Dial
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#fefefe"
            border.width: 4
            //radius: width / 2
        }

		Rectangle {
			anchors.left : parent.left
			anchors.leftMargin: 15
			y: 10
			width: 0.26*parent.width
			height: 0.13*parent.width
			color: "#00000000"
			Button {
				id: reverse
				QtObject{
					property color colorDefault: "#CBCBCB"
					property color colorMouseOver: "#5F5F5F"
					property color colorPressed: "#707070"
					id: internalReverse
					property var dynamicColor:
					if(reverse.down){
						reverse.down ? colorPressed : colorDefault
					} else {
						reverse.hovered ? colorMouseOver : colorDefault
					}
				}
				anchors.left : parent.left
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				implicitWidth: 60
				implicitHeight: 50
					x: 400
					y: 100
					background: Rectangle {
						color: internalReverse.dynamicColor
				}

				Text {
					anchors.horizontalCenter: parent.horizontalCenter
					y: 10
					text: "R"
					font.family: "Helvetica"
					font.pointSize: Math.max(6, parent.width * 0.2)
					color: "#FE2D00"
				}
			}

		}

		Rectangle {
			anchors.left : parent.left
			anchors.leftMargin: 150
			y: 10
			width: 0.26*parent.width
			height: 0.13*parent.width
			color: "#00000000"
			Button {
				id: neutral
				QtObject{
					property color colorDefault: "#CBCBCB"
					property color colorMouseOver: "#5F5F5F"
					property color colorPressed: "#707070"
					id: internalNeutral
					property var dynamicColor:
					if(neutral.down){
						neutral.down ? colorPressed : colorDefault
					} else {
						neutral.hovered ? colorMouseOver : colorDefault
					}
				}
				anchors.left : parent.left
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				implicitWidth: 60
				implicitHeight: 50
					x: 600
					y: 100
					background: Rectangle {
						color: internalNeutral.dynamicColor
				}

				Text {
					anchors.horizontalCenter: parent.horizontalCenter
					y: 10
					text: "N"
					font.family: "Helvetica"
					font.pointSize: Math.max(6, parent.width * 0.2)
					color: "#FE2D00"
				}
			}
		}

		Rectangle {
			anchors.left : parent.left
			anchors.leftMargin: 280
			y: 10
			width: 0.26*parent.width
			height: 0.13*parent.width
			Button {
				id: drive
				QtObject{
					property color colorDefault: "#CBCBCB"
					property color colorMouseOver: "#5F5F5F"
					property color colorPressed: "#707070"
					id: internalDrive
					property var dynamicColor:
					if(drive.down){
						drive.down ? colorPressed : colorDefault
					} else {
						drive.hovered ? colorMouseOver : colorDefault
					}
				}
				anchors.left : parent.left
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				implicitWidth: 60
				implicitHeight: 50
					x: 600
					y: 100
					background: Rectangle {
						color: internalDrive.dynamicColor
				}

				Text {
					anchors.horizontalCenter: parent.horizontalCenter
					y: 10
					text: "D"
					font.family: "Helvetica"
					font.pointSize: Math.max(6, parent.width * 0.2)
					color: "#FE2D00"
				}
			}
		}
    }

	Label {
        text: "Gear Switch"
        color: "#00A5FF"
        font.pointSize: 16
        anchors.bottom: gauge4.top
    	anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
	//
	Timer{
		id:tmgauge
		interval: 250
		repeat: true
		running: true
		onTriggered: {
			gauge1.value = backend.get_adc1()//Temperatura motor
			
			progressIndicator.value = backend.get_adc5()//RPMS
			gauge2.value = progressIndicator.value/100
			//gauge3.value = backend.get_adc3()/5
			//slider.value = backend.get_adc4()/85
		}
	}
	//
	
	
	Connections{
		target: backend
		//function onValueGauge(value){
        //   slider.value = value/10
        //   progressIndicator.value = value
        //   customSlider.value = value
        //}
	}
}
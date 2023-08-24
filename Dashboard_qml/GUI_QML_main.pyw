########################################################################
###### STANDAR QT LIBRARIES
########################################################################
import sys
from PyQt5.QtCore import * 
from PyQt5.QtGui import * 
from PyQt5.QtQml import * 
from PyQt5.QtWidgets import *
from PyQt5.QtQuick import *  
#from PyQt5.QtMultimedia import* # For use audio alarms
from PyQt5.QtChart import* #  pip install PyQtChart

########################################################################
###### SPECIAL LIBRARIES
########################################################################
import os
import random
import math
import serial.tools.list_ports

#RX CAN Messages ID's
CAN_ID_EMERGENCY_LIGHTS	=	0x171
CAN_ID_MOTOR_PULSES		=	0x120
CAN_ID_DIGITAL_INPUTS	=	0x140
CAN_ID_TEMPERATURE		=	0x180

#TX CAN Messages ID's
MSG_ELIGHTS_RX_ID		=	0x170

########################################################################
###### MAIN CLASS
########################################################################
class MainWindow(QObject):
	
	###### SIGNALS #####################################################
	# Signal Set Name
	setName = pyqtSignal(str)
	
	# Signal Set Name
	setPage = pyqtSignal(str)
	
	# Signal Set Port selected
	setCom = pyqtSignal(str)
	
	# Signal Set Data
	printTime = pyqtSignal(str)
	printDate = pyqtSignal(str)
	valueGauge = pyqtSignal(str)
	printHour = pyqtSignal(str)
	
	# Signal Visible
	isVisible = pyqtSignal(bool)
	
	# Open File To Text Edit
	readText = pyqtSignal(str)
	
	#setPuerto = pyqtSignal(object) ## NOT
	setPuerto = pyqtSignal(list)
	
	# Text String
	textField = ""
	
	def __init__(self, parent=None):
		super().__init__(parent)
		self.app = QApplication(sys.argv)
		self.app.setWindowIcon(QIcon("images/chip.ico"))
		self.engine = QQmlApplicationEngine(self)
		self.engine.rootContext().setContextProperty("backend", self)
		self.engine.load(QUrl("qml/main.qml"))

		#### SETUP CUSTOM ##############################################
		self.setupData()
		self.comSerialok = 0 
		#self.nodin = [0,0,0,0]
		self.iniClock()
		sys.exit(self.app.exec_())
	
	####################################################################
	###### CLOCK TIME
	####################################################################
	def iniClock(self):
		self.timer = QTimer()
		self.timer.timeout.connect(lambda: self.setTime())
		self.timer.start(1000)
	
	def setTime(self):
		current_time = QTime.currentTime()
		time = current_time.toString('HH:mm:ss')
		date =  QDate.currentDate().toString(Qt.ISODate)
		formatDate= 'Now is '+date+' '+time
		
		numTest = str(random.randint(10,100))
		self.valueGauge.emit(numTest)
		self.printTime.emit(formatDate)
		self.printDate.emit(date)
		self.printHour.emit(time)
		
	######   Setup data registers to transfer to QML ###################
	def setupData(self):
		self.adc1 = 0
		self.adc2 = 0
		self.adc3 = 0
		self.adc4 = 0
		self.adc5 = 0
		self.adc6 = 0
		self.adc7 = 0
		self.adc8 = 0
		self.digitalsIn0 = 0
		self.digitalsIn1 = 0
		self.digitalsIn2 = 0
		self.digitalsIn3 = 0
		self.digitalsIn4 = 0
		self.digitalsIn5 = 0
		self.digitalsIn6 = 0
		self.digitalsIn7 = 0
	
	######   Function Set Name To Page #################################
	@pyqtSlot(str)
	def namePage(self, pagex):
		self.setPage.emit(pagex)
		
	####################################################################
	# SELECT PORT & START COMMUNICATION
	####################################################################
	
	######   Description NAME HARDWARE COM PORTS  ######################
	@pyqtSlot(result=list)
	def personsList(self):
		return [port.device+" "+port.description for port in serial.tools.list_ports.comports()]
	
	######   Number COM port available  ################################
	@pyqtSlot(result=QVariant)
	def get_port_list_info(self):
		return [port.device for port in serial.tools.list_ports.comports()]
	
	######  Select COM PORT TO BE USED #################################
	@pyqtSlot(str,int)
	def setPortCom(self, port, speed):
		baudrate = int(speed)
		try: 
			self.ser = serial.Serial(
				port="COM4",
				baudrate=115200,
				timeout=1,
				parity=serial.PARITY_NONE,
				stopbits=serial.STOPBITS_ONE,
				bytesize=serial.EIGHTBITS
			)
			if self.ser.is_open:
				#print("Set PORT COM :", port, speed)
				self.comSerialok = 1
				self.iniSampler()
		
		except :
			print("PUERTO SERIAL NO RESPONDE")
			#sys.exit(-1)
	
	###### Close serial port ###########################################
	@pyqtSlot(int)
	def closePort(self, value):
		self.comSerialok = 0 
		self.ser.close()
		#print("Successfully closed serial port")
	
	####################################################################
	###### SAMPLER DATA
	####################################################################
	def iniSampler(self):
		self.temporizador = QTimer()
		self.temporizador.timeout.connect(self.readData)
		self.temporizador.start(1)

	
	
	####################################################################
	# READ DATA FROM ARDUINO, ANALOGS AIN  & DIGITALS IN.
	####################################################################
	def readData(self):
		packet_received=0
		index=0
		if self.comSerialok:
			data = self.ser.read(1)
			while packet_received==0:
				data = data + self.ser.read(1)
				index=index+1
				if data[index-1]==0xfb:
					if data[index-2]==0xfa:
						packet_received=1
						print("paquete recibido!!!!")

			if data[0]==0xfc:
				if data[1]==0xfd:
					can_id=data[3]*256+data[2]
					print("can_id="+str(can_id))
					
					can_dlc=data[6]
					print("can_dlc="+str(can_dlc))

					can_data_index=10
					can_data=data[can_data_index:can_data_index+can_dlc]
					print("can_data="+str(can_data))

					if can_id==CAN_ID_EMERGENCY_LIGHTS:
						print("CAN_ID_EMERGENCY_LIGHTS")
						Din0=can_data[0]
						self.digitalsIn0 = Din0&1

					if can_id==CAN_ID_MOTOR_PULSES:		
						print("CAN_ID_MOTOR_PULSES")
						pulses=can_data[1]*256+can_data[0]
						self.adc5 = pulses
						self.adc5 = self.adc5 *15
						print("pulses="+str(self.adc5))

					if can_id==CAN_ID_DIGITAL_INPUTS:
						print("CAN_ID_DIGITAL_INPUTS")
						ignition=can_data[0]&0x02
						door	=can_data[0]&0x01
						
						if ignition:
							self.digitalsIn1 = 1
						else:
							self.digitalsIn1 = 0

						if door:
							self.digitalsIn2 = 1
						else:
							self.digitalsIn2 = 0
						gear=0
						if can_data[1] ==1 :
							gear	=100
						if can_data[1] ==2 :
							gear	=400
						
						if can_data[1] ==4 :
							gear	=800
						self.adc6 = gear
						self.adc4 = gear
						self.adc3 = gear
						self.adc2 = gear
						self.adc1 = gear
					

						print("gear"+str(self.adc6))
						
							

						


					if can_id==CAN_ID_TEMPERATURE:
						print("CAN_ID_TEMPERATURE")



					self.adc1 = 10
					self.adc2 = 88
					self.adc3 = 30
					self.adc4 = 40
					self.adc6 = 60
					self.adc7 = 70
					self.adc8 = 80






				else:
					print("err2")	
			else:
				print("err1")

		

	def readData1(self):
		print("read data")
		if self.comSerialok:
			data = self.ser.read(1)
			n = self.ser.inWaiting()
			while n:
				print("read="+str(self.ser.read(n)))
				#data = data + self.ser.read(n)
				n = self.ser.inWaiting()
				print("n="+str(n))
			print("data"+str(data))
			
		self.adc1 = 10
		self.adc2 = 88
		self.adc3 = 30
		self.adc4 = 40
		self.adc5 = 4000
		self.adc6 = 60
		self.adc7 = 70
		self.adc8 = 80
	
	####################################################################
	# REFERENCE TIME FOR GRAPHICS : VOLATILE CHART
	####################################################################
	@pyqtSlot(result=int)
	def get_tiempo(self):
		date_time = QDateTime.currentDateTime()
		unixTIME = date_time.toSecsSinceEpoch()
		#unixTIMEx = date_time.currentMSecsSinceEpoch()
		return unixTIME
	
	####################################################################
	#  Set ON/OFF output  FOR ARDUINO 
	####################################################################
	@pyqtSlot('int','QString')
	def setPinoutput(self, pin, value):
		dataled=str(pin)+value
		#print (dataled)
		if self.comSerialok:
			self.ser.write(dataled.encode())
		else :
			pass
			#print("Set PIN OUTPUT :", pin, value)
	
	####################################################################
	# Set PWM output FOR ARDUINO 
	####################################################################
	@pyqtSlot('QString','QString')
	def setPwm(self, pin, value):
		datapinpwm =pin+value
		#print (datapinpwm)
		if self.comSerialok:
			self.ser.write((pin+value).encode())
		else:
			pass
			#print("Set PWM: PIN", pin, value)
	
	####################################################################
	# SEND  DATA  FROM PYTHON   TO QML: DIGITAL INPUTS
	####################################################################
	@pyqtSlot(result=int)
	def get_din0(self):
		return self.digitalsIn0
	
	@pyqtSlot(result=int)
	def get_din1(self):
		return self.digitalsIn1
	
	@pyqtSlot(result=int)
	def get_din2(self):
		return self.digitalsIn2
	
	@pyqtSlot(result=int)
	def get_din3(self):
		return self.digitalsIn3
	
	@pyqtSlot(result=int)
	def get_din4(self):
		return self.digitalsIn4
	
	@pyqtSlot(result=int)
	def get_din5(self):
		return self.digitalsIn5
	
	@pyqtSlot(result=int)
	def get_din6(self):
		return self.digitalsIn6
	
	@pyqtSlot(result=int)
	def get_din7(self):
		return self.digitalsIn7
	
	####################################################################
	# SEND  DATA  FROM PYTHON : ANALOG INPUTS
	####################################################################
	@pyqtSlot(result=float)
	def get_adc1(self):
		return self.adc1
		
	@pyqtSlot(result=float)
	def get_adc2(self):
		return self.adc2
		
	@pyqtSlot(result=float)
	def get_adc3(self):
		return self.adc3
	
	@pyqtSlot(result=float)
	def get_adc4(self):
		return self.adc4
	
	@pyqtSlot(result=float)
	def get_adc5(self):
		return self.adc5
	
	@pyqtSlot(result=float)
	def get_adc6(self):
		return self.adc6
	
	@pyqtSlot(result=float)
	def get_adc7(self):
		return self.adc7
	
	@pyqtSlot(result=float)
	def get_adc8(self):
		return self.adc8

	####################################################################
	# SEND  DATA FROM PYTHON TO CHART CALCULATED FUNCTION (CSV, RANDOM)
	####################################################################
	@pyqtSlot(QObject)
	def update0(self, series):
		series.clear()
		for i in range(128):
			series.append(i, 45*(math.sin(0.05*3.1416*i))+ random.random()*8)
			
	@pyqtSlot(QObject)
	def update1(self, series):
		series.clear()
		for i in range(128):
			series.append(i, 20*(math.sin(0.075*3.1416*i))+ random.random()*15)
	
	@pyqtSlot(QObject)
	def update2(self, series):
		series.clear()
		for i in range(128):
			series.append(i, 25*(math.sin(0.105*3.1416*i))+ random.random()*12)
			
	@pyqtSlot(QObject)
	def update3(self, series):
		series.clear()
		for i in range(128):
			series.append(i, 30*(math.sin(0.035*3.1416*i))+ random.random()*17)

	####################################################################
	# FUNCTIONS FOR PAGE SETTINGS
	####################################################################
	
	######   Function Set Name To Label  ###############################
	@pyqtSlot(str)
	def welcomeText(self, name):
		self.setName.emit("Welcome, " + name)
	
	######  Show / Hide Rectangle ######################################
	@pyqtSlot(bool,int)
	def showHideRectangle(self, isChecked, number):
		#print("Is rectangle visible: ", isChecked, number)
		self.isVisible.emit(isChecked)
	

####################################################################
###### MAIN ROUTINE
####################################################################
if __name__ == '__main__':
	main = MainWindow()




















































































import wollok.game.*

object mapa {
	
	const obstaculos = []
	
	method iniciar() {
		game.width(9)
		game.height(9)
		game.title("Camino")
		game.cellSize(60)
		self.colocarObstaculos()
		game.addVisual(meta)
		game.addVisual(salida)
		game.addVisual(robot)
		game.onCollideDo(robot, {algo=>algo.impacto()})
		keyboard.space().onPressDo{self.empezarAMoverse()}
		keyboard.enter().onPressDo{robot.paso()}
		game.start()
	}

	method empezarAMoverse(){
	     game.onTick(1000,"paso",{robot.paso()})
	}
		
	method colocarObstaculos(){
		self.paredV(0,0,game.height()-1)
		self.paredV(game.width()-1,0,game.height()-1)
		self.paredH(0,0,game.width()-1)
		self.paredH(game.height()-1,0,game.width()-1)
		
		self.paredV(5,3,5)
		self.paredV(2,3,5)
		self.paredH(6,4,6)
		self.paredH(2,5,7)
	}
	
	method paredV(col,desde,hasta){
		(desde..hasta).forEach{fila=> obstaculos.add(new Obstaculo(position = game.at(col,fila)))}
	}
	method paredH(fila,desde,hasta){
		(desde..hasta).forEach{col=> obstaculos.add(new Obstaculo(position = game.at(col,fila)))}
	}
	
	method sinObstaculos(pos) = not obstaculos.any{o=>o.position() == pos} 
	
		
}


class Obstaculo {
	
	const property position
	
	
 	method initialize() {
 		game.addVisual(self)
 	}
	method image() = "obstaculo.png"
	
	method impacto() { game.say(self, "Chocó obstáculo")}
	method esAtravesable() = false
}



object robot{
	var celdaActual = salida
	const posibles = []
	const visitados = [salida]
	
	
	method image() = "robot.png"
		
	method position() = celdaActual.position()
	
	method paso(){
		
		posibles.addAll(self.adyacentes())	
		celdaActual.image("cuadradoNaranja.png")
		celdaActual = posibles.min{celda=>celda.ponderacion()}
		posibles.remove(celdaActual)
		celdaActual.image("cuadradoNaranja.png")
		visitados.add(celdaActual)
		game.removeVisual(self)
		game.addVisual(self)
		
	}
	
	method adyacentes() =
		self.posicionesAdyacentes().map{pos=>
			new Celda(position = pos, anterior = celdaActual)
		}
	
	method posicionesAdyacentes() = 
		[self.position().left(1).up(1)   ,  self.position().up(1)  , self.position().right(1).up(1)   ,
		 self.position().left(1)         ,                    		 self.position().right(1)         ,
		 self.position().left(1).down(1) , self.position().down(1) , self.position().right(1).down(1) ]
		 	.filter{pos=>self.esPosible(pos)}
	
	method esPosible(pos) = mapa.sinObstaculos(pos) && not self.yaEstaEnPosibles(pos) && not self.yaFueVisitado(pos)
	
	method yaEstaEnPosibles(pos) = posibles.any{o=>o.position() == pos} 
	method yaFueVisitado(pos) = visitados.any{o=>o.position() == pos} 
	
	method dibujarCamino(){
		celdaActual.dibujarCamino()
	}
}

object meta {
	method position() = game.at(6,3)
	method image() = "meta.png"
	
	method impacto() { 
		game.say(self,"Llegó a la meta")
		robot.dibujarCamino()
		game.removeTickEvent("paso")
	}
	method esAtravesable() = true
	method dibujarCamino() {}
}


class Celda {
	var property position
	var property peso = 0
	var property estimacion = 0
	var property image = "cuadradoAmarillo.png"
	var property text = ""
	var anterior 
	 
	
	method initialize() {
		//peso = (position.distance(anterior.position())*10).truncate(0)
		peso = anterior.peso() + (position.distance(anterior.position())*10).truncate(0)
		estimacion= (position.distance(meta.position())*10).truncate(0)
		game.addVisual(self)
		self.text("G"+peso+" H"+ estimacion)	
		}
	method ponderacion() = peso + estimacion
	
	method impacto() {}
	method esAtravesable() = false
	method dibujarCamino() {
		image = "cuadradoRojo.jpg"
		anterior.dibujarCamino()
		}
	
}

object salida {
	var property position = game.center()
	method peso() = 0
	method image() = "meta.png"
	method image(_) {}
	method impacto() {}
	method dibujarCamino() {}
}
	
//
//  Reto_5___Que_personaje_eresTests.swift
//  Reto 5 - Que personaje eresTests
//
//  Created by Enrique Salazar Ruiz on 20/10/26.
//  Copyright © 2026 UVEG. All rights reserved.
//

import XCTest
@testable import Reto_5___Que_personaje_eres

class Reto_5___Que_personaje_eresTests: XCTestCase {

    /// El personaje con más respuestas es el resultado.
    func testGanaElPersonajeConMasRespuestas() {
        var cuestionario = Cuestionario(preguntas: Cuestionario.preguntasBase)
        // Opciones de Goku en cada pregunta: 3, 2, 0, 2, 1
        for indice in [3, 2, 0, 2, 1] {
            cuestionario.responder(opcion: indice)
        }
        XCTAssertTrue(cuestionario.terminado)
        XCTAssertEqual(cuestionario.resultado(), .goku)
        XCTAssertEqual(cuestionario.puntajes()[.goku], 5)
    }

    /// No se pueden registrar más de cinco respuestas.
    func testNoSeAceptanRespuestasExtra() {
        var cuestionario = Cuestionario(preguntas: Cuestionario.preguntasBase)
        for _ in 0..<7 {
            cuestionario.responder(opcion: 0)
        }
        XCTAssertEqual(cuestionario.respuestas.count, 5)
    }
}

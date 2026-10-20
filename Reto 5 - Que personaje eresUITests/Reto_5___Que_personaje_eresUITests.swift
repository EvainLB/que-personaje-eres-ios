//
//  Reto_5___Que_personaje_eresUITests.swift
//  Reto 5 - Que personaje eresUITests
//
//  Created by Enrique Salazar Ruiz on 20/10/26.
//  Copyright © 2026 UVEG. All rights reserved.
//
//  Responde las cinco preguntas y guarda una captura de pantalla en cada paso.
//

import XCTest

class Reto_5___Que_personaje_eresUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    private func capturar(_ nombre: String) {
        let adjunto = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        adjunto.name = nombre
        adjunto.lifetime = .keepAlways
        add(adjunto)
    }

    func testCuestionarioCompleto() {
        // Opción elegida en cada pregunta: Spider-Man, Tony Stark, Hermione, Hermione, Hermione
        let elecciones = [0, 1, 2, 3, 0]

        for (indice, eleccion) in elecciones.enumerated() {
            let numero = indice + 1
            let contador = app.staticTexts["contadorPregunta"]
            let textoEsperado = NSPredicate(format: "label == %@", "Pregunta \(numero) de 5")
            expectation(for: textoEsperado, evaluatedWith: contador)
            waitForExpectations(timeout: 10)
            capturar("\(numero)a_Pregunta_\(numero)")

            app.buttons["opcion_\(eleccion)"].tap()
            if numero == 1 {
                // Evidencia del inciso c: la respuesta queda marcada y las opciones bloqueadas.
                capturar("\(numero)b_Respuesta_bloqueada")
            }
        }

        let nombre = app.staticTexts["nombrePersonaje"]
        XCTAssertTrue(nombre.waitForExistence(timeout: 10))
        XCTAssertEqual(nombre.label, "Hermione Granger")
        capturar("6_Resultado")
    }
}

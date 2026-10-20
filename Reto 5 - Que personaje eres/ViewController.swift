//
//  ViewController.swift
//  Reto 5 - Que personaje eres
//
//  Created by Enrique Salazar Ruiz on 20/10/26.
//  Copyright © 2026 UVEG. All rights reserved.
//
//  Funcionamiento:
//  a) Cinco preguntas determinan el personaje del usuario.
//  b) El usuario elige una respuesta de una lista de opciones.
//  c) Solo puede elegir una respuesta por pregunta y no puede cambiarla.
//  d) Al responder la pregunta 5 se cierra el cuestionario y se muestra el resultado.
//

import UIKit

// MARK: - Modelo

/// Personajes posibles. CaseIterable permite recorrerlos con un ciclo for-in.
enum Personaje: String, CaseIterable {
    case spiderMan = "Spider-Man"
    case hermione = "Hermione Granger"
    case tonyStark = "Tony Stark"
    case goku = "Goku"

    var emoji: String {
        switch self {
        case .spiderMan: return "🕷️"
        case .hermione:  return "📚"
        case .tonyStark: return "🤖"
        case .goku:      return "🐉"
        }
    }

    var descripcion: String {
        switch self {
        case .spiderMan:
            return "Como Peter Parker, eres responsable y empático: siempre buscas ayudar a los demás, aunque eso complique tu vida. Tu buen humor te ayuda a salir adelante en los momentos difíciles."
        case .hermione:
            return "Eres estudioso, organizado y muy leal con tus amigos. Te preparas antes de actuar y tu inteligencia suele ser la clave para resolver los problemas del grupo."
        case .tonyStark:
            return "Eres creativo, ingenioso y seguro de ti mismo. Te encanta inventar y usar la tecnología para resolver problemas, y no temes asumir grandes retos."
        case .goku:
            return "Eres optimista, perseverante y siempre buscas superarte. Disfrutas los retos y nunca te rindes, aunque el oponente parezca más fuerte."
        }
    }
}

/// Una opción de respuesta suma un punto al personaje con el que se relaciona.
struct Opcion {
    let texto: String
    let personaje: Personaje
}

struct Pregunta {
    let texto: String
    let opciones: [Opcion]
}

/// Lógica del cuestionario, separada de la interfaz para poder probarla.
struct Cuestionario {
    let preguntas: [Pregunta]

    /// Respuestas guardadas en orden. Solo se agregan; nunca se modifican (inciso c).
    private(set) var respuestas: [Personaje] = []

    var indicePreguntaActual: Int { respuestas.count }
    var terminado: Bool { respuestas.count == preguntas.count }
    var preguntaActual: Pregunta? { terminado ? nil : preguntas[indicePreguntaActual] }

    /// Registra la respuesta de la pregunta actual.
    mutating func responder(opcion indice: Int) {
        guard let pregunta = preguntaActual,
              indice >= 0 && indice < pregunta.opciones.count else { return }
        respuestas.append(pregunta.opciones[indice].personaje)
    }

    /// Cuenta cuántas veces se eligió cada personaje usando un diccionario.
    func puntajes() -> [Personaje: Int] {
        var conteo: [Personaje: Int] = [:]
        for personaje in Personaje.allCases {
            conteo[personaje] = 0
        }
        for personaje in respuestas {
            conteo[personaje, default: 0] += 1
        }
        return conteo
    }

    /// El personaje con más puntos. En caso de empate gana el que se eligió más recientemente.
    func resultado() -> Personaje {
        let conteo = puntajes()
        let maximo = conteo.values.max() ?? 0
        let empatados = Personaje.allCases.filter { conteo[$0] == maximo }

        if empatados.count == 1 {
            return empatados[0]
        }
        for personaje in respuestas.reversed() where empatados.contains(personaje) {
            return personaje
        }
        return empatados[0]
    }

    static let preguntasBase: [Pregunta] = [
        Pregunta(texto: "¿Cómo pasas un sábado libre?", opciones: [
            Opcion(texto: "Ayudando a alguien que lo necesita", personaje: .spiderMan),
            Opcion(texto: "Leyendo o aprendiendo algo nuevo", personaje: .hermione),
            Opcion(texto: "Creando un proyecto o inventando algo", personaje: .tonyStark),
            Opcion(texto: "Entrenando o haciendo ejercicio", personaje: .goku)
        ]),
        Pregunta(texto: "Tus amigos te describen como…", opciones: [
            Opcion(texto: "Inteligente y organizado", personaje: .hermione),
            Opcion(texto: "Carismático y seguro de sí mismo", personaje: .tonyStark),
            Opcion(texto: "Alegre y con energía sin fin", personaje: .goku),
            Opcion(texto: "Amable y con buen sentido del humor", personaje: .spiderMan)
        ]),
        Pregunta(texto: "Ante un problema difícil, tú…", opciones: [
            Opcion(texto: "Lo enfrentas de frente y no te rindes", personaje: .goku),
            Opcion(texto: "Improvisas una solución sobre la marcha", personaje: .spiderMan),
            Opcion(texto: "Investigas antes de actuar", personaje: .hermione),
            Opcion(texto: "Usas la tecnología para resolverlo", personaje: .tonyStark)
        ]),
        Pregunta(texto: "¿Qué superpoder elegirías?", opciones: [
            Opcion(texto: "Trepar paredes y tener reflejos rápidos", personaje: .spiderMan),
            Opcion(texto: "Una armadura de alta tecnología", personaje: .tonyStark),
            Opcion(texto: "Fuerza y velocidad sin límites", personaje: .goku),
            Opcion(texto: "Conocer todos los hechizos", personaje: .hermione)
        ]),
        Pregunta(texto: "¿Qué valoras más?", opciones: [
            Opcion(texto: "El conocimiento y las reglas", personaje: .hermione),
            Opcion(texto: "Superar tus propios límites", personaje: .goku),
            Opcion(texto: "La responsabilidad con los demás", personaje: .spiderMan),
            Opcion(texto: "La innovación y el ingenio", personaje: .tonyStark)
        ])
    ]
}

// MARK: - Pantalla

class ViewController: UIViewController {

    private var cuestionario = Cuestionario(preguntas: Cuestionario.preguntasBase)
    private var botonesOpcion: [UIButton] = []

    // Vista del cuestionario
    private let vistaCuestionario = UIStackView()
    private let etiquetaContador = UILabel()
    private let barraProgreso = UIProgressView(progressViewStyle: .default)
    private let etiquetaPregunta = UILabel()
    private let pilaOpciones = UIStackView()

    // Vista del resultado
    private let vistaResultado = UIStackView()
    private let etiquetaEmoji = UILabel()
    private let etiquetaNombre = UILabel()
    private let etiquetaDescripcion = UILabel()
    private let etiquetaPuntajes = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        construirInterfaz()
        mostrarPreguntaActual()
    }

    // MARK: Construcción de la interfaz

    private func construirInterfaz() {
        let titulo = UILabel()
        titulo.text = "¿Qué personaje eres?"
        titulo.font = .preferredFont(forTextStyle: .largeTitle)
        titulo.adjustsFontForContentSizeCategory = true
        titulo.textAlignment = .center
        titulo.numberOfLines = 0
        titulo.accessibilityTraits = .header

        // Cuestionario
        etiquetaContador.font = .preferredFont(forTextStyle: .subheadline)
        etiquetaContador.textColor = .secondaryLabel
        etiquetaContador.accessibilityIdentifier = "contadorPregunta"

        barraProgreso.progressTintColor = .systemPurple

        etiquetaPregunta.font = .preferredFont(forTextStyle: .title2)
        etiquetaPregunta.adjustsFontForContentSizeCategory = true
        etiquetaPregunta.numberOfLines = 0
        etiquetaPregunta.accessibilityIdentifier = "textoPregunta"

        pilaOpciones.axis = .vertical
        pilaOpciones.spacing = 12

        vistaCuestionario.axis = .vertical
        vistaCuestionario.spacing = 16
        [etiquetaContador, barraProgreso, etiquetaPregunta, pilaOpciones].forEach {
            vistaCuestionario.addArrangedSubview($0)
        }

        // Resultado
        etiquetaEmoji.font = .systemFont(ofSize: 72)
        etiquetaEmoji.textAlignment = .center

        let etiquetaTuEres = UILabel()
        etiquetaTuEres.text = "Tu personaje es"
        etiquetaTuEres.font = .preferredFont(forTextStyle: .headline)
        etiquetaTuEres.textColor = .secondaryLabel
        etiquetaTuEres.textAlignment = .center

        etiquetaNombre.font = .preferredFont(forTextStyle: .title1)
        etiquetaNombre.adjustsFontForContentSizeCategory = true
        etiquetaNombre.textAlignment = .center
        etiquetaNombre.textColor = .systemPurple
        etiquetaNombre.accessibilityIdentifier = "nombrePersonaje"

        etiquetaDescripcion.font = .preferredFont(forTextStyle: .body)
        etiquetaDescripcion.adjustsFontForContentSizeCategory = true
        etiquetaDescripcion.numberOfLines = 0
        etiquetaDescripcion.textAlignment = .center

        etiquetaPuntajes.font = .preferredFont(forTextStyle: .footnote)
        etiquetaPuntajes.textColor = .secondaryLabel
        etiquetaPuntajes.numberOfLines = 0
        etiquetaPuntajes.textAlignment = .center

        let botonReiniciar = crearBoton(titulo: "Volver a empezar")
        botonReiniciar.accessibilityIdentifier = "botonReiniciar"
        botonReiniciar.addTarget(self, action: #selector(reiniciar), for: .touchUpInside)

        vistaResultado.axis = .vertical
        vistaResultado.spacing = 14
        [etiquetaEmoji, etiquetaTuEres, etiquetaNombre, etiquetaDescripcion, etiquetaPuntajes, botonReiniciar].forEach {
            vistaResultado.addArrangedSubview($0)
        }
        vistaResultado.isHidden = true

        let pilaPrincipal = UIStackView(arrangedSubviews: [titulo, vistaCuestionario, vistaResultado])
        pilaPrincipal.axis = .vertical
        pilaPrincipal.spacing = 28
        pilaPrincipal.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pilaPrincipal)

        let margen = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            pilaPrincipal.topAnchor.constraint(equalTo: margen.topAnchor, constant: 24),
            pilaPrincipal.leadingAnchor.constraint(equalTo: margen.leadingAnchor, constant: 24),
            pilaPrincipal.trailingAnchor.constraint(equalTo: margen.trailingAnchor, constant: -24)
        ])
    }

    private func crearBoton(titulo: String) -> UIButton {
        let boton = UIButton(type: .system)
        boton.setTitle(titulo, for: .normal)
        boton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        boton.titleLabel?.adjustsFontForContentSizeCategory = true
        boton.titleLabel?.numberOfLines = 0
        boton.titleLabel?.textAlignment = .center
        boton.setTitleColor(.white, for: .normal)
        boton.setTitleColor(.white, for: .disabled)
        boton.backgroundColor = .systemPurple
        boton.layer.cornerRadius = 12
        boton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        boton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
        return boton
    }

    // MARK: Flujo del cuestionario

    /// a) y b) Muestra la pregunta actual con su lista de opciones.
    private func mostrarPreguntaActual() {
        guard let pregunta = cuestionario.preguntaActual else {
            mostrarResultado()
            return
        }

        let numero = cuestionario.indicePreguntaActual + 1
        let total = cuestionario.preguntas.count
        etiquetaContador.text = "Pregunta \(numero) de \(total)"
        barraProgreso.setProgress(Float(numero - 1) / Float(total), animated: true)
        etiquetaPregunta.text = pregunta.texto

        // Se eliminan los botones anteriores y se crean los nuevos con un ciclo.
        botonesOpcion.forEach { $0.removeFromSuperview() }
        botonesOpcion.removeAll()

        for (indice, opcion) in pregunta.opciones.enumerated() {
            let boton = crearBoton(titulo: opcion.texto)
            boton.tag = indice
            boton.accessibilityIdentifier = "opcion_\(indice)"
            boton.addTarget(self, action: #selector(opcionSeleccionada(_:)), for: .touchUpInside)
            pilaOpciones.addArrangedSubview(boton)
            botonesOpcion.append(boton)
        }
    }

    /// c) Registra una sola respuesta y bloquea las opciones para que no se pueda cambiar.
    @objc private func opcionSeleccionada(_ sender: UIButton) {
        cuestionario.responder(opcion: sender.tag)

        for boton in botonesOpcion {
            boton.isEnabled = false
            boton.backgroundColor = (boton == sender) ? .systemGreen : .systemGray3
        }
        if let titulo = sender.title(for: .normal) {
            sender.setTitle("✓ " + titulo, for: .normal)
        }

        // Breve pausa para que el usuario vea su elección antes de avanzar.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.mostrarPreguntaActual()
        }
    }

    /// d) Cierra el cuestionario y muestra el personaje con su descripción.
    private func mostrarResultado() {
        let personaje = cuestionario.resultado()
        let conteo = cuestionario.puntajes()
        let total = cuestionario.preguntas.count

        etiquetaEmoji.text = personaje.emoji
        etiquetaNombre.text = personaje.rawValue
        etiquetaDescripcion.text = personaje.descripcion

        var lineas: [String] = []
        for candidato in Personaje.allCases {
            let puntos = conteo[candidato] ?? 0
            lineas.append("\(candidato.rawValue): \(puntos) de \(total)")
        }
        etiquetaPuntajes.text = lineas.joined(separator: "\n")

        vistaCuestionario.isHidden = true
        vistaResultado.isHidden = false
        UIAccessibility.post(notification: .screenChanged, argument: etiquetaNombre)
    }

    @objc private func reiniciar() {
        cuestionario = Cuestionario(preguntas: Cuestionario.preguntasBase)
        vistaResultado.isHidden = true
        vistaCuestionario.isHidden = false
        mostrarPreguntaActual()
    }
}

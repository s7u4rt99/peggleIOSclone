//
//  GameCanvasView.swift
//  peggleclone
//
//  Created by Stuart Long on 9/2/22.
//

import SwiftUI

struct GameCanvasView: View {
    @EnvironmentObject var allLevelsManager: AllLevelsManager
    @StateObject var levelManager: LevelManager
    @Binding var start: Bool
    @State private var load = true
    @State private var rotation = 0.0
    var gameEngineManager: GameEngineManager

    var body: some View {
        ZStack {
            BackgroundView()
                .gesture(
                    DragGesture().onChanged({ value in
                        setRotation(value.location)
                    }))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            gameEngineManager.fireCannonBall(directionOf: value.location)
                        })

//            Slider(value: $rotation, in: 0...360)

            CannonView()
                .rotationEffect(.radians(rotation))
                .position(x: CannonView.positionOfCannon.xCoordinate, y: CannonView.positionOfCannon.yCoordinate)

            ForEach(levelManager.level.pegs) { peg in
                PegView(location: .constant(toCGPoint(point: peg.center)),
                        pegType: peg.type,
                        pegRadius: peg.radius)
                    .onTapGesture {
                        gameEngineManager.fireCannonBall(directionOf: toCGPoint(point: peg.center))
                    }
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                    .onAppear(perform: {
                        print("hello \(peg)")
                    })
            }

            if load {
                GeometryReader { geometry in
                    LevelLoaderView(allLevelsManager: allLevelsManager,
                                    levelManager: levelManager,
                                    load: $load,
                                    gameEngineManager: gameEngineManager)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }.background(
                    Color.black.opacity(0.65)
                        .edgesIgnoringSafeArea(.all)
                )
            }
        }
        .alert("Congratulations, you completed the level", isPresented: .constant(levelManager.isGameEnd)) {
            Button("Home") {
                goToHome()
            }
        }
    }

    private func goToHome() {
        start = false
        // TODO: clean up the engines
    }

    private func toCGPoint(point: Point) -> CGPoint {
        return CGPoint(x: point.xCoordinate, y: point.yCoordinate)
    }

    private func setRotation(_ aim: CGPoint) {
        let centerHorizontalAxis = Vector(
            xDirection: 0,
            yDirection: CannonView.positionOfCannon.yCoordinate * 2)
        let directionOfAim = Vector(
            xDirection: aim.x - CannonView.positionOfCannon.xCoordinate,
            yDirection: aim.y - CannonView.positionOfCannon.yCoordinate)
        let angleOfRotation = calculateRotation(centerHorizontalAxis,
                                                directionOfAim)
        rotation = angleOfRotation
    }

    private func calculateRotation(_ firstVector: Vector, _ secondVector: Vector) -> Double {
//        acos(firstVector.dotProductWith(vector: secondVector) /
//              (firstVector.magnitude * secondVector.magnitude))
//        * 180 / Double.pi
        -atan2(firstVector.yDirection*secondVector.xDirection - firstVector.xDirection*secondVector.yDirection,
              firstVector.xDirection*secondVector.xDirection + firstVector.yDirection*secondVector.yDirection)
    }
}

struct GameCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        GameCanvasView(levelManager: LevelManager(level: Level(name: "default", pegs: [])),
                       start: .constant(true),
                       gameEngineManager: GameEngineManager(canvasDimension: CGRect()))
    }
}

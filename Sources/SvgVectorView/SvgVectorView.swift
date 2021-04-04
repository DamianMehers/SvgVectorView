//
//  SvgVector.swift
//  AplTests
//
//  Created by Damian Mehers on 04.04.21.
//

import SwiftUI

public struct SvgVectorView: View {
    
    private let pathData: String
    
    // From https://www.w3.org/TR/SVG/paths.html#PathData - I've kept the argument names from that document, except using dx/dy for relative arguments
    fileprivate enum Command {
        case moveAbsolute(xy: CGPoint)
        case moveRelative(dx: CGFloat, dy: CGFloat)
        case closePath
        case lineToAbsolute(xy: CGPoint)
        case lineToRelative(dx: CGFloat, dy: CGFloat)
        case horizontalLineToAbsolute(x: CGFloat)
        case horizontalLineToRelative(dx: CGFloat)
        case verticalLineToAbsolute(y: CGFloat)
        case verticalLineToRelative(dy: CGFloat)
        case curveToAbsolute(xy1: CGPoint, xy2: CGPoint, xy: CGPoint)
        case curveToRelative(dx1: CGFloat, dy1: CGFloat, dx2: CGFloat, dy2: CGFloat, dx: CGFloat, dy: CGFloat)
        case smoothCurveToAbsolute(xy2: CGPoint, xy: CGPoint)
        case smoothCurveToRelative(dx2: CGFloat, dy2: CGFloat, dx: CGFloat, dy: CGFloat)
        case quadraticBezierCurveToAbsolute(xy1: CGPoint, xy: CGPoint)
        case quadraticBezierCurveToRelative(dx1: CGFloat, dy1: CGFloat, dx: CGFloat, dy: CGFloat)
        case smoothQuadraticBezierCurveToAbsolute(xy: CGPoint)
        case smoothQuadraticBezierCurveToRelative(dx: CGFloat, dy: CGFloat)
        case elllipticalArcAbsolute(rx: CGFloat, ry: CGFloat, xAxisRotation: CGFloat, largeArcFlag: Bool, sweepFlag: Bool, xy: CGPoint)
        case elllipticalArcRelative(rx: CGFloat, ry: CGFloat, xAxisRotation: CGFloat, largeArcFlag: Bool, sweepFlag: Bool, dx: CGFloat, dy: CGFloat)
        case invalid(command: String, expected: Int, actual: Int)
    }
    
    public init(pathData: String) {
        self.pathData = pathData
    }
    
    
    public var body: some View {
        Path { path in
            var parser = PathDataParser(pathData: pathData)
            let commands = parser.parse()
            
            // Some commands needs this parameter from previous commands
            var secondControlPointOfPreviousCommand: CGPoint? = nil
            
            
            // Not all commands are handled, and some are probably not implemented properly - I've just done the ones
            // I need for now. Pull requests welcome.
            for command in commands {
                
                switch command {
                
                case .moveAbsolute(xy: let xy):
                    path.move(to: xy)
                case .moveRelative(dx: let x, dy: let y):
                    if let currentPoint = path.currentPoint {
                        path.move(to: CGPoint(x: currentPoint.x + x, y: currentPoint.y + y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                case .closePath:
                    path.closeSubpath()
                case .lineToAbsolute(xy: let xy):
                    path.addLine(to: xy)
                case .lineToRelative(dx: let dx, dy: let dy):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y + dy))
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                case .horizontalLineToAbsolute(x: let x):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: x, y: currentPoint.y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                case .horizontalLineToRelative(dx: let dx):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                case .verticalLineToAbsolute(y: let y):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: currentPoint.x, y: y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                case .verticalLineToRelative(dy: let dy):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: currentPoint.x, y: dy + currentPoint.y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                case .curveToAbsolute(xy1: let xy1, xy2: let xy2, xy: let xy):
                    secondControlPointOfPreviousCommand = xy2
                    path.addCurve(to: xy, control1: xy1, control2: xy2)
                case .curveToRelative(dx1: let dx1, dy1: let dy1, dx2: let dx2, dy2: let dy2, dx: let dx, dy: let dy):
                    if let currentPoint = path.currentPoint {
                        secondControlPointOfPreviousCommand = CGPoint(x: currentPoint.x + dx2, y: currentPoint.y + dy2)
                        path.addCurve(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y + dy), control1: CGPoint(x: currentPoint.x + dx1, y: currentPoint.y + dy1), control2: CGPoint(x: currentPoint.x + dx2, y: currentPoint.y + dy2))
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                case .smoothCurveToAbsolute(xy2: let xy2, xy: let xy):
                    
                    // https://stackoverflow.com/questions/5287559/calculating-control-points-for-a-shorthand-smooth-svg-path-bezier-curve
                    if let secondControlPointOfPreviousCommand = secondControlPointOfPreviousCommand,
                       let currentPoint = path.currentPoint{
                        let x1 = 2 * currentPoint.x - secondControlPointOfPreviousCommand.x
                        let y1 = 2 * currentPoint.y - secondControlPointOfPreviousCommand.y
                        path.addCurve(to: xy, control1: CGPoint(x: x1, y: y1), control2: xy2)
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                    secondControlPointOfPreviousCommand = xy2
                    
                case .smoothCurveToRelative(dx2: _, dy2:  _, dx:  _, dy:  _):
                    unhandled(command: command)
                case .quadraticBezierCurveToAbsolute(xy1: let xy1, xy: let xy):
                    path.addQuadCurve(to: xy, control: xy1)
                case .quadraticBezierCurveToRelative(dx1: let dx1, dy1: let dy1, dx: let dx, dy: let dy):
                    if let currentPoint = path.currentPoint {
                        path.addQuadCurve(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y + dy), control: CGPoint(x: currentPoint.x + dx1, y: currentPoint.y + dy1))
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                case .smoothQuadraticBezierCurveToAbsolute(xy: let xy):
                    if let secondControlPointOfPreviousCommand = secondControlPointOfPreviousCommand,
                       let currentPoint = path.currentPoint {
                        let x1 = 2 * currentPoint.x - secondControlPointOfPreviousCommand.x
                        let y1 = 2 * currentPoint.y - secondControlPointOfPreviousCommand.y
                        path.addQuadCurve(to: xy, control: CGPoint(x: x1, y: y1))
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                case .smoothQuadraticBezierCurveToRelative(dx: _, dy: _):
                    unhandled(command: command)
                case .elllipticalArcAbsolute(rx: _, ry: _, xAxisRotation: _, largeArcFlag: _, sweepFlag: _, xy: _):
                    unhandled(command: command)
                case .elllipticalArcRelative(rx: _, ry: _, xAxisRotation: _, largeArcFlag: _, sweepFlag: _, dx: _, dy: _):
                    unhandled(command: command)
                case .invalid(command: _, expected: _, actual: _):
                    unhandled(command: command)
                }
            }
            
        }
    }
    
    private func expectedCurrentPoint(command: Command) {
        print("No current point for \(command)")
    }
    
    private func unhandled(command: Command) {
        print("Don't know how to handle \(command)")
    }
    
    // How many arguments does each command need
    private static let separatorArgmentCounts = [
        "M": 2,
        "m": 2,
        "Z": 0,
        "z": 0,
        "L": 2,
        "l": 2,
        "H": 1,
        "h": 1,
        "V": 1,
        "v": 1,
        "C": 6,
        "c": 6,
        "S": 4,
        "s": 4,
        "Q": 4,
        "q": 4,
        "T": 2,
        "t": 2,
        "A": 7,
        "a": 7,
    ]
    
    
    
    fileprivate struct PathDataParser {
        let pathData: String
        let numberFormatter = NumberFormatter()
        var commands = [Command]()
        
        var arguments = [CGFloat]()
        var currentArgment = ""
        
        var currentCommand: String = ""
        
        mutating func parse() -> [Command] {
            for ch in pathData {
                if SvgVectorView.separatorArgmentCounts.keys.contains(String(ch)) {
                    addCommand(ch: String(ch))
                } else {
                    currentCommand += String(ch)
                    if ch == "," || ch == " " {
                        addCurrentArgument()
                        currentArgment = ""
                    } else if ch == "-" {
                        addCurrentArgument()
                        currentArgment = "-"
                    } else if ch == "." && currentArgment.contains(".") { // a new arg can just start by introducing a new period 0.25.456
                        addCurrentArgument()
                        currentArgment = "."
                    } else {
                        currentArgment.append(ch)
                    }
                }
            }
            return commands
            
        }
        
        mutating func addCurrentArgument() {
            guard !currentArgment.isEmpty else { return }

            let currentArgment = self.currentArgment // save it because addCommmand wipes it out
            
            
            // Multiple commands can occur by just adding more arguments: L124 456 789 101 // Two L commands: L124 456 and L789 101
            let ch = String(currentCommand.first!)
            if let expectedArgumentCount = SvgVectorView.separatorArgmentCounts[ch],
               arguments.count == expectedArgumentCount {
                self.currentArgment = ""
                addCommand(ch: ch)
            }
            
            if let n = numberFormatter.number(from: currentArgment) {
                arguments.append(CGFloat(truncating: n))
            } else {
                print("Can't parse number \(currentArgment)")
            }
            
        }
        
        mutating func addCommand(ch: String) {
            if !currentCommand.trimmingCharacters(in: .whitespaces).isEmpty {
                if !currentArgment.trimmingCharacters(in: .whitespaces).isEmpty {
                    if let n = numberFormatter.number(from: currentArgment) {
                        arguments.append(CGFloat(truncating: n))
                    } else {
                        print("Can't parse number \(currentCommand)")
                    }
                }
                
                let ch = String(currentCommand.first!)
                if let argumentCount = SvgVectorView.separatorArgmentCounts[ch],
                   argumentCount == arguments.count {
                    commands.append(generateCommand(ch: ch, args: arguments))
                } else {
                    print("Bad arguments: \(currentCommand)")
                }
            }
            currentCommand = String(ch)
            currentArgment = ""
            arguments = [CGFloat]()
            
        }
        
        func generateCommand(ch: String, args: [CGFloat]) -> Command {
            guard let expectedArgumentCount = SvgVectorView.separatorArgmentCounts[ch] else {
                print("Unknown separator: \(ch)")
                return .invalid(command: ch, expected: 0, actual: args.count)
            }
            
            guard expectedArgumentCount == args.count else {
                return .invalid(command: ch, expected: expectedArgumentCount, actual: args.count)
            }
            
            switch ch {
            case "M":
                return .moveAbsolute(xy: CGPoint(x: args[0], y: args[1]))
            case "m":
                return .moveRelative(dx: args[0], dy: args[1])
            case "Z":
                return .closePath
            case "z":
                return .closePath
            case "L":
                return .lineToAbsolute(xy: CGPoint(x: args[0], y: args[1]))
            case "l":
                return .lineToRelative(dx: args[0], dy: args[1])
            case "H":
                return .horizontalLineToAbsolute(x: args[0])
            case "h":
                return .horizontalLineToRelative(dx: args[0])
            case "V":
                return .verticalLineToAbsolute(y: args[0])
            case "v":
                return .verticalLineToRelative(dy: args[0])
            case "C":
                return .curveToAbsolute(xy1: CGPoint(x: args[0], y: args[1]), xy2: CGPoint(x: args[2], y: args[3]), xy: CGPoint(x: args[4], y: args[5]))
            case "c":
                return .curveToRelative(dx1: args[0], dy1: args[1], dx2: args[2], dy2: args[3], dx: args[4], dy: args[5])
            case "S":
                return .smoothCurveToAbsolute(xy2: CGPoint(x: args[0], y: args[1]), xy: CGPoint( x: args[2], y: args[3]))
            case "s":
                return .smoothCurveToRelative(dx2: args[0], dy2: args[1], dx: args[2], dy: args[3])
            case "Q":
                return .quadraticBezierCurveToAbsolute(xy1: CGPoint(x: args[0], y: args[1]), xy: CGPoint( x: args[2], y: args[3]))
            case "q":
                return .quadraticBezierCurveToRelative(dx1: args[0], dy1: args[1], dx: args[2], dy: args[3])
            case "T":
                return .smoothQuadraticBezierCurveToAbsolute(xy: CGPoint(x: args[0], y: args[1]))
            case "t":
                return .smoothQuadraticBezierCurveToRelative(dx: args[0], dy: args[1])
            case "A":
                return .elllipticalArcAbsolute(rx: args[0], ry: args[1], xAxisRotation: args[2], largeArcFlag: args[3] != 0, sweepFlag: args[4] != 0, xy: CGPoint(x: args[5], y: args[6]))
            case "a":
                return .elllipticalArcRelative(rx: args[0], ry: args[1], xAxisRotation: args[2], largeArcFlag: args[3] != 0, sweepFlag: args[4] != 0, dx: args[5], dy: args[6])
            default:
                return .invalid(command: ch, expected: 0, actual: args.count)
            }
        }
        
        func checkArguments(_ ch: String, _ args: [CGFloat], expected: Int) -> Command? {
            guard args.count == expected else {
                return .invalid(command: ch, expected: expected, actual: args.count)
            }
            return nil
        }
        
        
    }
}

struct SvgVector_Previews: PreviewProvider {
    static var previews: some View {
        SvgVectorView(pathData:  square)
            .frame(width: 100, height: 100)
        SvgVectorView(pathData:  circle)
            .frame(width: 100, height: 100)
        SvgVectorView(pathData:  key)
            .scaleEffect(CGSize(width: 0.25, height: 0.25))
            .frame(width: 200, height: 200)
        
    }
    static let circle = "M48,24c0,13.255-10.745,24-24,24S0,37.255,0,24S10.745,0,24,0S48,10.745,48,24z"
    static let square = "M32,12H16c-2.2,0-4,1.8-4,4v16c0,2.2,1.8,4,4,4h16c2.2,0,4-1.8,4-4V16C36,13.8,34.2,12,32,12z M34,32c0,1.103-0.897,2-2,2H16c-1.103,0-2-0.897-2-2V16c0-1.103,0.897-2,2-2h16c1.103,0,2,0.897,2,2V32z"
    static let key = """
M356.5 16.375l-174.906 255.22 1.53 1.06 31.97 22.314 175.062-255.5L356.5 16.374zm90.063 62.22c-20.16 29.418-44.122 23.1-68.25 8.905l-48.688 72.875c21.278 16.55 36.46 35.645 18.594 61.72l42.967 29.468 28.907-42.157-14.72-9.156c-3.167 1.844-6.85 2.906-10.78 2.906-11.85 0-21.47-9.62-21.47-21.47 0-11.847 9.62-21.436 21.47-21.436s21.437 9.59 21.437 21.438c0 .195-.025.4-.03.593l15.906 9.907 17.938-26.218-37.688-23.5 11.03-17.72 14.94 9.313 10.093-16.188 24.25 15.094 17.092-24.94-43-29.436zM141.22 268.624c-.31.01-.628.023-.94.063-.827.104-1.652.284-2.53.562-3.51 1.11-7.4 4.066-10.125 7.938-2.724 3.87-4.16 8.487-4 12.125.16 3.637 1.257 6.338 5.25 9.125l76.594 53.468c3.283 2.293 5.727 2.35 9.124 1.156 3.396-1.192 7.323-4.26 10.125-8.218 2.8-3.96 4.352-8.66 4.31-12.188-.04-3.53-.89-5.787-4.374-8.22L148.03 270.97c-2.546-1.78-4.657-2.42-6.81-2.345zM84.28 312.78c-24.354.41-45.504 9.52-57.655 27.25-16.95 24.737-11.868 59.753 9.625 90.283-1.838 4.72-2.875 9.84-2.875 15.187 0 23.243 19.07 42.313 42.313 42.313 8.635 0 16.692-2.625 23.406-7.125 43.208 18.488 88.07 12.714 108.28-16.782 18.695-27.28 10.884-66.912-16.374-99.312l-63.094-44.03c-14.016-5.107-28.07-7.7-41.25-7.783-.792-.004-1.59-.012-2.375 0zm-8.593 109.126c13.143 0 23.594 10.45 23.594 23.594 0 13.143-10.45 23.625-23.593 23.625-13.142 0-23.624-10.482-23.624-23.625s10.482-23.594 23.624-23.594z
"""
}

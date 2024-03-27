//
//  ToolbarView.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/25/23.
//

import SwiftUI
import PencilKit

enum DrawingTool {
    case pencil
    case eraser
    case knife
}

struct ToolbarView: View {
    @Environment(\.undoManager) private var undoManager
    @Binding var canvas: PKCanvasView
    @State private var selectedTool: DrawingTool? = .pencil  // Default to pencil
    @State private var eraserIsVector : Bool = false
  
    let toolPicker = PKToolPicker.self
    
    let pencil = PKInkingTool(.pencil, color: .black, width: 10)
    let knife = PKLassoTool()
    @State var eraser = PKEraserTool(.bitmap)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30) //timeline bg
                .frame(width: 100, height: 500)
                .foregroundColor(.black.opacity(0.25))

            VStack {
                Spacer()

                VStack(spacing: 50) {
                    
                    Button {
                        self.selectedTool = .pencil
                        self.canvas.tool = self.pencil
                    } label: {
                        Image(self.selectedTool == .pencil ? "pencil" : "pencilGrey").offset(x: self.selectedTool == .pencil ? 30 : 0)
                    }

                    Button {
                        self.selectedTool = .eraser
                        self.canvas.tool = self.eraser
                    } label: {
                        Image(self.selectedTool == .eraser ? "eraser" : "eraserGrey").offset(x: self.selectedTool == .eraser ? 30 : 0)
                    }
                    .contextMenu {
                        Button {
                            eraserIsVector = true
                            self.eraser = PKEraserTool(.vector)
                            self.selectedTool = .eraser
                            self.canvas.tool = self.eraser
                        } label: {
                            Text("Object eraser")
                            if eraserIsVector {
                                Image(systemName: "checkmark")
                            }
                        }
                        Button {
                            eraserIsVector = false
                            self.eraser = PKEraserTool(.bitmap)
                            self.selectedTool = .eraser
                            self.canvas.tool = self.eraser
                        } label: {
                            Text("Pixel eraser")
                            if !eraserIsVector {
                                Image(systemName: "checkmark")
                            }
                        }

                    }

                    Button {
                        self.selectedTool = .knife
                        self.canvas.tool = self.knife
                    } label: {
                        
                        Image(self.selectedTool == .knife ? "knife" : "knifeGrey").offset(x: self.selectedTool == .knife ? 30 : 0)
                    }
                }

                Spacer()

                VStack(spacing: 15) {
                    Button { undoManager?.undo() } label: { Image(systemName: "arrow.uturn.backward.circle.fill") }
                    Button { undoManager?.redo() } label: { Image(systemName: "arrow.uturn.forward.circle.fill") }
                }
                .foregroundColor(.black)
                .font(.largeTitle)
                .offset(x: 15)
            }
            .frame(height: 450)
        }.onAppear {
            self.canvas.tool = self.pencil
        }
    }
}

//struct Previews_ToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ToolbarView(canvasView: .constant(PKCanvasView()))
//    }
//}

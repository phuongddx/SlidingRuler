//
//  AnySlidingRulerStyle.swift
//
//  SlidingRuler
//
//  MIT License
//
//  Copyright (c) 2020 Pierre Tacchi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


import SwiftUI

public struct AnySlidingRulerStyle: SlidingRulerStyle {
    private let cellProvider: (SlidingRulerStyleConfiguation) -> AnyFractionableView
    private let cursorProvider: () -> AnyView

    public let fractions: Int
    public let cellWidth: CGFloat
    public let cursorAlignment: VerticalAlignment
    public let hasMarks: Bool

    public init<T: SlidingRulerStyle> (style: T) {
        self.cellProvider = { (configuration: SlidingRulerStyleConfiguation) -> AnyFractionableView in
            AnyFractionableView(style.makeCellBody(configuration: configuration))
        }
        self.cursorProvider = {
            AnyView(style.makeCursorBody())
        }
        self.fractions = style.fractions
        self.cellWidth = style.cellWidth
        self.cursorAlignment = style.cursorAlignment
        self.hasMarks = style.hasMarks
    }
    
    public func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> some FractionableView {
        cellProvider(configuration)
    }
    
    public func makeCursorBody() -> some View {
        cursorProvider()
    }
}

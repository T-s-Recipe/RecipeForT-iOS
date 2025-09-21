//
//  ViewFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI

@MainActor
protocol ViewFeature: View {
    associatedtype UIEvent
    
    nonmutating func notify(_ event: UIEvent)
    nonmutating func bind<Value>(_ getValue: @escaping (Self) -> Value, onChangeNotify: @escaping (Value) -> UIEvent) -> Binding<Value>
}

extension ViewFeature {
    nonmutating func bind<Value>(
        _ getValue: @escaping (Self) -> Value,
        onChangeNotify: @escaping (Value) -> UIEvent
    ) -> Binding<Value> {
        Binding {
            getValue(self)
        } set: { value in
            notify(onChangeNotify(value))
        }
    }
}

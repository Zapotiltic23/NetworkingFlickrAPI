//
//  GCDBlackBox.swift
//
//  Created by Horacio A Sanchez
//  Copyright © Sanchez Inc. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

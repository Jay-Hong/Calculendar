//
//  CalendarDelegate.swift
//  CalendarTest
//
//  Created by Jay on 2018. 4. 18..
//  Copyright © 2018년 Jay. All rights reserved.
//

import Foundation

protocol PopupDelegate {
    func moveYearMonth(year: Int, month: Int)
    func moveYearMonth(year: Int, month: Int, day: Int)
    func saveUnitOfWork(unitOfWork: String)
    func saveMemo(memo: String)
    func savePay(pay: String)
    func saveBasePay(basePay: String)
}

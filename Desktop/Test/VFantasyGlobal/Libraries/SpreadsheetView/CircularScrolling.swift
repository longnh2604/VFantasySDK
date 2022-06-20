//
//  CircularScrolling.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/6/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import Foundation

enum CircularScrolling {
    struct Configuration {
        public static var none: CircularScrollingConfigurationBuilder<CircularScrolling.None> {
            return CircularScrollingConfigurationBuilder<CircularScrolling.None>()
        }
        public static var horizontally: CircularScrollingConfigurationBuilder<CircularScrolling.Horizontally> {
            return CircularScrollingConfigurationBuilder<CircularScrolling.Horizontally>()
        }
        public static var vertically: CircularScrollingConfigurationBuilder<CircularScrolling.Vertically> {
            return CircularScrollingConfigurationBuilder<CircularScrolling.Vertically>()
        }
        public static var both: CircularScrollingConfigurationBuilder<CircularScrolling.Both> {
            return CircularScrollingConfigurationBuilder<CircularScrolling.Both>()
        }

        private init() {}

        struct Options {
            let direction: CircularScrolling.Direction
            let headerStyle: CircularScrolling.HeaderStyle
            let tableStyle: CircularScrolling.TableStyle
        }
    }

    class None: CircularScrollingConfigurationState {}
    class Horizontally: CircularScrollingConfigurationState {
        class ColumnHeaderNotRepeated: CircularScrollingConfigurationState {
            class RowHeaderStartsFirstColumn: CircularScrollingConfigurationState {}
        }
        class RowHeaderStartsFirstColumn: CircularScrollingConfigurationState {}
    }
    class Vertically: CircularScrollingConfigurationState {
        class RowHeaderNotRepeated: CircularScrollingConfigurationState {
            class ColumnHeaderStartsFirstRow: CircularScrollingConfigurationState {}
        }
        class ColumnHeaderStartsFirstRow: CircularScrollingConfigurationState {}
    }

    class Both: CircularScrollingConfigurationState {
        class ColumnHeaderNotRepeated: CircularScrollingConfigurationState {
            class RowHeaderStartsFirstColumn: CircularScrollingConfigurationState {}
            class ColumnHeaderStartsFirstRow: CircularScrollingConfigurationState {}
            class RowHeaderNotRepeated: CircularScrollingConfigurationState {
                class RowHeaderStartsFirstColumn: CircularScrollingConfigurationState {}
                class ColumnHeaderStartsFirstRow: CircularScrollingConfigurationState {}
            }
        }
        class RowHeaderNotRepeated: CircularScrollingConfigurationState {
            class RowHeaderStartsFirstColumn: CircularScrollingConfigurationState {}
            class ColumnHeaderStartsFirstRow: CircularScrollingConfigurationState {}
            class ColumnHeaderNotRepeated: CircularScrollingConfigurationState {
                class RowHeaderStartsFirstColumn: CircularScrollingConfigurationState {}
                class ColumnHeaderStartsFirstRow: CircularScrollingConfigurationState {}
            }
        }
        class RowHeaderStartsFirstColumn: CircularScrollingConfigurationState {
            class RowHeaderNotRepeated: CircularScrollingConfigurationState {}
        }
        class ColumnHeaderStartsFirstRow: CircularScrollingConfigurationState {
            class ColumnHeaderNotRepeated: CircularScrollingConfigurationState {}
        }
    }

    struct Direction: OptionSet {
        static var vertically = Direction(rawValue: 1 << 0)
        static var horizontally = Direction(rawValue: 1 << 1)
        static var both: Direction = [.vertically, .horizontally]

        let rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    enum HeaderStyle {
        case none
        case columnHeaderStartsFirstRow
        case rowHeaderStartsFirstColumn
    }

    struct TableStyle: OptionSet {
        static var columnHeaderNotRepeated = TableStyle(rawValue: 1 << 0)
        static var rowHeaderNotRepeated = TableStyle(rawValue: 1 << 1)

        let rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

protocol CircularScrollingConfigurationState {}
protocol CircularScrollingConfiguration {
    var options: CircularScrolling.Configuration.Options { get }
}

class CircularScrollingConfigurationBuilder<T: CircularScrollingConfigurationState> : CircularScrollingConfiguration {
    var options: CircularScrolling.Configuration.Options {
        switch T.self {
        case is CircularScrolling.None.Type:
            return CircularScrolling.Configuration.Options(direction: [], headerStyle: .none, tableStyle: [])
        case is CircularScrolling.Horizontally.Type:
            return CircularScrolling.Configuration.Options(direction: [.horizontally], headerStyle: .none, tableStyle: [])
        case is CircularScrolling.Horizontally.RowHeaderStartsFirstColumn.Type:
            return CircularScrolling.Configuration.Options(direction: [.horizontally], headerStyle: .rowHeaderStartsFirstColumn, tableStyle: [.columnHeaderNotRepeated])
        case is CircularScrolling.Horizontally.ColumnHeaderNotRepeated.Type:
            return CircularScrolling.Configuration.Options(direction: [.horizontally], headerStyle: .none, tableStyle: [.columnHeaderNotRepeated])
        case is CircularScrolling.Horizontally.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn.Type:
            return CircularScrolling.Configuration.Options(direction: [.horizontally], headerStyle: .rowHeaderStartsFirstColumn, tableStyle: [.columnHeaderNotRepeated])
        case is CircularScrolling.Vertically.Type:
            return CircularScrolling.Configuration.Options(direction: [.vertically], headerStyle: .none, tableStyle: [])
        case is CircularScrolling.Vertically.ColumnHeaderStartsFirstRow.Type:
            return CircularScrolling.Configuration.Options(direction: [.vertically], headerStyle: .columnHeaderStartsFirstRow, tableStyle: [.rowHeaderNotRepeated])
        case is CircularScrolling.Vertically.RowHeaderNotRepeated.Type:
            return CircularScrolling.Configuration.Options(direction: [.vertically], headerStyle: .none, tableStyle: [.rowHeaderNotRepeated])
        case is CircularScrolling.Vertically.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow.Type:
            return CircularScrolling.Configuration.Options(direction: [.vertically], headerStyle: .columnHeaderStartsFirstRow, tableStyle: [.rowHeaderNotRepeated])
        case is CircularScrolling.Both.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .none, tableStyle: [])
        case is CircularScrolling.Both.RowHeaderStartsFirstColumn.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .rowHeaderStartsFirstColumn, tableStyle: [.columnHeaderNotRepeated])
        case is CircularScrolling.Both.ColumnHeaderStartsFirstRow.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .columnHeaderStartsFirstRow, tableStyle: [.rowHeaderNotRepeated])
        case is CircularScrolling.Both.RowHeaderStartsFirstColumn.RowHeaderNotRepeated.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .rowHeaderStartsFirstColumn, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.ColumnHeaderStartsFirstRow.ColumnHeaderNotRepeated.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .columnHeaderStartsFirstRow, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.ColumnHeaderNotRepeated.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .none, tableStyle: [.columnHeaderNotRepeated])
        case is CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .rowHeaderStartsFirstColumn, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.ColumnHeaderNotRepeated.ColumnHeaderStartsFirstRow.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .columnHeaderStartsFirstRow, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .none, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated.RowHeaderStartsFirstColumn.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .rowHeaderStartsFirstColumn, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .columnHeaderStartsFirstRow, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.RowHeaderNotRepeated.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .none, tableStyle: [.rowHeaderNotRepeated])
        case is CircularScrolling.Both.RowHeaderNotRepeated.RowHeaderStartsFirstColumn.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .rowHeaderStartsFirstColumn, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .columnHeaderStartsFirstRow, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .none, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .rowHeaderStartsFirstColumn, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        case is CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated.ColumnHeaderStartsFirstRow.Type:
            return CircularScrolling.Configuration.Options(direction: [.both], headerStyle: .columnHeaderStartsFirstRow, tableStyle: [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        default:
            return CircularScrolling.Configuration.Options(direction: [], headerStyle: .none, tableStyle: [])
        }
    }
}

extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Horizontally {
    var rowHeaderStartsFirstColumn: CircularScrollingConfigurationBuilder<CircularScrolling.Horizontally.RowHeaderStartsFirstColumn> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Horizontally.RowHeaderStartsFirstColumn>()
    }
    var columnHeaderNotRepeated: CircularScrollingConfigurationBuilder<CircularScrolling.Horizontally.ColumnHeaderNotRepeated> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Horizontally.ColumnHeaderNotRepeated>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Horizontally.RowHeaderStartsFirstColumn {}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Horizontally.ColumnHeaderNotRepeated {
    var rowHeaderStartsFirstColumn: CircularScrollingConfigurationBuilder<CircularScrolling.Horizontally.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Horizontally.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Horizontally.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn {}

extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Vertically {
    var columnHeaderStartsFirstRow: CircularScrollingConfigurationBuilder<CircularScrolling.Vertically.ColumnHeaderStartsFirstRow> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Vertically.ColumnHeaderStartsFirstRow>()
    }
    var rowHeaderNotRepeated: CircularScrollingConfigurationBuilder<CircularScrolling.Vertically.RowHeaderNotRepeated> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Vertically.RowHeaderNotRepeated>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Vertically.ColumnHeaderStartsFirstRow {}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Vertically.RowHeaderNotRepeated {
    var columnHeaderStartsFirstRow: CircularScrollingConfigurationBuilder<CircularScrolling.Vertically.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Vertically.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Vertically.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow {}

extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both {
    var rowHeaderStartsFirstColumn: CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderStartsFirstColumn> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderStartsFirstColumn>()
    }
    var columnHeaderStartsFirstRow: CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderStartsFirstRow> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderStartsFirstRow>()
    }
    var columnHeaderNotRepeated: CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated>()
    }
    var rowHeaderNotRepeated: CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.RowHeaderStartsFirstColumn {
    var rowHeaderNotRepeated: CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderStartsFirstColumn.RowHeaderNotRepeated> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderStartsFirstColumn.RowHeaderNotRepeated>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.ColumnHeaderStartsFirstRow {
    var columnHeaderNotRepeated: CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderStartsFirstRow.ColumnHeaderNotRepeated> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderStartsFirstRow.ColumnHeaderNotRepeated>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.RowHeaderStartsFirstColumn.RowHeaderNotRepeated {}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.ColumnHeaderStartsFirstRow.ColumnHeaderNotRepeated {}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.ColumnHeaderNotRepeated {
    var rowHeaderNotRepeated: CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated>()
    }
    var rowHeaderStartsFirstColumn: CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn>()
    }
    var columnHeaderStartsFirstRow: CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.ColumnHeaderStartsFirstRow> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.ColumnHeaderStartsFirstRow>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated {
    var rowHeaderStartsFirstColumn: CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated.RowHeaderStartsFirstColumn> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated.RowHeaderStartsFirstColumn>()
    }
    var columnHeaderStartsFirstRow: CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated.RowHeaderStartsFirstColumn {}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.ColumnHeaderNotRepeated.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow {}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.RowHeaderNotRepeated {
    var columnHeaderNotRepeated: CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated>()
    }
    var rowHeaderStartsFirstColumn: CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.RowHeaderStartsFirstColumn> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.RowHeaderStartsFirstColumn>()
    }
    var columnHeaderStartsFirstRow: CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderStartsFirstRow>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated {
    var rowHeaderStartsFirstColumn: CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn>()
    }
    var columnHeaderStartsFirstRow: CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated.ColumnHeaderStartsFirstRow> {
        return CircularScrollingConfigurationBuilder<CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated.ColumnHeaderStartsFirstRow>()
    }
}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated.RowHeaderStartsFirstColumn {}
extension CircularScrollingConfigurationBuilder where T: CircularScrolling.Both.RowHeaderNotRepeated.ColumnHeaderNotRepeated.ColumnHeaderStartsFirstRow {}

extension CircularScrollingConfigurationBuilder: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return "(direction: \(options.direction), tableStyle: \(options.tableStyle), headerStyle: \(options.headerStyle))"
    }

    var debugDescription: String {
        return description
    }
}

extension CircularScrolling.Direction: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        var options = [String]()
        if contains(.vertically) {
            options.append(".vertically")
        }
        if contains(.horizontally) {
            options.append(".horizontally")
        }
        return options.description
    }

    var debugDescription: String {
        return description
    }
}

extension CircularScrolling.TableStyle: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        var options = [String]()
        if contains(.columnHeaderNotRepeated) {
            options.append(".columnHeaderNotRepeated")
        }
        if contains(.rowHeaderNotRepeated) {
            options.append(".rowHeaderNotRepeated")
        }
        return options.description
    }

    var debugDescription: String {
        return description
    }
}

extension CircularScrolling.HeaderStyle: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        switch self {
        case .none:
            return ".none"
        case .columnHeaderStartsFirstRow:
            return ".columnHeaderStartsFirstRow"
        case .rowHeaderStartsFirstColumn:
            return ".rowHeaderStartsFirstColumn"
        }
    }

    var debugDescription: String {
        return description
    }
}

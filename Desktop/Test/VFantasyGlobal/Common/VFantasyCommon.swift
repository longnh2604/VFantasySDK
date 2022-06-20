//
//  VFantasyCommon.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import UIKit

let numberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumFractionDigits = 0
    nf.maximumFractionDigits = 1
    return nf
}()

class VFantasyCommon: NSObject {
    static func formatPoint(_ point: Int?, separetor: String = ".") -> String {
        guard let point = point, point > 0 else { return "0" }
        let billionNumber = point/1000000000
        let leftBillion = point - billionNumber * 1000000000
        let millionNumber = leftBillion/1000000
        let leftMillion = leftBillion - millionNumber * 1000000
        let thoundsandNumber = leftMillion/1000
        let leftThoundsand = leftMillion - thoundsandNumber * 1000
        if billionNumber > 0 {
            return "\(billionNumber)\(separetor)\(self.formatUnitPoint(millionNumber))\(separetor)\(self.formatUnitPoint(thoundsandNumber))\(separetor)\(self.formatUnitPoint(leftThoundsand))"
        }
        if millionNumber > 0 {
            return "\(millionNumber)\(separetor)\(self.formatUnitPoint(thoundsandNumber))\(separetor)\(self.formatUnitPoint(leftThoundsand))"
        }
        if thoundsandNumber > 0 {
            return "\(thoundsandNumber)\(separetor)\(self.formatUnitPoint(leftThoundsand))"
        }
        return "\(point)"
    }
    
    static private func formatUnitPoint(_ point: Int) -> String {
        if point < 10 {
            return "00\(point)"
        }
        if point < 100 {
            return "0\(point)"
        }
        return "\(point)"
    }
    
    static func budgetDisplay(_ value: Int?, suffixMillion: String = "m", suffixThousands: String = "k") -> String {
        return self.budgetDisplay(Double(value ?? 0), suffixMillion: suffixMillion, suffixThousands: suffixThousands)
    }
    
    static func budgetDisplay(_ value: Double?, suffixMillion: String = "m", suffixThousands: String = "k") -> String {
        guard let value = value else { return "0\(suffixThousands)"}
        if value >= 1000000 {
            let valueStr = numberFormatter.string(from: NSNumber(value: value/1000000)) ?? "0"
            return "\(valueStr)\(suffixMillion)"
        }
        let valueStr = numberFormatter.string(from: NSNumber(value: value/1000)) ?? "0"
        return "\(valueStr)\(suffixThousands)"
    }
    
    static func budgetDisplay(_ budget: BudgetOption?) -> String {
        if let budget = budget {
            let name = budget.name ?? ""
            return name + " (\(VFantasyCommon.budgetValue(budget)))"
        }
        return ""
    }
    
    static func budgetValue(_ budget: BudgetOption?) -> String {
        if let budget = budget {
            let value = budget.value ?? 0
            if VFantasyManager.shared.isVietnamese() {
                return "\(value.roundedWithAbbreviations.replacingOccurrences(of: ".0", with: ""))"
            }
            return "€\(value.roundedWithAbbreviations.replacingOccurrences(of: ".0", with: ""))"
        }
        return ""
    }
    
    static func changeSorting(_ sort: SortType) -> SortType {
        if sort == .asc {
            return .desc
        }
        return .asc
    }
    
    static func validSortType<T: Codable>(_ models: [T], toArray: Bool = false) -> String {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(models) {
            if let result = String(data: data, encoding: .utf8) {
                if toArray {
                    return "[\(result.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: ""))]"
                }
                return result
            }
        }
        return ""
    }
    
    static func isIphone5() -> Bool {
        return UIScreen.main.bounds.width == 320
    }
    
    /// Find available position (player in that position is nil)
    ///
    /// - Parameter players: players
    /// - Returns: index of available position, nil if all positions are full
    static func availablePositionIndex<T>(_ input: [T?]) -> Int? {
        for index in 0...input.count - 1 {
            if input[index] == nil {
                return index
            }
        }
        return nil
    }
    
    /// Calculate drafting duration to determine the minimum time allowed from draft time to start time in order to check the selected start time
    ///
    /// - Parameters:
    ///   - numberOfUsers: Number of users allowed in league
    ///   - timePerDraft: Time per draft
    /// - Returns: Minimum seconds allowed
    static func calculateDraftDuration(with numberOfUsers: Int, and timePerDraft: Int) -> Double {
        let userDouble = Double(numberOfUsers)
        let timeDouble = Double(timePerDraft)
        let duration = (timeDouble * userDouble) * 18 + 60
        let fiftyMinutes: Double = 15 * 60
        //Round to multiplier of 15
        if duration.truncatingRemainder(dividingBy: fiftyMinutes) != 0 {
            let fraction = duration / fiftyMinutes
            return ceil(fraction) * fiftyMinutes
        }
        return duration
    }
    
    /// Generate a fake player with id = 0
    ///
    /// - Returns: fake player
    static func fakePlayer() -> Player {
        return Player(id: 0, createdAt: nil, updatedAt: nil, startAt: nil, realClubID: nil, realClub: nil, name: nil, nickname: nil, photo: nil, isInjured: nil, isGoalkeeper: nil, isDefender: nil, isMidfielder: nil, isAttacker: nil, mainPosition: nil, minorPosition: nil, transferValue: nil, pointLastRound: nil, isSelected: nil, goals: nil, assists: nil, cleanSheet: nil, duelsTheyWin: nil, passes: nil, shots: nil, saves: nil, yellowCards: nil, dribbles: nil, turnovers: nil, ballsRecovered: nil, foulsCommitted: nil, totalPoint: nil, point: nil, position: nil, order: nil, transferDeadline: nil, rankStatus: nil, lastPickTurn: nil, isTrading: nil, gameweek_point: nil, season_point: nil)
    }
    
    static func gotoPointTeam(_ team: MyTeamData?, from: UIViewController) {
        
        func openPointTeamVC() {
            guard let vc = instantiateViewController(storyboardName: .global, withIdentifier: "GlobalPointsViewController") as? GlobalPointsViewController else { return }
            vc.myTeam = team
            vc.hidesBottomBarWhenPushed = true
            from.navigationController?.pushViewController(vc, animated: true)
        }
        
        if from.presentedViewController != nil {
            from.dismiss(animated: false) {
                openPointTeamVC()
            }
        } else {
            openPointTeamVC()
        }
        
    }
    
    /// Add 1 player in specific position to statistic
    ///
    /// - Parameters:
    ///   - statistic: current statistic
    ///   - player: picked player
    /// - Returns: updated statistic
    static func upgradeStatistic(_ statistic: Statistic?, player: Player) -> Statistic? {
        guard let statistic = statistic else { return nil }
        
        var goalkeepers = statistic.goalkeeper ?? 0
        var defenders = statistic.defender ?? 0
        var midfielders = statistic.midfielder ?? 0
        var attackers = statistic.attacker ?? 0
        
        if let position = player.mainPosition {
            switch position {
            case PlayerPositionType.goalkeeper.rawValue:
                goalkeepers += 1
            case PlayerPositionType.defender.rawValue:
                defenders += 1
            case PlayerPositionType.midfielder.rawValue:
                midfielders += 1
            default:
                attackers += 1
            }
        }
        
        return Statistic(goalkeeper: goalkeepers, defender: defenders, midfielder: midfielders, attacker: attackers)
    }
    
    /// Remove 1 player in specific position to statistic
    ///
    /// - Parameters:
    ///   - statistic: current statistic
    ///   - player: removed player
    /// - Returns: updated statistic
    static func downgradeStatistic(_ statistic: Statistic?, player: Player) -> Statistic? {
        guard let statistic = statistic else { return nil }
        
        var goalkeepers = statistic.goalkeeper ?? 0
        var defenders = statistic.defender ?? 0
        var midfielders = statistic.midfielder ?? 0
        var attackers = statistic.attacker ?? 0
        
        if let position = player.mainPosition {
            switch position {
            case PlayerPositionType.goalkeeper.rawValue:
                goalkeepers -= 1
            case PlayerPositionType.defender.rawValue:
                defenders -= 1
            case PlayerPositionType.midfielder.rawValue:
                midfielders -= 1
            default:
                attackers -= 1
            }
        }
        
        return Statistic(goalkeeper: goalkeepers, defender: defenders, midfielder: midfielders, attacker: attackers)
    }
    
    static func getCheckboxFilters(_ seasons: [SeasonData], current: SeasonData?) -> [CheckBoxData] {
        var returnValue = [CheckBoxData]()
        if let current = current {
            seasons.forEach { season in
                if let id = season.id, let currentId = current.id {
                    let selected = id == currentId
                    if let data = VFantasyCommon.mapSeasonToCheckbox(season, selected) {
                        returnValue.append(data)
                    }
                }
            }
        } else {
            seasons.forEach { season in
                if let data = VFantasyCommon.mapSeasonToCheckbox(season, false) {
                    returnValue.append(data)
                }
            }
        }
        return returnValue
    }
    
    static func mapSeasonToCheckbox(_ season: SeasonData, _ selected: Bool) -> CheckBoxData? {
        if let id = season.id {
            return CheckBoxData(String(id), season.name ?? "", season.name ?? "", selected)
        }
        return nil
    }
    
    static func image(named: String) -> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(named: named, in: Bundle.sdkBundler(), with: nil)
        } else {
            return UIImage(named: named, in: Bundle.sdkBundler(), compatibleWith: nil)
        }
    }
    
    static func showAlertPickingPhoto(in topVC: UIViewController, _ completion: @escaping (_ action: PickingPhotoAction) -> Void) {
        let alertVC = UIAlertController(title: nil, message: "Choose Avatar".localiz(), preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Take Photo".localiz(), style: .destructive, handler: { _ in
            alertVC.dismiss(animated: true, completion: nil)
            completion(.camera)
        }))
        alertVC.addAction(UIAlertAction(title: "Choose Photo".localiz(), style: .default, handler: { _ in
            alertVC.dismiss(animated: true, completion: nil)
            completion(.photo)
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel".localiz(), style: .cancel, handler: { _ in
            alertVC.dismiss(animated: true, completion: nil)
            completion(.cancel)
        }))
        DispatchQueue.main.async {
            topVC.present(alertVC, animated: true, completion: nil)
        }
    }
}

extension UIFont {
    
    static func jbs_registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }
        
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }
        
        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }
        
        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }
        
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
    
}

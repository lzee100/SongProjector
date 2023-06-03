//
//  SheetActivitiesView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetActivitiesView: SheetView {
    
    @IBOutlet var sheetView: UIView!
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var descriptionTitle: UILabel!
    @IBOutlet var titleBackgroundView: UIView!
    @IBOutlet var activitiesContainerView: UIView!
    
    @IBOutlet var titleLeftConstraint: NSLayoutConstraint!
    @IBOutlet var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet var timeLabelRightConstraint: NSLayoutConstraint!
    
    @IBOutlet var containerLeftConstraint: NSLayoutConstraint!
    @IBOutlet var containerBottomContraint: NSLayoutConstraint!
    @IBOutlet var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet var containerRightConstraint: NSLayoutConstraint!
    @IBOutlet var titleHeightConstraint: NSLayoutConstraint!
    
    private var activities: [VGoogleActivity] = []
    
    override func customInit() {
        Bundle.main.loadNibNamed("SheetActivitiesView", owner: self, options: [:])
        sheetView.frame = self.frame
        sheetView.layoutIfNeeded()
        addSubview(sheetView)
    }
    
    override func update() {
        
        timeLabel.text = ""
        if isPreview {
            addPreviewActivities()
        } else {
//            let activities: [GoogleActivity] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "startDate", ascending: true))
//            self.activities = activities.map({ VGoogleActivity(activity: $0, context: moc) })
        }
        
        if let scaleFactor = scaleFactor {
            titleLeftConstraint.constant = titleLeftConstraint.constant  * scaleFactor
            titleTopConstraint.constant = titleTopConstraint.constant  * scaleFactor
            timeLabelRightConstraint.constant = timeLabelRightConstraint.constant  * scaleFactor
            containerTopConstraint.constant = containerTopConstraint.constant  * scaleFactor
            containerLeftConstraint.constant = containerLeftConstraint.constant  * scaleFactor
            containerBottomContraint.constant = containerBottomContraint.constant  * scaleFactor
            containerRightConstraint.constant = containerRightConstraint.constant  * scaleFactor
        }
        
        var fontName = ""
        if var attributes = sheetTheme?.getTitleAttributes(scaleFactor ?? 1), let font = attributes[.font] as? UIFont {
            fontName = font.fontName
            attributes[.font] = UIFont(name: fontName, size: (self.descriptionTitle.frame.height / 3) * (scaleFactor ?? 1))
            descriptionTitle.attributedText = NSAttributedString(string: sheet.title ?? "", attributes: attributes)
        } else {
            descriptionTitle.attributedText = NSAttributedString(string: sheet.title ?? "", attributes: sheetTheme?.getTitleAttributes(scaleFactor ?? 1))
        }
        titleHeightConstraint.constant = descriptionTitle.attributedText?.height(containerWidth: CGFloat.greatestFiniteMagnitude) ?? 30
        
        layoutIfNeeded()
        
        addActivities()
        
        updateBackgroundImage()
        
        if let backgroundColor = sheetTheme?.sheetBackgroundColor, sheetTheme?.backgroundImage == nil {
            self.backgroundView.backgroundColor = backgroundColor
        } else {
            self.backgroundView.backgroundColor = .whiteColor
        }
    }
    
    private func addPreviewActivities() {
        activities = []
        var index: Double = 0
        while index < 8 {
            let activity = VGoogleActivity()
            activity.deleteDate = NSDate()
            activity.startDate = Date().addingTimeInterval(.days(index * 3)) as NSDate
            activity.eventDescription = AppText.ActivitySheet.previewDescription
            index += 1
            activities.append(activity)
        }
    }
    
    private func addActivities() {
        
        let thisWeekDaysLeft: Int
        switch Date().dayOfWeek {
        case 1: thisWeekDaysLeft = 0
        case 2: thisWeekDaysLeft = 6
        case 3: thisWeekDaysLeft = 5
        case 4: thisWeekDaysLeft = 4
        case 5: thisWeekDaysLeft = 3
        case 6: thisWeekDaysLeft = 2
        case 7: thisWeekDaysLeft = 1
        default: thisWeekDaysLeft = 0
        }
        
        
        let thisWeekEnd = Date().dateEndOfDay.dateByAddingDays(thisWeekDaysLeft)
        let thisWeek = activities.filter({ (($0.startDate as Date?)?.isAfter(Date()) ?? false) && (($0.startDate as Date?)?.isBefore(thisWeekEnd) ?? false) })
        
        let nextWeekDaysToMonday: Int
        switch Date().dayOfWeek {
        case 1: nextWeekDaysToMonday = 1
        case 2: nextWeekDaysToMonday = 0
        case 3: nextWeekDaysToMonday = 6
        case 4: nextWeekDaysToMonday = 5
        case 5: nextWeekDaysToMonday = 4
        case 6: nextWeekDaysToMonday = 3
        case 7: nextWeekDaysToMonday = 2
        default: nextWeekDaysToMonday = 0
        }
        
        let nextWeekBegin = Date().dateByAddingDays(nextWeekDaysToMonday).dateMidnight
        let nextWeekEnd = nextWeekBegin.dateByAddingDays(7)
        let nextWeek = activities.filter({ (($0.startDate as Date?)?.isAfter(nextWeekBegin) ?? false) && (($0.startDate as Date?)?.isBefore(nextWeekEnd) ?? false) })
        
        for subview in activitiesContainerView.subviews {
            subview.removeFromSuperview()
        }
        
        // NO ACTIVITIES
        if activities.count == 0 {
            
            // add HEADER
            let frameHeader = CGRect(x: 0, y: 0, width: activitiesContainerView.bounds.width, height: activitiesContainerView.bounds.height / 10)
            let headerThisWeek = ActivityHeader.createWith(frame: frameHeader, theme: sheetTheme, title: AppText.ActivitySheet.titleUpcomingTime, scaleFactor: scaleFactor)
            activitiesContainerView.addSubview(headerThisWeek)
            
            // add ACTIVITY THIS WEEK
            let frame = CGRect(x: 0, y: activitiesContainerView.bounds.height / 10, width: activitiesContainerView.bounds.width, height: activitiesContainerView.bounds.height / 12)
            let activityView = ActivityView.createWith(frame: frame, theme: sheetTheme, activity: nil, scaleFactor: (scaleFactor ?? 1))
            activitiesContainerView.addSubview(activityView)
            
            return
        }
        
        let stackview = UIStackView(frame: .zero)
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.distribution = .fill
        stackview.alignment = .leading
        stackview.axis = .vertical
        stackview.spacing = 0
        activitiesContainerView.addSubview(stackview)
        
        NSLayoutConstraint.activate([
            stackview.topAnchor.constraint(equalTo: activitiesContainerView.topAnchor),
            stackview.leadingAnchor.constraint(equalTo: activitiesContainerView.leadingAnchor),
            stackview.trailingAnchor.constraint(equalTo: activitiesContainerView.trailingAnchor),
        ])
        
        let upcoming = activities.filter({ (($0.startDate as Date?)?.isAfter(nextWeekEnd) ?? false) })
        
        let hasHeaderThisWeek = thisWeek.count > 0
        let hasHeaderNextWeek = nextWeek.count > 0
        let hasHeaderUpcoming = upcoming.count > 0
        
        if hasHeaderThisWeek {
            buildIn(stackview: stackview, forHeader: AppText.ActivitySheet.titleThisWeek, activities: thisWeek, isFirst: true)
        }
        
        if stackview.bounds.height <= activitiesContainerView.bounds.height, hasHeaderNextWeek {
            buildIn(stackview: stackview, forHeader: AppText.ActivitySheet.titleNextWeek, activities: nextWeek)
        }
        if stackview.bounds.height <= activitiesContainerView.bounds.height, hasHeaderUpcoming {
            buildIn(stackview: stackview, forHeader: AppText.ActivitySheet.titleUpcomingTime, activities: upcoming)
        }
        
    }
    
    private func buildIn(stackview: UIStackView, forHeader: String, activities: [VGoogleActivity], isFirst: Bool = false) {
        
        if !isFirst {
            let spacer = UIView(frame: .zero)
            spacer.backgroundColor = .blue
            spacer.heightAnchor.constraint(equalToConstant: 5 * (scaleFactor ?? 1)).isActive = true
            stackview.addArrangedSubview(spacer)
        }
        
        // build header
        let header = UILabel(frame: .zero)
        var attr = sheetTheme?.getTitleAttributes(scaleFactor ?? 1) ?? [:]
        let font = attr[.font] as? UIFont
        attr[.font] = UIFont(name: font?.fontName ?? "Avenir-Book", size: 8 * (scaleFactor ?? 1))
        header.attributedText = NSAttributedString(string: forHeader, attributes: attr)
        stackview.addArrangedSubview(header)
        
        // build activities
        
        func styleStackView(view: UIStackView) {
            view.distribution = .fill
            view.alignment = .leading
            view.axis = .horizontal
            view.spacing = 8 * (scaleFactor ?? 1)
        }
                    
        var views: [UIStackView] = activities.map { activity in
            let hStack = UIStackView(frame: .zero)
            styleStackView(view: hStack)
            let dateString = activity.dateString
            let activityDescription = activity.eventDescription ?? AppText.ActivitySheet.descriptionNoActivities
            
            let dateLabel = UILabel(frame: .zero)
            
            var attributes = sheetTheme?.getLyricsAttributes(scaleFactor ?? 1) ?? [:]
            let font = attributes[.font] as? UIFont
            attributes[.font] = UIFont(name: font?.fontName ?? "Avenir-Book", size: 5 * (scaleFactor ?? 1))
            dateLabel.attributedText = NSAttributedString(string: dateString, attributes: attributes)
            let activityDescriptionLabel = UILabel(frame: .zero)
            activityDescriptionLabel.attributedText = NSAttributedString(string: activityDescription, attributes: attributes)

            hStack.addArrangedSubview(dateLabel)
            hStack.addArrangedSubview(activityDescriptionLabel)
            
            return hStack
        }
        
        repeat {
            if let view = views.first {
                stackview.addArrangedSubview(view)
                views.removeFirst()
            }
            stackview.layoutIfNeeded()
        } while views.count > 0 && (stackview.bounds.height <= activitiesContainerView.bounds.height)

    }
    
    override func updateOpacity() {
        if let alpha = sheetTheme?.backgroundTransparancy, alpha != 1 {
            if sheetTheme?.backgroundImage != nil {
                backgroundImageView.alpha = CGFloat(alpha)
                backgroundView.alpha = 1
            } else {
                backgroundImageView.alpha = 0
                backgroundView.alpha = CGFloat(alpha)
            }
        }
    }
    
    override func updateBackgroundImage() {
        if let image = isForExternalDispay ? sheetTheme?.backgroundImage : sheetTheme?.thumbnail {
            backgroundImageView.isHidden = false
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.image = image
            if let backgroundTransparency = sheetTheme?.backgroundTransparancy {
                backgroundImageView.alpha = CGFloat(backgroundTransparency)
            }
        } else {
            backgroundImageView.isHidden = true
        }
    }
    
    override func updateTime(isOn: Bool) {
        
        let test = Date().time
        if !isOn {
            timeLabel.text = ""
            return
        }
        
        if let theme = sheetTheme, let scaleFactor = scaleFactor { // is custom sheet
            
            timeLabel.attributedText = NSAttributedString(string: test, attributes: theme.getTitleAttributes(scaleFactor))
            
        } else {
            timeLabel.text = test
        }
        
    }
    
    override func updateTitle() {
        let sheet = self.sheet as! VSheetActivities
        if let songTitle = sheet.title {
            if let theme = sheetTheme {
                descriptionTitle.attributedText = NSAttributedString(string: songTitle, attributes: theme.getTitleAttributes(scaleFactor ?? 0))
            } else {
                descriptionTitle.text = ""
            }
        }
        self.setNeedsLayout()
    }
    
    override func updateContent() {
        if let theme = sheetTheme {
            activitiesContainerView.subviews.compactMap({ $0 as? ActivityView }).compactMap({ $0.descriptionTime }).forEach({ $0.attributedText = NSAttributedString(string: $0.text ?? "", attributes: theme.getLyricsAttributes(scaleFactor ?? 1)) })
            activitiesContainerView.subviews.compactMap({ $0 as? ActivityView }).compactMap({ $0.descriptionActivity }).forEach({ $0.attributedText = NSAttributedString(string: $0.text ?? "", attributes: theme.getLyricsAttributes(scaleFactor ?? 1)) })
            activitiesContainerView.subviews.compactMap({ $0 as? ActivityHeader }).compactMap({ $0.descriptionTitle }).forEach({ $0.attributedText = NSAttributedString(string: $0.text ?? "", attributes: theme.getLyricsAttributes(scaleFactor ?? 1)) })
        }
    }
    
    override func updateBackgroundColor() {
        if let backgroundColor = sheetTheme?.sheetBackgroundColor {
            self.backgroundView.backgroundColor = backgroundColor
        } else {
            self.backgroundView.backgroundColor = .white
        }
    }
    
}

extension VGoogleActivity {
    var dateString: String {
        if let date = startDate {
            return (date as Date).toString
        } else {
            return AppText.ActivitySheet.dayActivity
        }
    }
}


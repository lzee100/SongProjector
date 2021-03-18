//
//  BibleIndex.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation

let BibleIndex = BibleIndexx()

class BibleIndexx {
	private var searchText: String?
	
	init() {
	}
	
	init(searchText: String?){
		self.searchText = searchText
	}
	
	func isExisting() -> Bool {
		return parse(searchRequest: searchText, returnScripture: false).1 != nil
	}
	
	func getFullName() -> String? {
		return parse(searchRequest: searchText, returnScripture: false).1
	}
	
	
	private enum Book: String {
		case Genesis
		case Exodus
		case Leviticus
		case Numeri
		case Deuteronomium
		case Jozua
		case Richteren
		case Ruth
		case Samuël
		case Koningen
		case Ezra
		case Nehemia
		case Ester
		case Job
		case Psalmen
		case Spreuken
		case Prediker
		case Hooglied
		case Jesaja
		case Jeremia
		case Klaagliederen
		case Ezechiël
		case Daniël
		case Hosea
		case Joël
		case Amos
		case Obadja
		case Jona
		case Micha
		case Nahum
		case Habakuk
		case Sefanja
		case Haggai
		case Zacharia
		case Maleachi
		case Matteüs
		case Marcus
		case Lucas
		case Johannes
		case Handelingen
		case Romeinen
		case Korintiërs
		case Galaten
		case Efeziërs
		case Filippenzen
		case Kolossenzen
		case Tessalonicenzen
		case Timoteüs
		case Titus
		case Filemon
		case Hebreeën
		case Jakobus
		case Petrus
		case Judas
		case Openbaringen
		
		static let all = [Genesis, Exodus, Leviticus, Numeri, Deuteronomium, Jozua, Richteren, Ruth, Samuël, Koningen, Ezra, Nehemia, Ester, Job, Psalmen, Spreuken, Prediker, Hooglied, Jesaja, Jeremia, Klaagliederen, Ezechiël, Daniël, Hosea, Joël, Amos, Obadja, Jona, Micha, Nahum, Habakuk, Sefanja, Haggai, Zacharia, Maleachi, Matteüs, Marcus, Lucas, Johannes, Handelingen, Romeinen, Korintiërs, Galaten, Efeziërs, Filippenzen, Kolossenzen, Tessalonicenzen, Timoteüs, Titus, Filemon, Hebreeën, Jakobus, Petrus, Judas, Openbaringen]
		
		static let searchIndex: [(Book, [String])] = [
			(.Genesis, ["Genesis", "Gen"]),
			(.Exodus, ["Exodus", "Exo"]),
			(.Leviticus, ["Leviticus", "Lev"]),
			(.Numeri, ["Numeri", "Num", "Nummeri", "Nummerie", "Numerri", "Nummerrie"]),
			(.Deuteronomium, ["Deuteronomium", "Deut", "Deutoronomium", "Deu", "Deutr"]),
			(.Jozua, ["Leviticus", "Lev"]),
			(.Richteren, ["Richteren", "Rigteren", "Rich", "Richt", "Rigt"]),
			(.Ruth, ["Ruth"]),
			(.Samuël, ["Samuël", "Sam", "Samuel"]),
			(.Koningen, ["Koningen", "Kon", "Koning"]),
			(.Ezra, ["Ezra", "Esra"]),
			(.Nehemia, ["Nehemia", "Neh"]),
			(.Ester, ["Ester", "Esther", "Ezter", "Ezther"]),
			(.Job, ["Job", "Jop"]),
			(.Psalmen, ["Psalmen", "Psalm", "Psa"]),
			(.Spreuken, ["Spreuken", "Spreu"]),
			(.Prediker, ["Prediker", "Pred"]),
			(.Hooglied, ["Hooglied", "Hoog"]),
			(.Jesaja, ["Jesaja", "Jes", "Jez", "Jezaja"]),
			(.Jeremia, ["Jeremia", "Jer"]),
			(.Klaagliederen, ["Klaagliederen", "Klaag", "Klaaglied"]),
			(.Ezechiël, ["Ezechiël", "Eze", "Ezechiel", "Ezegiel", "Ezegiël"]),
			(.Daniël, ["Daniël", "Dan", "Daniel"]),
			(.Hosea, ["Hosea", "Hos"]),
			(.Joël, ["Joël", "Joel"]),
			(.Amos, ["Amos"]),
			(.Obadja, ["Obadja", "Obad", "Oba", "Obod", "Obodja"]),
			(.Jona, ["Jona"]),
			(.Micha, ["Micha", "Mich", "Mic", "Miga"]),
			(.Nahum, ["Nahum", "Nah"]),
			(.Habakuk, ["Habakuk", "Hab", "Habakkuk", "Habbakuk", "Habbbakkuk"]),
			(.Sefanja, ["Sefanja", "Sef", "Sevanja", "Sev"]),
			(.Haggai, ["Haggai", "Hag", "Hagg"]),
			(.Zacharia, ["Zacharia", "Zach", "Zacha"]),
			(.Maleachi, ["Maleachi", "Mal", "Maliachi", "Maleagi"]),
			(.Matteüs, ["Matteüs", "Matt", "Mat", "Matteus", "Mattheus", "Mattheüs"]),
			(.Marcus, ["Marcus", "Marc", "Markus", "Mark"]),
			(.Lucas, ["Lucas", "Luc", "Luk", "Lukas"]),
			(.Johannes, ["Johannes", "Joh", "Jho", "Johan", "Johanes"]),
			(.Handelingen, ["Handelingen", "Hand", "Han"]),
			(.Romeinen, ["Romeinen", "Rom", "Romijnen", "Romij"]),
			(.Korintiërs, ["Korintiërs", "Kor", "Cor", "Corintiërs", "Corintiers", "Korinte"]),
			(.Galaten, ["Galaten", "Gal", "Galate"]),
			(.Efeziërs, ["Efeziërs", "Efe", "Ef", "Efeziers", "Efezië", "Efezie"]),
			(.Filippenzen, ["Filippenzen", "Fil", "Phil", "Filli", "Fillippenzen", "Philippenzen", "Philipenzen", "Filipensen", "Fillipensen", "Filippensen"]),
			(.Kolossenzen, ["Kolossenzen", "Kol", "Kollossenzen", "Kollosenzen", "Kolosenzen"]),
			(.Tessalonicenzen, ["Tessalonicenzen", "Tess", "Tes", "Tesallonicenzen", "Tessallonicenzen", "Tessalonisenzen", "Tessallonisenzen"]),
			(.Timoteüs, ["Timoteüs", "Tim", "Timo", "Timotius", "Timothius", "Timoteus"]),
			(.Titus, ["Titus", "Tit", "Tites"]),
			(.Filemon, ["Filemon", "File"]),
			(.Hebreeën, ["Hebreeën", "Heb", "Hebr", "Hebreeen", "Hebreën", "Hebreeun"]),
			(.Jakobus, ["Jakobus", "Jak", "Jacobus", "Jacob", "Jako"]),
			(.Petrus, ["Petrus", "Pet", "Petr"]),
			(.Judas, ["Judas", "Jud"]),
			(.Openbaringen, ["Openbaringen", "Open", "Ope", "Openb"])
		]
		
		static func searchIn(chapter: Book) -> [String]? {
            if searchIndex.first(where: { (searchIndex) -> Bool in
                searchIndex.0 == chapter
            }) != nil {
			} else {
				print("does not contain")
			}
			return searchIndex.first(where: { (searchIndex) -> Bool in
				searchIndex.0 == chapter
			})?.1
		}
	}
	
	private func parse(searchRequest: String?, returnScripture: Bool) -> ([Vers]?, String?) {
		
//		if let searchRequest = searchRequest, searchRequest.count > 0 {
//
//			var bookNumber = ""
//			var bookName = ""
//			var bookChapter = ""
//			var vers = ""
//
//			var searchText = searchRequest.trimmingCharacters(in: .whitespacesAndNewlines)
//
//			// get BOOKNUMBER
//			var index = 0
//			while searchText[0].isNumber {
//				bookNumber += searchText[index]
//				searchText.remove(at: searchText.startIndex)
//			}
//
//			searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
//			searchText = searchText.capitalized
//
//			index = 0
//			while !searchText[index].isNumber {
//				index += 1
//				if index > 100 {
//					return (nil, nil)
//				}
//			}
//
//			var chapterString = String(searchText.prefix(index)).trimmingCharacters(in: .whitespacesAndNewlines)
//			chapterString = chapterString.trimmingCharacters(in: .whitespacesAndNewlines)
//			if let point = chapterString.range(of: ".") {
//				chapterString.removeSubrange(point)
//			}
//
//			if chapterString.count < 3 {
//				return (nil, nil)
//			}
//
//			index = 0
//			while index < chapterString.count {
//				if !chapterString[index].lowercased().isLetter {
//					return (nil, nil)
//				}
//				index += 1
//				if index > 100 {
//					return (nil, nil)
//				}
//			}
//
//			var found = false
//			for chapter in Book.all {
//				if let searchIndex = Book.searchIn(chapter: chapter) {
//					if searchIndex.contains(chapterString) {
//						bookName = chapter.rawValue
//						found = true
//						if let index = searchIndex.index(of: chapterString) {
//							let strToRemove = searchIndex[index]
//							if let searchIndex = searchText.range(of: strToRemove) {
//								searchText.removeSubrange(searchIndex)
//							}
//						}
//						break
//					}
//				}else {
//					return (nil, nil)
//				}
//			}
//
//			if !found {
//				return (nil, nil)
//			}
//
//			searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
//			if let point = searchText.range(of: ".") {
//			searchText.removeSubrange(point)
//			}
//
//			// get verses (this only gets the last remainder (4-10 AX), not search verses as 4 till 10
//			if let strIndex = searchText.index(of: ":") {
//				bookChapter = String(searchText.prefix(strIndex.encodedOffset)).trimmingCharacters(in: .whitespacesAndNewlines)
//				let nextIndex = searchText.index(strIndex, offsetBy: 1)
//				vers = String(searchText.suffix(from: nextIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
//			} else if let strIndex = searchText.range(of: "vers", options: [], range: nil, locale: nil){
//				bookChapter = String(searchText.prefix(strIndex.lowerBound.encodedOffset)).trimmingCharacters(in: .whitespacesAndNewlines)
//				vers = String(searchText.suffix(from: strIndex.upperBound)).trimmingCharacters(in: .whitespacesAndNewlines)
//			} else if let strIndex = searchText.range(of: "Vers", options: [], range: nil, locale: nil){
//				bookChapter = String(searchText.prefix(strIndex.lowerBound.encodedOffset)).trimmingCharacters(in: .whitespacesAndNewlines)
//				vers = String(searchText.suffix(from: strIndex.upperBound)).trimmingCharacters(in: .whitespacesAndNewlines)
//			} else {
//				return (nil, nil)
//			}
//
//
//			var versStart = ""
//			if let strIndex = vers.index(of: "-") {
//				let nextIndex = vers.index(strIndex, offsetBy: 0)
//				versStart = String(vers.prefix(upTo: nextIndex).trimmingCharacters(in: .whitespacesAndNewlines))
//			} else {
//				versStart = vers
//			}
//
//			var versEnd = ""
//			if let strIndex = vers.index(of: "-") {
//				let nextIndex = vers.index(strIndex, offsetBy: 1)
//				versEnd = String(vers.suffix(from: nextIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
//			}
//
//			if versEnd != "" {
//                let chapter: Chapter? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: bookChapter)])
//				if let verses = chapter?.hasVerses?.allObjects as? [Vers] {
//					if verses.filter({ $0.number == Int16(versEnd) }).count == 0 {
//						return (nil, nil)
//					}
//				} else {
//					return (nil, nil)
//				}
//			}
//
//			var versRange: [Int] = []
//
//			let versNumberToUse = Int(versEnd) == nil ? 0 : (Int(versStart) ?? 0)
//			let numberOfVerses = (Int(versEnd) ?? 0 + 1) -  versNumberToUse
//
//			guard numberOfVerses > 0 else {
//				return (nil, nil)
//			}
//
//			if numberOfVerses == 1 {
//				versRange.append(Int(versStart) ?? 1)
//			} else {
//				for value in 0...numberOfVerses {
//					versRange.append((Int(versStart) ?? 0) + value)
//				}
//			}
//
//			if returnScripture {
//				CoreChapter.predicates.append("hasBook.name", equals: bookName)
//				CoreChapter.predicates.append("number", equals: bookChapter)
//
//
//				if let text = (CoreChapter.getEntities().first?.hasVerses?.allObjects as? [Vers]) {
//
//					var resultText = text.filter({
//						versRange.contains(Int($0.number))
//					})
//					resultText = resultText.sorted(by: { $0.number < $1.number })
//					return (resultText, nil)
//
//				} else {
//					return (nil, nil)
//				}
//				//
//			} else {
//				return (nil, bookNumber + " " + bookName + " " + bookChapter + ":" + vers)
//			}
//
//		} else {
//			return (nil, nil)
//		}
        return (nil, nil)
	}
	
	public func getBookFor(index: Int) -> String {
		return Book.all[index].rawValue
	}
	
	public func getVersesFor(searchValue: String) -> ([Vers]?, Int) {
		if let verses = parse(searchRequest: searchValue, returnScripture: true).0 {
			var lenght = 0
			let allLengths = verses.compactMap{ $0.text?.length }
			allLengths.forEach{ lenght += $0 }
			return (verses, lenght)
		} else {
			return (nil, 0)
		}
	}
	
}

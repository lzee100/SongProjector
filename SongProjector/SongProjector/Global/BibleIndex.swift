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
		return parse(searchRequest: searchText) != nil
	}
	
	func getFullName() -> String? {
		return parse(searchRequest: searchText)
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
			if let result = searchIndex.first(where: { (searchIndex) -> Bool in
				searchIndex.0 == chapter
			}) {
			} else {
				print("does not contain")
			}
			return searchIndex.first(where: { (searchIndex) -> Bool in
				searchIndex.0 == chapter
			})?.1
		}
	}
	
	private func parse(searchRequest: String?, returnScripture: Bool) -> String? {
		
		if let searchRequest = searchRequest, searchRequest.count > 0 {
			
			var bookNumber = ""
			var bookName = ""
			var bookChapter = ""
			var vers = ""
		
			var searchText = searchRequest.trimmingCharacters(in: .whitespacesAndNewlines)
			
			// get BOOKNUMBER
			var index = 0
			while searchText[0].isNumber {
				bookNumber += searchText[index]
				searchText.remove(at: searchText.startIndex)
			}
			
			searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
			searchText = searchText.capitalized
			
			index = 0
			while !searchText[index].isNumber {
				index += 1
				if index > 100 {
					return nil
				}
			}
			
			var chapterString = String(searchText.prefix(index)).trimmingCharacters(in: .whitespacesAndNewlines)
			chapterString = chapterString.trimmingCharacters(in: .whitespacesAndNewlines)
			if let point = chapterString.range(of: ".") {
				chapterString.removeSubrange(point)
			}
			
			if chapterString.count < 3 {
				return nil
			}
			
			index = 0
			while index < chapterString.count {
				if !chapterString[index].lowercased().isLetter {
					return nil
				}
				index += 1
				if index > 100 {
					return nil
				}
			}
			
			var found = false
			for chapter in Book.all {
				if let searchIndex = Book.searchIn(chapter: chapter) {
					if searchIndex.contains(chapterString) {
						bookName = chapter.rawValue
						found = true
						if let index = searchIndex.index(of: chapterString) {
							let strToRemove = searchIndex[index]
							if let searchIndex = searchText.range(of: strToRemove) {
								searchText.removeSubrange(searchIndex)
							}
						}
						break
					}
				}else {
					return nil
				}
			}
			
			if !found {
				return nil
			}
			
			searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
			if let point = searchText.range(of: ".") {
			searchText.removeSubrange(point)
			}
			
			// get verses (this only gets the last remainder (4-10 AX), not search verses as 4 till 10
			if let strIndex = searchText.index(of: ":") {
				bookChapter = String(searchText.prefix(strIndex.encodedOffset)).trimmingCharacters(in: .whitespacesAndNewlines)
				let nextIndex = searchText.index(strIndex, offsetBy: 1)
				vers = String(searchText.suffix(from: nextIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
			} else if let strIndex = searchText.range(of: "vers", options: [], range: nil, locale: nil){
				bookChapter = String(searchText.prefix(strIndex.lowerBound.encodedOffset)).trimmingCharacters(in: .whitespacesAndNewlines)
				vers = String(searchText.suffix(from: strIndex.upperBound)).trimmingCharacters(in: .whitespacesAndNewlines)
			} else if let strIndex = searchText.range(of: "Vers", options: [], range: nil, locale: nil){
				bookChapter = String(searchText.prefix(strIndex.lowerBound.encodedOffset)).trimmingCharacters(in: .whitespacesAndNewlines)
				vers = String(searchText.suffix(from: strIndex.upperBound)).trimmingCharacters(in: .whitespacesAndNewlines)
			} else {
				return nil
			}
			
			if returnScripture {
				CoreVers
				//
			} else {
				return bookNumber + " " + bookName + " " + bookChapter + ":" + vers
			}

		} else {
			return nil
		}
	}
	
	public func getBookFor(index: Int) -> String {
		return Book.all[index].rawValue
	}
	
	public func getBibleTextFor(searchValue: String) -> String {
		
		
		
	}
	
}

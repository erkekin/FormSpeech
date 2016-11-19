//
//  FormSpeech.swift
//  FormSpeech
//
//  Created by Erk Ekin on 16/11/2016.
//  Copyright © 2016 Erk Ekin. All rights reserved.
//

import Foundation

typealias Pair = [Field:String]
protocol Iteratable {}

protocol FormSpeechDelegate {
    
    func valueParsed(parser: Parser, forValue value:String, andKey key:Field)
    
}

class Parser {
    
    var delegate:FormSpeechDelegate?
    
    let words = Field.rawValues()
    var iteration = 0
    var text = ""{
        
        didSet{
            
            let secondIndex = iteration + 1
          
            let secondWord:String? = secondIndex == words.count ? nil: words[secondIndex]
            let first = words[iteration]
            let second = secondWord
     
            if let value = text.getSubstring(substring1: first, substring2: second),
                
                let key = Field(rawValue: first){
                let value = value.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                iteration += secondIndex == words.count ? 0 : 1
                delegate?.valueParsed(parser: self, forValue: value, andKey: key)
                
            }
            
        }
    }
    
}


extension RawRepresentable where Self: RawRepresentable {
    
    static func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) {
                $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
            }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
}

extension Iteratable where Self: RawRepresentable, Self: Hashable {
    
    static func hashValues() -> AnyIterator<Self> {
        return iterateEnum(self)
    }
    
    static func rawValues() -> [Self.RawValue] {
        return hashValues().map({$0.rawValue})
    }
}

extension String{
    
    func getSubstring(substring1: String, substring2:String?) -> String?{
        
        guard let range1 = self.range(of: substring1) else{return nil}
        
        let lo = self.index(range1.upperBound, offsetBy: 0)
        
        if let sub = substring2 {
            
            if let range2 = self.range(of: sub){
                let hi = self.index(range2.lowerBound, offsetBy: 0)
                let subRange = lo ..< hi
                return self[subRange]
            }else{
                return nil
            }
        }else {
            
            let hi = self.endIndex
            let subRange = lo ..< hi
            return self[subRange]
        }
    }
    
//    func parse() -> Pair?{ need for a full sentence parse.
//        
//        let words = Field.rawValues()
//        var output:Pair = [:]
//        
//        for (index, word) in words.enumerated() {
//            
//            let secondIndex = index + 1
//            let secondWord:String? = secondIndex == words.count ? nil: words[secondIndex]
//            
//            if let value = getSubstring(substring1: word, substring2: secondWord),
//                let key = Field(rawValue: word){
//                
//                output[key] = value.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
//                
//            }else {
//                return nil
//            }
//        }
//        
//        return output.count == 0 ? nil:output
//        
//    }
    
}


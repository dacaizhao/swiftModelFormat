//
//  SourceEditorCommand.swift
//  ModelFormat
//
//  Created by point on 2016/12/3.
//  Copyright © 2016年 dacai. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    var start:Int = 0
    var len:Int = 0
    
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        //获取选中的行
        if invocation.buffer.selections.count != 0 {
            let firstObject:XCSourceTextRange = invocation.buffer.selections.firstObject as! XCSourceTextRange;
            start = firstObject.start.line
            len = firstObject.end.line - start + 1
        }
        
        
        
        for lineIndex in start..<start+len {
            let line:String = invocation.buffer.lines[lineIndex] as! String
            var type:String = "String"
            do {
                let pattern = "\".*?\""
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let dacaiRange = NSMakeRange(0, line.characters.count)
                
                //匹配到的个数
                let  resa = regex.numberOfMatches(in: line, options: [], range: dacaiRange)
                if resa > 0 {
                    //匹配第一个结果集
                    guard let resb = regex.firstMatch(in: line, options: [], range: dacaiRange) else {
                        return
                    }
                    
                    //取得值
                    if line.contains(":") {
                        let arr = line.components(separatedBy: ":")
                        var value = arr[1]
                        value = String(value.characters.filter { $0 != " " })
                        value = String(value.characters.filter { $0 != "," })
                        value = String(value.characters.filter { $0 != "\n" })
                        
                        if isNum(str: value) {
                            type = "Int"
                        }
                    }
                    
                    let newStr:String =  (line as NSString).substring(with: resb.range) as String
                    var res = String(newStr.characters.filter { $0 != "\"" })
                    if type == "Int" {
                        res  = " var " + res + " : " + type + " = 0"
                    } else {
                        res  = " var " + res + " : " + type + " = \"\""
                    }
                    
                    invocation.buffer.lines[lineIndex] = res
                }
                
                
            }
            catch {}
        }
        
        for _ in start..<start+len {
            invocation.buffer.lines.insert( "//属性:", at: start)
            start = start+2
        }
        completionHandler(nil)
    }
    
    
    func isNum(str:String) -> Bool {
        
        if str.characters.count == 0 {
            return false
        }
        do {
            let pattern = "^[0-9]*$"
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let dacaiRange = NSMakeRange(0, str.characters.count)
            let  resa = regex.numberOfMatches(in: str, options: [], range: dacaiRange)
            if resa>0 {
                return true
            }else{
                return false
            }
        }catch {
            return false
        }
        
    }
    
}

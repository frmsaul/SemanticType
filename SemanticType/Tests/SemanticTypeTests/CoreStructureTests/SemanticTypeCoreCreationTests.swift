//
//  SemanticTypeCoreCreationTests.swift
//  
//
//  Created by Atai Barkai on 8/13/19.
//

import XCTest
@testable import SemanticType

final class SemanticTypeCoreCreationTests: XCTestCase {
    
    
    func testModificationlessErrorlessCreation() {
        enum Encrypted_Spec: SemanticTypeSpec {
            typealias BackingPrimitiveWithValueSemantics = Data
            typealias Error = Never
            
            static func gatewayMap(preMap: String) -> Result<String, Never> {
                return .success(preMap.lowercased())
            }
        }
//        typealias CaselessString = SemanticType<CaselessString_Spec>

    }

    func testErrorlessValueModifyingCreation() {
        enum CaselessString_Spec: SemanticTypeSpec {
            typealias BackingPrimitiveWithValueSemantics = String
            typealias Error = Never
            
            static func gatewayMap(preMap: String) -> Result<String, Never> {
                return .success(preMap.lowercased())
            }
        }
        typealias CaselessString = SemanticType<CaselessString_Spec>

        let str1: CaselessString = CaselessString.create("HeLlo, WorLD.").get()
        XCTAssertEqual(str1._backingPrimitiveProxy, "hello, world.")
        
        let str2: CaselessString = CaselessString.create("Why would Jerry BRING anything?").get()
        XCTAssertEqual(str2._backingPrimitiveProxy, "why would jerry bring anything?")
        
        let str3: CaselessString = CaselessString.create("Why would JERRY bring anything?").get()
        XCTAssertEqual(str3._backingPrimitiveProxy, "why would jerry bring anything?")

        let str4: CaselessString = CaselessString.create("Yo-Yo Ma").get()
        XCTAssertEqual(str4._backingPrimitiveProxy, "yo-yo ma")
    }
    
    func testErrorfullCreation() {
        enum StringlessString_Spec: SemanticTypeSpec {
            typealias BackingPrimitiveWithValueSemantics = String
            enum Error: Swift.Error {
                case containsStringValues
            }
            
            static func gatewayMap(preMap: String) -> Result<String, Error> {
                return .failure(.containsStringValues)
            }
        }
        typealias StringlessString = SemanticType<StringlessString_Spec>
        
        

    }
    
    static var allTests = [
        ("testErrorlessValueModifyingCreation", testErrorlessValueModifyingCreation),
    ]
}


func mapVariant<T>(
    ofMutatingClosure mutation: @escaping (inout T) -> ()
) -> (T) -> T {
    return { input in
        var mutableInput = input
        mutation(&mutableInput)
        return mutableInput
    }
}

func mapVariant<T>(
    ofMutatingClosure mutation: @escaping (inout T) throws -> ()
) -> (T) throws -> T {
    return { input in
        var mutableInput = input
        try mutation(&mutableInput)
        return mutableInput
    }
}

func executeWithMutation<Variable, Output>(
    mapTaker: ((Variable) -> Variable) -> Output,
    mutatingVariant: (inout Variable) -> ()
) -> Output {
    return withoutActuallyEscaping(mutatingVariant) { mutatingVariant in
        let map = mapVariant(ofMutatingClosure: mutatingVariant)
        return mapTaker(map)
    }
}

func throwingExecuteWithMutation<Variable, Output>(
    mapTaker: ((Variable) throws -> Variable) throws -> Output,
    mutatingVariant: (inout Variable) throws -> ()
) rethrows -> Output {
    return try withoutActuallyEscaping(mutatingVariant) { mutatingVariant in
        let map = mapVariant(ofMutatingClosure: mutatingVariant)
        return try mapTaker(map)
    }
}

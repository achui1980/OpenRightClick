//
//  OfficeTemplateGenerator.swift
//  OpenRightClickExtension
//

import Foundation

/// Generates minimal valid Office Open XML files (.docx, .xlsx, .pptx)
/// using pre-built ZIP data embedded as base64 strings.
/// This avoids using Process/NSTask which is forbidden in App Sandbox.
enum OfficeTemplateGenerator {
    
    // MARK: - Public
    
    static func createMinimalDocx(at url: URL) throws {
        guard let data = Data(base64Encoded: Self.docxBase64) else {
            throw TemplateError.invalidBase64
        }
        try data.write(to: url)
    }
    
    static func createMinimalXlsx(at url: URL) throws {
        guard let data = Data(base64Encoded: Self.xlsxBase64) else {
            throw TemplateError.invalidBase64
        }
        try data.write(to: url)
    }
    
    static func createMinimalPptx(at url: URL) throws {
        guard let data = Data(base64Encoded: Self.pptxBase64) else {
            throw TemplateError.invalidBase64
        }
        try data.write(to: url)
    }
    
    // MARK: - Error
    
    enum TemplateError: Error, LocalizedError {
        case invalidBase64
        
        var errorDescription: String? {
            "Failed to decode embedded Office template data"
        }
    }
    
    // MARK: - Embedded Templates (minimal valid Office Open XML ZIP archives)
    
    // Minimal .docx — 1138 bytes
    // Contains: [Content_Types].xml, _rels/.rels, word/document.xml, word/_rels/document.xml.rels
    private static let docxBase64 = """
    UEsDBBQAAAAIAMFlaFx5bjPX6AAAAK0BAAATAAAAW0NvbnRlbnRfVHlwZXNdLnhtbH1QyU7DMBD9\
    FWuuKHHggBCK0wPLETiUDxjZk8SqN3nc0v49Tlt6QIXjzFv1+tXeO7GjzDYGBbdtB4KCjsaGScHn\
    +rV5AMEFg0EXAyk4EMNq6NeHRCyqNrCCuZT0KCXrmTxyGxOFiowxeyz1zJNMqDc4kbzrunupYygU\
    SlMWDxj6Zxpx64p42df3qUcmxyCeTsQlSwGm5KzGUnG5C+ZXSnNOaKvyyOHZJr6pBJBXExbk74Cz\
    7r0Ok60h8YG5vKGvLPkVs5Em6q2vyvZ/mys94zhaTRf94pZy1MRcF/euvSAebfjpL49zD99QSwME\
    FAAAAAgAwWVoXJv9N+qtAAAAKQEAAAsAAABfcmVscy8ucmVsc43POw7CMAwG4KtE3mlaBoRQ0y4I\
    qSsqB7ASN61oHkrCo7cnAwNFDIy2f3+W6/ZpZnanECdnBVRFCYysdGqyWsClP232wGJCq3B2lgQs\
    xHCsygvNKqYVHkbPIhmWJQwx+gMi64GM4sx5sinpXDAqpjLs2TJnRlZkWcWM0JbOkHALxPW9lvDg\
    5IdJrDMkwHiC4qA9XmjiFpoK4ivtezXNtCKO6kVghPCknjH+6RCtOC3y8r6s11WZfik0UycpBWVd\
    y/6JX7/PkE21SOe/6aX39ZvIQzpQkW/TkOlK8shpVW/qqWCTyboIONsuwsm1zctydrHru3U/UEsD\
    BBQAAAAIAMFlaFyZCVxZiwAAAK4AAAARAAAAd29yZC9kb2N1bWVudC54bWxFjUEOgjAQRa9CZi+D\
    LowhFHaeQA9Q2xFI6EzTqSK3tyyMq5+Xn7zXDZ+wVG9KOgsbONYNVMRO/MyjgfvterhApdmyt4sw\
    GdhIYei7tfXiXoE4V0XA2q4Gppxji6huomC1lkhcvqekYHPBNOIqycckjlSLPyx4apozBjsz7MqH\
    +G3fiH2HP8R/qv8CUEsDBBQAAAAIAMFlaFyGGx+fdgAAAIwAAAAcAAAAd29yZC9fcmVscy9kb2N1\
    bWVudC54bWwucmVsc02MQQ7CIBAAv0L2bkEPxpjS3voAow/Y0BWIsBCWGP29HD1OJjPz+slJvalJ\
    LGzhOBlQxK7skb2Fx307XEBJR94xFSYLXxJYl/lGCftIJMQqajxYLITe61VrcYEyylQq8TDP0jL2\
    gc3riu6FnvTJmLNu/w/Qyw9QSwECFAMUAAAACADBZWhceW4z1+gAAACtAQAAEwAAAAAAAAAAAAAA\
    gAEAAAAAW0NvbnRlbnRfVHlwZXNdLnhtbFBLAQIUAxQAAAAIAMFlaFyb/TfqrQAAACkBAAALAAAA\
    AAAAAAAAAACAARkBAABfcmVscy8ucmVsc1BLAQIUAxQAAAAIAMFlaFyZCVxZiwAAAK4AAAARAGAA\
    AAAAAAAAAAAAgAHvAQAAd29yZC9kb2N1bWVudC54bWxQSwECFAMUAAAACADBZWhchhsfn3YAAACM\
    AAAAHAAAAAAAAAAAAAAAgAGpAgAAd29yZC9fcmVscy9kb2N1bWVudC54bWwucmVsc1BLBQYAAAAA\
    BAAEAAMBAABZAwAAAAA=
    """.replacingOccurrences(of: "\\\n", with: "")
       .replacingOccurrences(of: "\n", with: "")
       .replacingOccurrences(of: " ", with: "")
    
    // Minimal .xlsx — 1512 bytes
    // Contains: [Content_Types].xml, _rels/.rels, xl/workbook.xml, xl/_rels/workbook.xml.rels, xl/worksheets/sheet1.xml
    private static let xlsxBase64 = """
    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
    """.replacingOccurrences(of: "\\\n", with: "")
       .replacingOccurrences(of: "\n", with: "")
       .replacingOccurrences(of: " ", with: "")
    
    // Minimal .pptx — 3488 bytes
    // Contains: [Content_Types].xml, _rels/.rels, ppt/presentation.xml, ppt/_rels/presentation.xml.rels,
    //           ppt/slides/slide1.xml, ppt/slides/_rels/slide1.xml.rels,
    //           ppt/slideLayouts/slideLayout1.xml, ppt/slideLayouts/_rels/slideLayout1.xml.rels,
    //           ppt/slideMasters/slideMaster1.xml, ppt/slideMasters/_rels/slideMaster1.xml.rels
    private static let pptxBase64 = """
    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\
    VOpW8D1qborIbU2RrEbYn0jx363hk6BfOcyecfEYonZ+mCS3jmwmIaKGuQ8ru/WqpliQDVNmr1bvsB\
    UEsBAhQDFAAAAAgAwWVoXNuboGQWAQAAXAMAABMAAAAAAAAAAAAAAIABAAAAAFtDb250ZW50X1R5cGVz\
    XS54bWxQSwECFAMUAAAACADBZWhcG8q47q4AAAAsAQAACwAAAAAAAAAAAAAAgAFHAQAAX3JlbHMvLnJl\
    bHNQSwECFAMUAAAACADBZWhcrzpeG/4AAAD/AQAAFAAAAAAAAAAAAAAAgAEeAgAAcHB0L3ByZXNlbnRh\
    dGlvbi54bWxQSwECFAMUAAAACADBZWhc9M0Gpr8AAAC3AQAAHwAAAAAAAAAAAAAAgAFOAwAAcHB0L19y\
    ZWxzL3ByZXNlbnRhdGlvbi54bWwucmVsc1BLAQIUAxQAAAAIAMFlaFxKVqr/1wAAAJcBAAAVAAAAAAAA\
    AAAAAACAAUoEAABwcHQvc2xpZGVzL3NsaWRlMS54bWxQSwECFAMUAAAACADBZWhc3RFNSrIAAAA1AQ\
    AAIAAAAAAAAAAAAAAAgAFUBQAAcHB0L3NsaWRlcy9fcmVscy9zbGlkZTEueG1sLnJlbHNQSwECFAMU\
    AAAACADBZWhc1zw4EuUAAACwAQAAIQAAAAAAAAAAAAAAgAFEBgAAcHB0L3NsaWRlTGF5b3V0cy9zbGlk\
    ZUxheW91dDEueG1sUEsBAhQDFAAAAAgAwWVoXGuc/A+xAAAANQEAACwAAAAAAAAAAAAAAIABaAcAAHBw\
    dC9zbGlkZUxheW91dHMvX3JlbHMvc2xpZGVMYXlvdXQxLnhtbC5yZWxzUEsBAhQDFAAAAAgAwWVoXP\
    s/rNMAAQAA9AEAACEAAAAAAAAAAAAAAIABYwgAAHBwdC9zbGlkZU1hc3RlcnMvc2xpZGVNYXN0ZXIx\
    LnhtbFBLAQIUAxQAAAAIAMFlaFzdEU1KsgAAADUBAAAsAAAAAAAAAAAAAACAAaIJAABwcHQvc2xpZGVN\
    YXN0ZXJzL19yZWxzL3NsaWRlTWFzdGVyMS54bWwucmVsc1BLBQYAAAAACgAKAOwCAACeCgAAAAA=
    """.replacingOccurrences(of: "\\\n", with: "")
       .replacingOccurrences(of: "\n", with: "")
       .replacingOccurrences(of: " ", with: "")
}

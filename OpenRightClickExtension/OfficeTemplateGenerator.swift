//
//  OfficeTemplateGenerator.swift
//  OpenRightClickExtension
//

import Foundation

enum OfficeTemplateGenerator {
    
    // MARK: - Public
    
    static func createMinimalDocx(at url: URL) throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // [Content_Types].xml
        try contentTypesXML(overrides: [
            ("/word/document.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml")
        ]).write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
        
        // _rels/.rels
        let relsDir = tempDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: relsDir, withIntermediateDirectories: true)
        try relsXML(relationships: [
            ("rId1", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument", "word/document.xml")
        ]).write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
        
        // word/document.xml
        let wordDir = tempDir.appendingPathComponent("word")
        try FileManager.default.createDirectory(at: wordDir, withIntermediateDirectories: true)
        let docXML = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:r><w:t></w:t></w:r></w:p>
          </w:body>
        </w:document>
        """
        try docXML.write(to: wordDir.appendingPathComponent("document.xml"), atomically: true, encoding: .utf8)
        
        // word/_rels/document.xml.rels
        let wordRelsDir = wordDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: wordRelsDir, withIntermediateDirectories: true)
        try relsXML(relationships: []).write(to: wordRelsDir.appendingPathComponent("document.xml.rels"), atomically: true, encoding: .utf8)
        
        try zipDirectory(tempDir, to: url)
    }
    
    static func createMinimalXlsx(at url: URL) throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // [Content_Types].xml
        try contentTypesXML(overrides: [
            ("/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"),
            ("/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml")
        ]).write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
        
        // _rels/.rels
        let relsDir = tempDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: relsDir, withIntermediateDirectories: true)
        try relsXML(relationships: [
            ("rId1", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument", "xl/workbook.xml")
        ]).write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
        
        // xl/workbook.xml
        let xlDir = tempDir.appendingPathComponent("xl")
        try FileManager.default.createDirectory(at: xlDir, withIntermediateDirectories: true)
        let wbXML = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <sheets>
            <sheet name="Sheet1" sheetId="1" r:id="rId1"/>
          </sheets>
        </workbook>
        """
        try wbXML.write(to: xlDir.appendingPathComponent("workbook.xml"), atomically: true, encoding: .utf8)
        
        // xl/_rels/workbook.xml.rels
        let xlRelsDir = xlDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: xlRelsDir, withIntermediateDirectories: true)
        try relsXML(relationships: [
            ("rId1", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet", "worksheets/sheet1.xml")
        ]).write(to: xlRelsDir.appendingPathComponent("workbook.xml.rels"), atomically: true, encoding: .utf8)
        
        // xl/worksheets/sheet1.xml
        let sheetsDir = xlDir.appendingPathComponent("worksheets")
        try FileManager.default.createDirectory(at: sheetsDir, withIntermediateDirectories: true)
        let sheetXML = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          <sheetData/>
        </worksheet>
        """
        try sheetXML.write(to: sheetsDir.appendingPathComponent("sheet1.xml"), atomically: true, encoding: .utf8)
        
        try zipDirectory(tempDir, to: url)
    }
    
    static func createMinimalPptx(at url: URL) throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // [Content_Types].xml
        try contentTypesXML(overrides: [
            ("/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"),
            ("/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml"),
            ("/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"),
            ("/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml")
        ]).write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
        
        // _rels/.rels
        let relsDir = tempDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: relsDir, withIntermediateDirectories: true)
        try relsXML(relationships: [
            ("rId1", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument", "ppt/presentation.xml")
        ]).write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
        
        // ppt/presentation.xml
        let pptDir = tempDir.appendingPathComponent("ppt")
        try FileManager.default.createDirectory(at: pptDir, withIntermediateDirectories: true)
        let presXML = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <p:presentation xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
                        xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                        xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
          <p:sldMasterIdLst>
            <p:sldMasterId id="2147483648" r:id="rId2"/>
          </p:sldMasterIdLst>
          <p:sldIdLst>
            <p:sldId id="256" r:id="rId1"/>
          </p:sldIdLst>
          <p:sldSz cx="12192000" cy="6858000"/>
          <p:notesSz cx="6858000" cy="9144000"/>
        </p:presentation>
        """
        try presXML.write(to: pptDir.appendingPathComponent("presentation.xml"), atomically: true, encoding: .utf8)
        
        // ppt/_rels/presentation.xml.rels
        let pptRelsDir = pptDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: pptRelsDir, withIntermediateDirectories: true)
        try relsXML(relationships: [
            ("rId1", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide", "slides/slide1.xml"),
            ("rId2", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster", "slideMasters/slideMaster1.xml")
        ]).write(to: pptRelsDir.appendingPathComponent("presentation.xml.rels"), atomically: true, encoding: .utf8)
        
        // ppt/slides/slide1.xml
        let slidesDir = pptDir.appendingPathComponent("slides")
        try FileManager.default.createDirectory(at: slidesDir, withIntermediateDirectories: true)
        let slideXML = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <p:sld xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
               xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
               xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <p:cSld>
            <p:spTree>
              <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
              <p:grpSpPr/>
            </p:spTree>
          </p:cSld>
        </p:sld>
        """
        try slideXML.write(to: slidesDir.appendingPathComponent("slide1.xml"), atomically: true, encoding: .utf8)
        
        // ppt/slides/_rels/slide1.xml.rels
        let slideRelsDir = slidesDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: slideRelsDir, withIntermediateDirectories: true)
        try relsXML(relationships: [
            ("rId1", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout", "../slideLayouts/slideLayout1.xml")
        ]).write(to: slideRelsDir.appendingPathComponent("slide1.xml.rels"), atomically: true, encoding: .utf8)
        
        // ppt/slideLayouts/slideLayout1.xml
        let layoutsDir = pptDir.appendingPathComponent("slideLayouts")
        try FileManager.default.createDirectory(at: layoutsDir, withIntermediateDirectories: true)
        let layoutXML = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <p:sldLayout xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
                     xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                     xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                     type="blank">
          <p:cSld>
            <p:spTree>
              <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
              <p:grpSpPr/>
            </p:spTree>
          </p:cSld>
        </p:sldLayout>
        """
        try layoutXML.write(to: layoutsDir.appendingPathComponent("slideLayout1.xml"), atomically: true, encoding: .utf8)
        
        // ppt/slideLayouts/_rels/slideLayout1.xml.rels
        let layoutRelsDir = layoutsDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: layoutRelsDir, withIntermediateDirectories: true)
        try relsXML(relationships: [
            ("rId1", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster", "../slideMasters/slideMaster1.xml")
        ]).write(to: layoutRelsDir.appendingPathComponent("slideLayout1.xml.rels"), atomically: true, encoding: .utf8)
        
        // ppt/slideMasters/slideMaster1.xml
        let mastersDir = pptDir.appendingPathComponent("slideMasters")
        try FileManager.default.createDirectory(at: mastersDir, withIntermediateDirectories: true)
        let masterXML = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <p:sldMaster xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
                     xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                     xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <p:cSld>
            <p:spTree>
              <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
              <p:grpSpPr/>
            </p:spTree>
          </p:cSld>
          <p:sldLayoutIdLst>
            <p:sldLayoutId id="2147483649" r:id="rId1"/>
          </p:sldLayoutIdLst>
        </p:sldMaster>
        """
        try masterXML.write(to: mastersDir.appendingPathComponent("slideMaster1.xml"), atomically: true, encoding: .utf8)
        
        // ppt/slideMasters/_rels/slideMaster1.xml.rels
        let masterRelsDir = mastersDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: masterRelsDir, withIntermediateDirectories: true)
        try relsXML(relationships: [
            ("rId1", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout", "../slideLayouts/slideLayout1.xml")
        ]).write(to: masterRelsDir.appendingPathComponent("slideMaster1.xml.rels"), atomically: true, encoding: .utf8)
        
        try zipDirectory(tempDir, to: url)
    }
    
    // MARK: - Helpers
    
    private static func contentTypesXML(overrides: [(String, String)]) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
          <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
          <Default Extension="xml" ContentType="application/xml"/>
        
        """
        for (partName, contentType) in overrides {
            xml += "  <Override PartName=\"\(partName)\" ContentType=\"\(contentType)\"/>\n"
        }
        xml += "</Types>"
        return xml
    }
    
    private static func relsXML(relationships: [(String, String, String)]) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        
        """
        for (id, type, target) in relationships {
            xml += "  <Relationship Id=\"\(id)\" Type=\"\(type)\" Target=\"\(target)\"/>\n"
        }
        xml += "</Relationships>"
        return xml
    }
    
    private static func zipDirectory(_ sourceDir: URL, to destination: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-c", "-k", "--sequesterRsrc", sourceDir.path, destination.path]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw NSError(domain: "OfficeTemplateGenerator", code: Int(process.terminationStatus),
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create ZIP archive"])
        }
    }
}

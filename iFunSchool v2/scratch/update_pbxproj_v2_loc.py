import sys

pbxproj_path = "/Users/wojciechbeling/Projekty/ifunschool_ios/iFunSchool.xcodeproj/project.pbxproj"

with open(pbxproj_path, "r", encoding="utf-8") as f:
    content = f.read()

HAPTIC_SVC_REF   = "V20000000000000000000050"
REVIEW_SVC_REF   = "V20000000000000000000051"
LOC_VAR_REF      = "V20000000000000000000052"

EN_LOC_FILE_REF  = "V20000000000000000000053"
PL_LOC_FILE_REF  = "V20000000000000000000054"

BUILD_HAPTIC_SRC = "V20000000000000000000055"
BUILD_REVIEW_SRC = "V20000000000000000000056"
BUILD_LOC_RES    = "V20000000000000000000057"

if HAPTIC_SVC_REF not in content:
    # 1. PBXBuildFile Section
    pbx_build_file_insert = f"""\t\t{BUILD_HAPTIC_SRC} /* HapticService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {HAPTIC_SVC_REF} /* HapticService.swift */; }};\n\t\t{BUILD_REVIEW_SRC} /* ReviewPromptService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {REVIEW_SVC_REF} /* ReviewPromptService.swift */; }};\n\t\t{BUILD_LOC_RES} /* Localizable.strings in Resources */ = {{isa = PBXBuildFile; fileRef = {LOC_VAR_REF} /* Localizable.strings */; }};\n"""
    content = content.replace("/* Begin PBXBuildFile section */\n", "/* Begin PBXBuildFile section */\n" + pbx_build_file_insert)

    # 2. PBXFileReference Section
    pbx_file_ref_insert = f"""\t\t{HAPTIC_SVC_REF} /* HapticService.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = HapticService.swift; sourceTree = "<group>"; }};\n\t\t{REVIEW_SVC_REF} /* ReviewPromptService.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = ReviewPromptService.swift; sourceTree = "<group>"; }};\n\t\t{EN_LOC_FILE_REF} /* en */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = en; path = "iFunSchool v2/en.lproj/Localizable.strings"; sourceTree = "<group>"; }};\n\t\t{PL_LOC_FILE_REF} /* pl */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = pl; path = "iFunSchool v2/pl.lproj/Localizable.strings"; sourceTree = "<group>"; }};\n"""
    content = content.replace("/* Begin PBXFileReference section */\n", "/* Begin PBXFileReference section */\n" + pbx_file_ref_insert)

    # 3. PBXVariantGroup Section
    pbx_variant_insert = f"""\t\t{LOC_VAR_REF} /* Localizable.strings */ = {{\n\t\t\tisa = PBXVariantGroup;\n\t\t\tchildren = (\n\t\t\t\t{EN_LOC_FILE_REF} /* en */,\n\t\t\t\t{PL_LOC_FILE_REF} /* pl */,\n\t\t\t);\n\t\t\tname = Localizable.strings;\n\t\t\tsourceTree = "<group>";\n\t\t}};\n"""
    content = content.replace("/* Begin PBXVariantGroup section */\n", "/* Begin PBXVariantGroup section */\n" + pbx_variant_insert)

    # 4. PBXSourcesBuildPhase for iFunSchool v2
    content = content.replace(
        "V20000000000000000000043 /* SettingsView.swift in Sources */,",
        f"V20000000000000000000043 /* SettingsView.swift in Sources */,\n\t\t\t\t{BUILD_HAPTIC_SRC} /* HapticService.swift in Sources */,\n\t\t\t\t{BUILD_REVIEW_SRC} /* ReviewPromptService.swift in Sources */,"
    )

    # 5. PBXResourcesBuildPhase for iFunSchool v2
    content = content.replace(
        "V2RES0000000000000000102 /* pierwiastki.dat in Resources */,",
        f"V2RES0000000000000000102 /* pierwiastki.dat in Resources */,\n\t\t\t\t{BUILD_LOC_RES} /* Localizable.strings in Resources */,"
    )

    # 6. PBXGroup for iFunSchool v2
    content = content.replace(
        "V20000000000000000000041 /* SettingsView.swift */,",
        f"V20000000000000000000041 /* SettingsView.swift */,\n\t\t\t\t{HAPTIC_SVC_REF} /* HapticService.swift */,\n\t\t\t\t{REVIEW_SVC_REF} /* ReviewPromptService.swift */,\n\t\t\t\t{LOC_VAR_REF} /* Localizable.strings */,"
    )

    with open(pbxproj_path, "w", encoding="utf-8") as f:
        f.write(content)

    print("Added HapticService, ReviewPromptService, and Localizable.strings (en & pl) to project.pbxproj!")
else:
    print("Files already added in project.pbxproj!")

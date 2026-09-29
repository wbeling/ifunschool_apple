import sys

pbxproj_path = "/Users/wojciechbeling/Projekty/ifunschool_ios/iFunSchool.xcodeproj/project.pbxproj"

with open(pbxproj_path, "r", encoding="utf-8") as f:
    content = f.read()

STORE_SVC_REF   = "V20000000000000000000060"
STORE_VIEW_REF  = "V20000000000000000000061"

BUILD_STORE_SVC = "V20000000000000000000062"
BUILD_STORE_VIEW = "V20000000000000000000063"

if STORE_SVC_REF not in content:
    # 1. PBXBuildFile Section
    pbx_build_file_insert = f"""\t\t{BUILD_STORE_SVC} /* StoreKitService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {STORE_SVC_REF} /* StoreKitService.swift */; }};\n\t\t{BUILD_STORE_VIEW} /* StoreView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {STORE_VIEW_REF} /* StoreView.swift */; }};\n"""
    content = content.replace("/* Begin PBXBuildFile section */\n", "/* Begin PBXBuildFile section */\n" + pbx_build_file_insert)

    # 2. PBXFileReference Section
    pbx_file_ref_insert = f"""\t\t{STORE_SVC_REF} /* StoreKitService.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = StoreKitService.swift; sourceTree = "<group>"; }};\n\t\t{STORE_VIEW_REF} /* StoreView.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = StoreView.swift; sourceTree = "<group>"; }};\n"""
    content = content.replace("/* Begin PBXFileReference section */\n", "/* Begin PBXFileReference section */\n" + pbx_file_ref_insert)

    # 3. PBXSourcesBuildPhase for iFunSchool v2
    content = content.replace(
        "V20000000000000000000056 /* ReviewPromptService.swift in Sources */,",
        f"V20000000000000000000056 /* ReviewPromptService.swift in Sources */,\n\t\t\t\t{BUILD_STORE_SVC} /* StoreKitService.swift in Sources */,\n\t\t\t\t{BUILD_STORE_VIEW} /* StoreView.swift in Sources */,"
    )

    # 4. PBXGroup for iFunSchool v2
    content = content.replace(
        "V20000000000000000000051 /* ReviewPromptService.swift */,",
        f"V20000000000000000000051 /* ReviewPromptService.swift */,\n\t\t\t\t{STORE_SVC_REF} /* StoreKitService.swift */,\n\t\t\t\t{STORE_VIEW_REF} /* StoreView.swift */,"
    )

    with open(pbxproj_path, "w", encoding="utf-8") as f:
        f.write(content)

    print("Added StoreKitService.swift and StoreView.swift to project.pbxproj!")
else:
    print("Files already added in project.pbxproj!")

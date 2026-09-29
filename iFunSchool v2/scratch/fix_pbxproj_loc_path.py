import sys

pbxproj_path = "/Users/wojciechbeling/Projekty/ifunschool_ios/iFunSchool.xcodeproj/project.pbxproj"

with open(pbxproj_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace duplicated path prefix
content = content.replace(
    'path = "iFunSchool v2/en.lproj/Localizable.strings"',
    'path = "en.lproj/Localizable.strings"'
)
content = content.replace(
    'path = "iFunSchool v2/pl.lproj/Localizable.strings"',
    'path = "pl.lproj/Localizable.strings"'
)

with open(pbxproj_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Successfully fixed Localizable.strings paths in project.pbxproj!")

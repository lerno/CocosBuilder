//
//  CCBProjectCreator.m
//  CocosBuilder
//
//  Created by Viktor on 10/11/13.
//
//

#import "CCBProjectCreator.h"
#import "AppDelegate.h"
#import "CCBFileUtil.h"
#import "SBPackageSettings.h"

@implementation NSString (IdentifierSanitizer)

- (NSString *)sanitizedIdentifier
{
    NSString* identifier = [self stringByTrimmingCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]];
    NSMutableString* sanitized = [NSMutableString new];
    
    for (int idx = 0; idx < [identifier length]; idx++)
    {
        unichar ch = [identifier characterAtIndex:idx];
        if (!isalpha(ch))
        {
            ch = '_';
        }
        [sanitized appendString:[NSString stringWithCharacters:&ch length:1]];
    }
    
    NSString *trimmed = [sanitized stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
    if ([trimmed length] == 0)
    {
        trimmed = @"identifier";
    }
    
    return trimmed;
}

@end

@implementation CCBProjectCreator

-(BOOL) createDefaultProjectAtPath:(NSString*)fileName engine:(CCBTargetEngine)engine programmingLanguage:(CCBProgrammingLanguage)programmingLanguage orientation:(CCBOrientation)orientation
{
    NSError *error = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    
	NSString* substitutableProjectName = @"PROJECTNAME";
    NSString* substitutableProjectIdentifier = @"PROJECTIDENTIFIER";
    NSString* parentPath = [fileName stringByDeletingLastPathComponent];
	
    NSString* zipFile = [[NSBundle mainBundle] pathForResource:substitutableProjectName ofType:@"zip" inDirectory:@"Generated"];
    
    // Check that zip file exists
    if (![fm fileExistsAtPath:zipFile])
    {
        [[AppDelegate appDelegate] modalDialogTitle:@"Failed to Create Project"
											message:@"The default CocosBuilder project is missing from this build. Make sure that you build CocosBuilder using 'Scripts/build_distribution.py --version <versionstr>' the first time you build the program."];
        return NO;
    }
    
    // Unzip resources
    NSTask* zipTask = [[NSTask alloc] init];
    [zipTask setCurrentDirectoryPath:parentPath];
    [zipTask setLaunchPath:@"/usr/bin/unzip"];
    NSArray* args = @[@"-o", zipFile];
    [zipTask setArguments:args];
    [zipTask launch];
    [zipTask waitUntilExit];
    
    // Rename ccbproj
	NSString* ccbproj = [NSString stringWithFormat:@"%@.ccbproj", substitutableProjectName];
    [fm moveItemAtPath:[parentPath stringByAppendingPathComponent:ccbproj] toPath:fileName error:NULL];
    
    // Update the Xcode project
	NSString* xcodeproj = [NSString stringWithFormat:@"%@.xcodeproj", substitutableProjectName];
    NSString* xcodeFileName = [parentPath stringByAppendingPathComponent:xcodeproj];
    NSString* projName = [[fileName lastPathComponent] stringByDeletingPathExtension];
    NSString* identifier = [projName sanitizedIdentifier];
    
    // Update the project
    NSString *pbxprojFile = [xcodeFileName stringByAppendingPathComponent:@"project.pbxproj"];
    [self setName:projName inFile:pbxprojFile search:substitutableProjectName];
    [self setName:identifier inFile:pbxprojFile search:substitutableProjectIdentifier];
    NSArray *filesToRemove;
    if (programmingLanguage == CCBProgrammingLanguageObjectiveC)
    {
        // keep ios7 as minimum deployment target
        /*
        [self setName:@"IPHONEOS_DEPLOYMENT_TARGET = 8.0"
               inFile:pbxprojFile
               search:@"IPHONEOS_DEPLOYMENT_TARGET = 7.0"];
        */
        [self setName:@"MACOSX_DEPLOYMENT_TARGET = 10.10"
               inFile:pbxprojFile
               search:@"MACOSX_DEPLOYMENT_TARGET = 10.11"];
        
        [self removeLinesMatching:@".*MainScene[.]swift.*" inFile:pbxprojFile];
        [self removeLinesMatching:@".*AppDelegate[.]swift.*" inFile:pbxprojFile];
        filesToRemove = @[@"Source/MainScene.swift", @"Source/Platforms/iOS/AppDelegate.swift", @"Source/Platforms/tvOS/AppDelegate.swift", @"Source/Platforms/Mac/AppDelegate.swift"];
    }
    else if (programmingLanguage == CCBProgrammingLanguageSwift)
    {
        [self removeLinesMatching:@".*MainScene[.][hm].*" inFile:pbxprojFile];
        [self removeLinesMatching:@".* AppDelegate[.][hm].*" inFile:pbxprojFile];
        [self removeLinesMatching:@".*main[.][m].*" inFile:pbxprojFile];
        filesToRemove = @[@"Source/MainScene.h", @"Source/MainScene.m", @"Source/Platforms/iOS/AppDelegate.h", @"Source/Platforms/iOS/AppDelegate.m", @"Source/Platforms/iOS/main.m", @"Source/Platforms/tvOS/AppDelegate.h", @"Source/Platforms/tvOS/AppDelegate.m", @"Source/Platforms/tvOS/main.m", @"Source/Platforms/Mac/AppDelegate.h", @"Source/Platforms/Mac/AppDelegate.m", @"Source/Platforms/Mac/main.m"];
    }

    for (NSString *file in filesToRemove)
    {
        if (![fm removeItemAtPath:[parentPath stringByAppendingPathComponent:file] error:&error])
        {
            return NO;
        }
    }

    // Update workspace data
    [self setName:projName inFile:[xcodeFileName stringByAppendingPathComponent:@"project.xcworkspace/contents.xcworkspacedata"] search:substitutableProjectName];
    
    NSArray *platforms = @[@"iOS", @"Mac", @"tvOS"];
    
    for (id platform in platforms) {
        // Update scheme
        NSString* templateScheme = [NSString stringWithFormat:@"xcshareddata/xcschemes/%@ %@.xcscheme", substitutableProjectName, platform];
        [self setName:projName inFile:[xcodeFileName stringByAppendingPathComponent:templateScheme] search:substitutableProjectName];

        // Rename scheme file
        NSString* schemeFile = [xcodeFileName stringByAppendingPathComponent:templateScheme];
        NSString* format = [@"iOS" isEqualToString:platform] ? @"%@" : @"%@ %@";  // we want iOS on top

        NSString* newSchemeFile = [[[schemeFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:format, projName, platform]]
            stringByAppendingPathExtension:@"xcscheme"];
        
        if (![fm moveItemAtPath:schemeFile toPath:newSchemeFile error:&error])
        {
            return NO;
        }

        // Update plist
        NSString* plistFileName = [parentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Source/Resources/Platforms/%@/Info.plist", platform]];
        [self setName:identifier inFile:plistFileName search:substitutableProjectIdentifier];
        [self setName:projName inFile:plistFileName search:substitutableProjectName];
        if (orientation == kCCBOrientationLandscape)
        {
            [self setName:@"UIInterfaceOrientationLandscapeLeft</string>\n<string>UIInterfaceOrientationLandscapeRight" inFile:plistFileName search:@"ORIENTATION"];
        }
        else if (orientation == kCCBOrientationPortrait)
        {
            [self setName:@"UIInterfaceOrientationPortrait" inFile:plistFileName search:@"ORIENTATION"];
        }
    }

    // Rename Xcode project file
    NSString* newXcodeFileName = [[[xcodeFileName stringByDeletingLastPathComponent] stringByAppendingPathComponent:projName] stringByAppendingPathExtension:@"xcodeproj"];
    
    [fm moveItemAtPath:xcodeFileName toPath:newXcodeFileName error:NULL];
    
    // Update Mac Xib file
    NSString* xibFileName = [parentPath stringByAppendingPathComponent:@"Source/Resources/Platforms/Mac/MainMenu.xib"];
    if (programmingLanguage == CCBProgrammingLanguageObjectiveC) {
        [self setName:@"" inFile:xibFileName search: @"customModule=\"PROJECTNAME\""];
    }
    [self setName:identifier inFile:xibFileName search:substitutableProjectIdentifier];
    [self setName:projName inFile:xibFileName search:substitutableProjectName];
	
	// perform cleanup to remove unnecessary files which only bloat the project
	[CCBFileUtil cleanupCocosBuilderProjectAtPath:fileName];
	
    // hide package content by default
    [SBPackageSettings showPackageContentInFinder:NO withPackagePath:[parentPath stringByAppendingPathComponent:@"Packages/CocosBuilder Resources.ccbpack"]];
    
    // change orientation in cocos2d config file
    NSString* plistFileName = [parentPath stringByAppendingPathComponent:@"Source/Resources/Published-iOS/configCocos2d.plist"];
    if (orientation == kCCBOrientationLandscape)
    {
        [self setName:@"CCScreenOrientationLandscape" inFile:plistFileName search:@"ORIENTATION"];
    }
    else if (orientation == kCCBOrientationPortrait)
    {
        [self setName:@"CCScreenOrientationPortrait" inFile:plistFileName search:@"ORIENTATION"];
    }
    else
    {
        return NO;
    }
    plistFileName = [parentPath stringByAppendingPathComponent:@"Source/Resources/Published-tvOS/configCocos2d.plist"];
    if (orientation == kCCBOrientationLandscape)
    {
        [self setName:@"CCScreenOrientationLandscape" inFile:plistFileName search:@"ORIENTATION"];
    }
    else if (orientation == kCCBOrientationPortrait)
    {
        [self setName:@"CCScreenOrientationPortrait" inFile:plistFileName search:@"ORIENTATION"];
    }
    else
    {
        return NO;
    }
    
    // change orientation in cbbproj file
    NSMutableDictionary* projectDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    if (!projectDict)
    {
        return NO;
    }
    projectDict[@"deviceOrientationLandscapeLeft"] = @((orientation == kCCBOrientationLandscape));
    projectDict[@"deviceOrientationLandscapeRight"] = @((orientation == kCCBOrientationLandscape));
    projectDict[@"deviceOrientationPortrait"] = @((orientation == kCCBOrientationPortrait));
    projectDict[@"deviceOrientationUpsideDown"] = @((orientation == kCCBOrientationPortrait));
    projectDict[@"defaultOrientation"] = @(orientation);
    
    [projectDict writeToFile:fileName atomically:YES];
    
    return [fm fileExistsAtPath:fileName];
}

- (void) setName:(NSString*)name inFile:(NSString*)fileName search:(NSString*)searchStr
{
    NSMutableData *fileData = [NSMutableData dataWithContentsOfFile:fileName];
    NSData *search = [searchStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *replacement = [name dataUsingEncoding:NSUTF8StringEncoding];
    NSRange found;
    do {
        found = [fileData rangeOfData:search options:0 range:NSMakeRange(0, [fileData length])];
        if (found.location != NSNotFound)
{
            [fileData replaceBytesInRange:found withBytes:[replacement bytes] length:[replacement length]];
	}
    } while (found.location != NSNotFound && found.length > 0);
    [fileData writeToFile:fileName atomically:YES];
}

- (void) removeLinesMatching:(NSString*)pattern inFile:(NSString*)fileName
{
    NSData *fileData = [NSData dataWithContentsOfFile:fileName];
    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *updatedString = [regex stringByReplacingMatchesInString:fileString
                                                         options:0
                                                           range:NSMakeRange(0, [fileString length])
                                                    withTemplate:@""];
    NSData *updatedFileData = [updatedString dataUsingEncoding:NSUTF8StringEncoding];
    [updatedFileData writeToFile:fileName atomically:YES];
}

@end

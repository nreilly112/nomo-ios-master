//
//  NoMoUITests.m
//  NoMoUITests
//
//  Created by Marta on 03.09.2018.
//  Copyright © 2018 MiiCard. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NoMoUITests : XCTestCase

@end

@implementation NoMoUITests

XCUIApplication *app;

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    
    
    app = [[XCUIApplication alloc] init];
    app.launchArguments = @[@"UI-Testing"];
    [app launch];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testAcceptingTerms {
    [app.buttons[@"Accept and Continue"] tap];
    XCTAssertTrue([app.buttons [@"Connect your account"] exists]);
}

- (void)testConnectAccount {
    [app.buttons[@"Accept and Continue"] tap];
    [app.buttons[@"Connect your account"] tap];
    XCTAssertTrue([app.buttons [@"CLOSE"] exists]);
}

- (void)testCloseButton {
    [app.buttons[@"Accept and Continue"] tap];
    [app.buttons[@"Connect your account"] tap];
    
    [[app.buttons[@"CLOSE"] accessibilityElementAtIndex:1] tap];
    XCTAssertTrue([app.buttons [@"Connect your account"] exists]);
    XCTAssertFalse([app.buttons [@"Accept and Continue"] exists]);
}

- (BOOL)isDisplaying:(NSString*)element {
    return app.otherElements[element].exists;
}

- (void)setTermsDisplayed{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *actionKey = @"action:AcceptTermsAndConditions";
    [userDefaults setBool:YES forKey:actionKey];
    [userDefaults synchronize];
}

- (NSString *)keyForActionNamed:(NSString *)actionName
{
    return [NSString stringWithFormat:@"action:%@", actionName ?: @""];
}

@end

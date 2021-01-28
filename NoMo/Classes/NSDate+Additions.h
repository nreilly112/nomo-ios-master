//
//  NSDate+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSDate (Additions)

@property (nonatomic, assign, readonly) NSInteger year;
@property (nonatomic, assign, readonly) NSInteger month;
@property (nonatomic, assign, readonly) NSInteger day;
@property (nonatomic, assign, readonly) NSInteger hour;
@property (nonatomic, assign, readonly) NSInteger minute;
@property (nonatomic, assign, readonly) NSInteger second;
@property (nonatomic, assign, readonly) NMWeekday weekday;

+ (instancetype)dateWithRFC3339String:(NSString *)string;
+ (instancetype)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

- (NSString *)stringRFC3339;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringExpressionRelativeToNow;

- (BOOL)isEarlierThanDate:(NSDate *)date;
- (BOOL)isLaterThanDate:(NSDate *)date;
- (BOOL)isInRangeWithStartDate:(NSDate *)startDate duration:(NSTimeInterval)duration;
- (BOOL)isInRangeWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (BOOL)isToday;

- (NSDate *)dateByAddingHours:(NSInteger)hours;
- (NSDate *)dateByAddingDays:(NSInteger)days;
- (NSDate *)dateByAddingMonths:(NSInteger)months;
- (NSDate *)dateByAddingYears:(NSInteger)years;

- (NSDate *)startOfHour;
- (NSDate *)endOfHour;

- (NSDate *)startOfDay;
- (NSDate *)endOfDay;
- (NSDate *)noon;

- (NSDate *)startOfMonth;
- (NSDate *)endOfMonth;

- (NSInteger)numberOfDaysInMonth;
- (NSInteger)numberOfDaysSinceDate:(NSDate *)date;

+ (NSDate *)midnightBeforeDate:(NSDate *)date;
+ (NSDate *)midnightAfterDate:(NSDate *)date;

- (NSString *)monthString;
- (NSString *)weekdayString;
- (NSString *)shortWeekdayString;
- (NSString *)veryShortWeekdayString;

- (BOOL)isSameDayWithDate:(NSDate *)date;

@end

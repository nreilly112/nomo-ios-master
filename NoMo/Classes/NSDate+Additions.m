//
//  NSDate+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSDate+Additions.h"


@interface NSCalendar (Additions)

+ (NSCalendar *)referenceCalendar;

@end


@implementation NSCalendar (Additions)

+ (NSCalendar *)referenceCalendar
{
	static NSCalendar *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
		instance.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		instance.locale = [NSLocale currentLocale];
	});
	
	return instance;
}

@end


@implementation NSDate (Additions)

+ (instancetype)dateWithRFC3339String:(NSString *)string
{
	NSDateFormatter *formatter = [NSDateFormatter dateFormatterRFC3339];

	if (19 < string.length) {
		string = [string substringToIndex:19];
	}
	if (string.length == 19) {
		string = [string stringByAppendingString:@"Z"];
	}
	
	return [formatter dateFromString:string];
}

+ (instancetype)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setYear:year];
	[components setMonth:month];
	[components setDay:day];
	
	return [calendar dateFromComponents:components];
}

- (NSInteger)year
{
	return [[NSCalendar referenceCalendar] component:NSCalendarUnitYear fromDate:self];
}

- (NSInteger)month
{
	return [[NSCalendar referenceCalendar] component:NSCalendarUnitMonth fromDate:self];
}

- (NSInteger)day
{
	return [[NSCalendar referenceCalendar] component:NSCalendarUnitDay fromDate:self];
}

- (NSInteger)hour
{
	return [[NSCalendar referenceCalendar] component:NSCalendarUnitHour fromDate:self];
}

- (NSInteger)minute
{
	return [[NSCalendar referenceCalendar] component:NSCalendarUnitMinute fromDate:self];
}

- (NSInteger)second
{
	return [[NSCalendar referenceCalendar] component:NSCalendarUnitSecond fromDate:self];
}

- (NMWeekday)weekday
{
	return (NMWeekday)[[NSCalendar referenceCalendar] component:NSCalendarUnitWeekday fromDate:self];
}

- (NSString *)stringRFC3339
{
	NSDateFormatter *formatter = [NSDateFormatter dateFormatterRFC3339];
	
	return [formatter stringFromDate:self];
}

- (NSString *)stringWithFormat:(NSString *)format
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = format;
	
	return [formatter stringFromDate:self];
}

- (NSString *)stringExpressionRelativeToNow
{
	NSTimeInterval intervalSinceNow = MAX(0.0, -[self timeIntervalSinceNow]);
	
	if (intervalSinceNow < (60.0)) {
		return @"a moment ago";
	}
	else if (intervalSinceNow < (2 * 60.0)) {
		return @"1 minute ago";
	}
	else if (intervalSinceNow < (60 * 60.0)) {
		return [NSString stringWithFormat:@"%d minutes ago", (int)(intervalSinceNow / 60.0)];
	}
	else if (intervalSinceNow < (2 * 3600.0)) {
		return [NSString stringWithFormat:@"1 hour ago"];
	}
	else if (intervalSinceNow < (24 * 3600.0)) {
		return [NSString stringWithFormat:@"%d hours ago", (int)(intervalSinceNow / 3600.0)];
	}
	else if (intervalSinceNow < (2 * 24 * 3600.0)) {
		return [NSString stringWithFormat:@"yesterday"];
	}
	else if (intervalSinceNow < (7 * 24 * 3600.0)) {
		return [NSString stringWithFormat:@"%d days ago", (int)(intervalSinceNow / (24 * 3600.0))];
	}
	else if (intervalSinceNow < (2 * 7 * 24 * 3600.0)) {
		return [NSString stringWithFormat:@"1 week ago"];
	}
	else if (intervalSinceNow < (10 * 7 * 24 * 3600.0)) {
		return [NSString stringWithFormat:@"%d weeks ago", (int)(intervalSinceNow / (7 * 24 * 3600.0))];
	}
	else {
		return @"months ago";
	}
}

- (BOOL)isEarlierThanDate:(NSDate *)date
{
	return ([self compare:date] == NSOrderedAscending);
}

- (BOOL)isLaterThanDate:(NSDate *)date
{
	return ([self compare:date] == NSOrderedDescending);
}

- (BOOL)isInRangeWithStartDate:(NSDate *)startDate duration:(NSTimeInterval)duration
{
	NSTimeInterval interval = [self timeIntervalSinceDate:startDate];
	
	return (0 <= interval) && (interval < duration);
}

- (BOOL)isInRangeWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
	return ([self compare:startDate] >= 0) && ([self compare:endDate] < 0);
}

- (BOOL)isToday
{
	NSDate *now = [NSDate date];
	NSDate *startOfDay = [now startOfDay];
	NSDate *endOfDate = [startOfDay dateByAddingDays:1];
	
	return [self isInRangeWithStartDate:startOfDay endDate:endOfDate];
}

- (NSDate *)dateByAddingHours:(NSInteger)hours
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setHour:hours];
	
	return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingDays:(NSInteger)days
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setDay:days];
	
	return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingMonths:(NSInteger)months
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setMonth:months];
	
	return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingYears:(NSInteger)years
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setYear:years];

	return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)startOfHour
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSCalendarUnit calendarUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitTimeZone;
	NSDateComponents *components = [calendar components:calendarUnits fromDate:self];
	
	return [calendar dateFromComponents:components];
}

- (NSDate *)endOfHour
{
	return [[self startOfHour] dateByAddingHours:1];
}

- (NSDate *)startOfDay
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSCalendarUnit calendarUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitTimeZone;
	NSDateComponents *components = [calendar components:calendarUnits fromDate:self];
	
	return [calendar dateFromComponents:components];
}

- (NSDate *)endOfDay
{
	return [[self startOfDay] dateByAddingDays:1];
}

- (NSDate *)noon
{
	return [[self startOfDay] dateByAddingHours:12];
}

- (NSDate *)startOfMonth
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSCalendarUnit calendarUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitTimeZone;
	NSDateComponents *components = [calendar components:calendarUnits fromDate:self];
	
	return [calendar dateFromComponents:components];
}

- (NSDate *)endOfMonth
{
	return [[self startOfMonth] dateByAddingMonths:1];
}

- (NSInteger)numberOfDaysInMonth
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSDateComponents *components = [calendar components:NSCalendarUnitDay
											   fromDate:[self startOfMonth]
												 toDate:[self endOfMonth]
												options:0];
	return components.day;
}

- (NSInteger)numberOfDaysSinceDate:(NSDate *)date
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSDateComponents *components = [calendar components:NSCalendarUnitDay
											   fromDate:date
												 toDate:self
												options:0];
	return components.day;
}

+ (NSDate *)midnightBeforeDate:(NSDate *)date
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSCalendarUnit calendarUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
	NSDateComponents *components = [calendar components:calendarUnits fromDate:date];
	
	return [calendar dateFromComponents:components];
}

+ (NSDate *)midnightAfterDate:(NSDate *)date
{
	return [[self midnightBeforeDate:date] dateByAddingDays:1];
}

- (NSString *)monthString
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSArray *monthStrings = [calendar monthSymbols];
	
	return [monthStrings objectOrNilAtIndex:self.month - 1];
}

- (NSString *)weekdayString
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSArray *weekdayStrings = [calendar weekdaySymbols];
	
	return [weekdayStrings objectOrNilAtIndex:self.weekday - 1];
}

- (NSString *)shortWeekdayString
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSArray *weekdayStrings = [calendar shortWeekdaySymbols];
	
	return [weekdayStrings objectOrNilAtIndex:self.weekday - 1];
}

- (NSString *)veryShortWeekdayString
{
	NSCalendar *calendar = [NSCalendar referenceCalendar];
	NSArray *weekdayStrings = [calendar veryShortWeekdaySymbols];
	
	return [weekdayStrings objectOrNilAtIndex:self.weekday - 1];
}

- (BOOL)isSameDayWithDate:(NSDate *)date
{
	NSDate *d1 = [self startOfDay];
	NSDate *d2 = [date startOfDay];
	
	return [d1 isEqualToDate:d2];
}

@end


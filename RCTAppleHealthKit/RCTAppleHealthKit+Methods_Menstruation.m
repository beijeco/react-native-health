//
//  RCTAppleHealthKit+Methods_Menstruation.m
//  RCTAppleHealthKit
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "RCTAppleHealthKit+Methods_Menstruation.h"
#import "RCTAppleHealthKit+Utils.h"
#import "RCTAppleHealthKit+Queries.h"

@implementation RCTAppleHealthKit (Methods_Menstruation)

- (void)menstruation_getMenstruationDays:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    if (@available(iOS 9.0, *)) {
        HKCategoryType *menstrualCycleType = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierMenstrualFlow];
        NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
        BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
        NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
        NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
        
        if (startDate == nil) {
            callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
            return;
        }
        
        NSPredicate *predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:menstrualCycleType
                                                               predicate:predicate
                                                                   limit:limit
                                                         sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:ascending]]
                                                         resultsHandler:^(HKSampleQuery *query, NSArray<HKCategorySample *> *results, NSError *error) {
            
            if(results){
                NSMutableArray *menstruationDays = [NSMutableArray array];

                for (HKCategorySample *sample in results) {
                    if(sample != nil){
                        NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.startDate];
                        NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.endDate];
                        NSString *intensityString = [RCTAppleHealthKit stringFromMenstrualFlowValue:sample.value];
                        
                        NSDictionary *menstruationDay = @{
                            @"startDate" : startDateString,
                            @"endDate" : endDateString,
                            @"intensity": intensityString
                        };
                        [menstruationDays addObject:menstruationDay];
                    }
                }
                callback(@[[NSNull null], menstruationDays]);
                return;
            } else {
                callback(@[RCTJSErrorFromNSError(error)]);
                return;
            }
        }];
        
        [self.healthStore executeQuery:query];
    } else {
        callback(@[RCTMakeError(@"Menstrual Cycle data is not available for this iOS version", nil, nil)]);
    }
}


@end

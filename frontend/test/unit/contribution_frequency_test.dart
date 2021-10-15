import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/contribution_frequency.dart';

void main() {
  test('Should be able to convert Contribution Frequency to String', () {
    expect(contribFreqToString(ContributionFrequency.monthly), 'MONTHLY');
    expect(contribFreqToString(ContributionFrequency.biWeekly), 'BI_WEEKLY');
    expect(contribFreqToString(ContributionFrequency.weekly), 'WEEKLY');
    expect(contribFreqToString(ContributionFrequency.na), 'NA');
  });

  test('Should be able to convert String to Contribution Frequency', () {
    expect(stringToContribFreq('MONTHLY'), ContributionFrequency.monthly);
    expect(stringToContribFreq('BI_WEEKLY'), ContributionFrequency.biWeekly);
    expect(stringToContribFreq('WEEKLY'), ContributionFrequency.weekly);
    expect(stringToContribFreq('NA'), ContributionFrequency.na);
  });
}

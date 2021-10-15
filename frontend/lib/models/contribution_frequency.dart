enum ContributionFrequency {
  monthly,
  biWeekly,
  weekly,
  na,
}

final Map<String, ContributionFrequency> contribFreqMap = {
  "MONTHLY": ContributionFrequency.monthly,
  "BI_WEEKLY": ContributionFrequency.biWeekly,
  "WEEKLY": ContributionFrequency.weekly,
  "NA": ContributionFrequency.na,
};

String contribFreqToString(ContributionFrequency freq) {
  MapEntry<String, ContributionFrequency> entry =
      contribFreqMap.entries.firstWhere((entry) => entry.value == freq);
  return entry.key;
}

ContributionFrequency stringToContribFreq(String stringFreq) {
  MapEntry<String, ContributionFrequency> entry =
      contribFreqMap.entries.firstWhere((entry) => entry.key == stringFreq);
  return entry.value;
}

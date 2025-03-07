import 'package:flutter_test/flutter_test.dart';
import 'package:onlight/model/med_on_off_log.dart';

void main() {
  test("only med", () {
    var log = anOnOffLog("00:00", null, null);

    expect(log.timeUntilOn.inMinutes, 0, reason: "Should never be on");
    expect(log.timeOn.inMinutes, 0, reason: "Should never be on");
    expect(log.timeUntilOff.inMinutes, 0, reason: "Should never be off");
    expect(log.timeUntilNextMed.inMinutes, 0);
  });

  test("med then on", () {
    var log = anOnOffLog("00:00", "00:10", null);

    expect(log.timeUntilOn.inMinutes, 10, reason: "Should be on after 10 minutes");
    expect(log.timeOn.inMinutes, 60 * 8, reason: "Should be on for 8 hours");
    expect(log.timeUntilOff.inMinutes, 0, reason: "Should never be off");
    expect(log.timeUntilNextMed.inMinutes, 0);
  });

  test("single med", () {
    var log = anOnOffLog("00:00", "01:00", "01:30");

    expect(log.timeUntilOn.inMinutes, 60, reason: "Should be 60 minutes until on");
    expect(log.timeOn.inMinutes, 30, reason: "Should be 30 minutes on");
    expect(log.timeUntilOff.inMinutes, 90, reason: "Should be 90 minutes until off");
    expect(log.timeUntilNextMed.inMinutes, 0);
  });
}

const testDate = '2022-01-01';
MedOnOffLog anOnOffLog(String med, String? on, String? off, {String? prevMed, String? nextMed}) {
  return MedOnOffLog(
    DateTime.parse('$testDate $med'),
    on != null ? DateTime.parse('$testDate $on') : null,
    off != null ? DateTime.parse('$testDate $off') : null,
    tprevmed: prevMed != null ? DateTime.parse('2022-01-01 $prevMed') : null,
    tnextmed: nextMed != null ? DateTime.parse('2022-01-01 $nextMed') : null,
  );
}

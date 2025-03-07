import 'package:flutter_test/flutter_test.dart';
import 'package:onlight/model/logg.dart';
import 'package:onlight/model/med_on_off_log.dart';
import 'package:onlight/util/calculate_on_off.dart';

void main() {
  test('Creates an empty onofflog when no logs are submitted', () {
    List<MedOnOffLog> result = calculateOnOff([]);
    expect(result, []);
  });

  test('No medication in input', () {
    List<MedOnOffLog> result = calculateOnOff([
      Logg(timestamp: '2022-01-01 12:00', event: 'on'),
      Logg(timestamp: '2022-01-01 12:00', event: 'on'),
      Logg(timestamp: '2022-01-01 12:01', event: 'on'),
      Logg(timestamp: '2022-01-01 12:00', event: 'on'),
    ]);
    expect(result.length, 0);
  });

  test('One medication in input', () {
    List<MedOnOffLog> result = calculateOnOff([
      Logg(id: "1", timestamp: '2022-01-01 12:00', event: LoggType.medicineTaken.name),
      Logg(id: "2", timestamp: '2022-01-01 12:01', event: LoggType.on.name),
    ]);
    expect(result.length, 1);
    expect(
      result[0],
      equals(MedOnOffLog(DateTime.parse('2022-01-01 12:00'), DateTime.parse('2022-01-01 12:01'), null)),
    );
  });

  test('On and off before med should ', () {
    List<MedOnOffLog> result = calculateOnOff([
      Logg(timestamp: '2022-01-01 11:00', event: LoggType.on.name),
      Logg(timestamp: '2022-01-01 11:01', event: LoggType.off.name),
      Logg(timestamp: '2022-01-01 12:00', event: LoggType.medicineTaken.name),
    ]);
    expect(result.length, 0);
  });

  test('Medication before on', () {
    List<MedOnOffLog> result = calculateOnOff([
      Logg(timestamp: '2022-01-01 12:00', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 00:01', event: LoggType.on.name),
    ]);
    expect(result.length, 1);
    expect(
      result[0],
      equals(MedOnOffLog(DateTime.parse('2022-01-01 12:00'), DateTime.parse('2022-01-01 12:00'), null)),
      reason: "$result Should start as on when the last status before med was on",
    );
  });

  test('Always on except after first dose in the morning', () {
    List<MedOnOffLog> result = calculateOnOff([
      Logg(timestamp: '2022-01-01 07:00', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 10:50', event: LoggType.on.name),
      Logg(timestamp: '2022-01-01 11:01', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 14:59', event: LoggType.on.name),
      Logg(timestamp: '2022-01-01 15:00', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 18:45', event: LoggType.on.name),
      Logg(timestamp: '2022-01-01 19:01', event: LoggType.medicineTaken.name),
    ]);
    expect(result.length, 4);
    expect(
      result,
      equals([
        anOnOffLog('07:00', '10:50', null, nextMed: '11:01'),
        anOnOffLog('11:01', '11:01', null, nextMed: '15:00', prevMed: '07:00'),
        anOnOffLog('15:00', '15:00', null, nextMed: '19:01', prevMed: '11:01'),
        anOnOffLog('19:01', '19:01', null, prevMed: '15:00'),
      ]),
      reason: "$result Should have four medOnOffLogs, first on period starting later",
    );
  });

  test('Always on Scenario with four medOnOffLogs', () {
    List<MedOnOffLog> result = calculateOnOff([
      Logg(timestamp: '2022-01-01 00:50', event: LoggType.on.name),
      Logg(timestamp: '2022-01-01 07:00', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 11:01', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 15:00', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 19:01', event: LoggType.medicineTaken.name),
    ]);
    expect(result.length, 4);
    expect(
      result,
      equals([
        anOnOffLog('07:00', '07:00', null, nextMed: '11:01'),
        anOnOffLog('11:01', '11:01', null, nextMed: '15:00', prevMed: '07:00'),
        anOnOffLog('15:00', '15:00', null, nextMed: '19:01', prevMed: '11:01'),
        anOnOffLog('19:01', '19:01', null, prevMed: '15:00'),
      ]),
      reason: "$result Should have four medOnOffLogs, starting as on",
    );
  });

  test('Scenario with four meds, ons and offs', () {
    List<MedOnOffLog> result = calculateOnOff([
      Logg(timestamp: '2022-01-01 07:00', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 07:50', event: LoggType.on.name),
      Logg(timestamp: '2022-01-01 10:50', event: LoggType.off.name),
      Logg(timestamp: '2022-01-01 11:01', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 11:40', event: LoggType.on.name),
      Logg(timestamp: '2022-01-01 14:37', event: LoggType.off.name),
      Logg(timestamp: '2022-01-01 15:00', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 16:40', event: LoggType.on.name),
      Logg(timestamp: '2022-01-01 18:21', event: LoggType.off.name),
      Logg(timestamp: '2022-01-01 19:01', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 19:40', event: LoggType.on.name),
      Logg(timestamp: '2022-01-01 23:21', event: LoggType.off.name),
    ]);
    expect(result.length, 4);
    expect(
      result,
      equals([
        anOnOffLog('07:00', '07:50', '10:50', prevMed: null, nextMed: '11:01'),
        anOnOffLog('11:01', '11:40', '14:37', prevMed: '07:00', nextMed: '15:00'),
        anOnOffLog('15:00', '16:40', '18:21', prevMed: '11:01', nextMed: '19:01'),
        anOnOffLog('19:01', '19:40', '23:21', prevMed: '15:00'),
      ]),
      reason: "$result Should have four medOnOffLogs, starting as on",
    );
  });

  // ids are added because equality is affected by the id for Logg objects
  // and ids are randomly generated if they are not provided
  // Assertions in the other tests compare MedOnOffLogs which do not have an id
  test('getSortedMedList should return only med-events in chronoloigical order', () {
    List<Logg> result = getSortedMedList([
      Logg(id: "2", timestamp: '2022-01-01 12:00', event: LoggType.medicineTaken.name),
      Logg(id: "4", timestamp: '2022-01-01 18:10', event: LoggType.medicineTaken.name),
      Logg(id: "5", timestamp: '2022-01-01 18:10', event: LoggType.on.name),
      Logg(id: "6", timestamp: '2022-01-01 00:00', event: LoggType.on.name),
      Logg(id: "1", timestamp: '2022-01-01 00:10', event: LoggType.medicineTaken.name),
      Logg(id: "7", timestamp: '2022-01-01 12:00', event: LoggType.off.name),
      Logg(id: "8", timestamp: '2022-01-01 13:37', event: LoggType.on.name),
      Logg(id: "3", timestamp: '2022-01-01 12:01', event: LoggType.medicineTaken.name),
    ]);

    expect(
      result,
      equals([
        Logg(id: "1", timestamp: '2022-01-01 00:10', event: LoggType.medicineTaken.name),
        Logg(id: "2", timestamp: '2022-01-01 12:00', event: LoggType.medicineTaken.name),
        Logg(id: "3", timestamp: '2022-01-01 12:01', event: LoggType.medicineTaken.name),
        Logg(id: "4", timestamp: '2022-01-01 18:10', event: LoggType.medicineTaken.name),
      ]),
      reason:
          "$result should only contain ${LoggType.medicineTaken.name} and be ordered by timestamp in increasing order",
    );
  });
}

const testDate = '2022-01-01';
MedOnOffLog anOnOffLog(String med, String on, String? off, {String? prevMed, String? nextMed}) {
  return MedOnOffLog(
    DateTime.parse('$testDate $med'),
    DateTime.parse('$testDate $on'),
    off != null ? DateTime.parse('$testDate $off') : null,
    tprevmed: prevMed != null ? DateTime.parse('2022-01-01 $prevMed') : null,
    tnextmed: nextMed != null ? DateTime.parse('2022-01-01 $nextMed') : null,
  );
}

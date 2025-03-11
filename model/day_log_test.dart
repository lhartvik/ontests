import 'package:flutter_test/flutter_test.dart';
import 'package:onlight/model/day_log.dart';
import 'package:onlight/model/logg.dart';
import 'package:onlight/model/logg_type.dart';

void main() {
  test('Creates an empty daylog when no logs are submitted', () {
    final DayLog dayLog = DayLog('2022-01-01', []);
    expect(dayLog.day, '2022-01-01');
    expect(dayLog.logs, []);
    expect(dayLog.medOnOffLogs, []);
  });

  test('Creates a daylog with one log', () {
    final DayLog dayLog = DayLog('2022-01-01', [Logg(timestamp: '2022-01-01 12:00', event: 'on')]);
    expect(dayLog.day, '2022-01-01');
    expect(dayLog.logs.length, 1);
    expect(dayLog.medOnOffLogs.length, 0);
  });

  test('Creates a daylog with one medonofflog', () {
    final DayLog dayLog = DayLog('2022-01-01', [
      Logg(timestamp: '2022-01-01 12:00', event: LoggType.medicineTaken.name),
      Logg(timestamp: '2022-01-01 12:01', event: LoggType.on.name),
    ]);
    expect(dayLog.day, '2022-01-01');
    expect(dayLog.logs.length, 2, reason: "Should reflect number of submitted logs");

    final res = dayLog.medOnOffLogs;

    expect(res.length, 1, reason: "Should result in 1 medonoff-log");
  });
}

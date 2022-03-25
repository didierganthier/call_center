import 'dart:async';
import 'dart:math';

import 'package:async/async.dart' show StreamGroup;

class CallCenter {
  List<Responder> workers = [];
  List<Responder> managers = [];
  List<Responder> directors = [];
  List<List<Responder>> allProcessors = [];
  List<Call> queueCalls = [];

  StreamController<List<List<Responder>>> _responderStream = StreamController();
  StreamController<List<Call>> _queue = StreamController();
  Stream changes = Stream.empty();

  CallCenter() {
    workers.addAll([
      Responder(type: ResponderType.Worker, name: "Responder A"),
      Responder(type: ResponderType.Worker, name: "Responder B"),
      Responder(type: ResponderType.Worker, name: "Responder C"),
      Responder(type: ResponderType.Worker, name: "Responder D"),
    ]);

    managers.addAll([
      Responder(type: ResponderType.Manager, name: "Manager A"),
      Responder(type: ResponderType.Manager, name: "Manager B"),
      Responder(type: ResponderType.Manager, name: "Manager C"),
    ]);

    directors.addAll([
      Responder(type: ResponderType.Director, name: "Director A"),
      Responder(type: ResponderType.Director, name: "Director B"),
    ]);

    allProcessors.add(workers);
    allProcessors.add(managers);
    allProcessors.add(directors);

    changes = StreamGroup.merge([_responderStream.stream, _queue.stream]);
  }

  dispatchCall(Call call) {
    Responder processor =
        Responder(type: ResponderType.Worker, name: "Responder A");

    for (var i = 0; i < allProcessors.length; i++) {
      try {
        processor = allProcessors[i].firstWhere((Responder r) => !r.isBusy());
      } catch (e) {
        print("Switching to next processor");
        continue;
      }
      if (processor != null) {
        break;
      }
    }
    if (processor == null) {
      queueCalls.add(call);
      print("Call queued");
      _queue.sink.add(queueCalls);
    } else {
      processor.respondToCall(call);
      print("Call dispatched");
      call.addEndCallback(callEnded);
      _responderStream.sink.add(allProcessors);
    }
  }

  callEnded() {
    _responderStream.sink.add(allProcessors);
    if (queueCalls.length > 0) {
      dispatchCall(queueCalls[0]);
      queueCalls.removeAt(0);
      _queue.sink.add(queueCalls);
    }
  }

  endRandomCall() {
    Random random = Random();
    var groupRandom = random.nextInt(allProcessors.length);
    var subGroupRandom = random.nextInt(allProcessors[groupRandom].length);
    allProcessors[groupRandom][subGroupRandom].endCurrentCall();
  }
}

class Call {
  String msg;
  List<Function> endCallbacks = [];

  Call({required this.msg});

  addEndCallback(Function callback) {
    endCallbacks.add(callback);
  }

  endCall() {
    endCallbacks.forEach((callback) => callback());
  }
}

enum ResponderType { Manager, Director, Worker }

class Responder {
  final ResponderType type;
  Call call = Call(msg: 'Hello');
  final String name;

  Responder({required this.type, required this.name});

  void respondToCall(Call incoming) {
    if (isBusy()) {
      throw ResponderBusyException('Responder $name of type $type is busy.');
    }
    call = incoming;
  }

  bool isBusy() {
    return this.call != null;
  }

  endCurrentCall() {
    if (this.isBusy()) {
      var temp = call;
      call = Call(msg: 'Call ended');
      temp.endCall();
    }
  }
}

class ResponderBusyException implements Exception {
  String msg;

  ResponderBusyException(this.msg);
}

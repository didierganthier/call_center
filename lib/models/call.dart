class CallCenter {
  List<Responder> workers = [];
  List<Responder> managers = [];
  List<Responder> directors = [];
  List<List<Responder>> allProcessors = [];
  List<Call> queueCalls = [];

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
  ResponderType type;
  String name;

  Responder({required this.type, required this.name});

  respondToCall(Call call) {}

  isBusy() {}

  endCurrentCall() {}
}

class ResponderBusyException implements Exception {
  String msg;

  ResponderBusyException(this.msg);
}

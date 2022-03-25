import 'dart:math';

import 'package:call_center/models/call.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CallCenter callCenter = CallCenter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Call Center'),
        ),
        body: StreamBuilder(
            stream: callCenter.changes,
            builder: (context, snapshot) {
              return Column(
                children: _buildBody() +
                    [_buildButton()] +
                    [_buildQueueView(callCenter.queueCalls)],
              );
            }),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 50.0,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    List<Widget> result = [];
    callCenter.allProcessors
        .forEach((group) => result.add(_buildResponderRow(group)));
    return result;
  }

  Widget _buildResponderRow(List<Responder> group) {
    return Container(
      height: 100.0,
      child: ListView.builder(
        itemCount: group.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _buildResponderView(group[index]);
        },
      ),
    );
  }

  Widget _buildResponderView(Responder responder) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          responder.name,
          style: TextStyle(
              color: responder.isBusy() ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.call_end),
          onPressed: responder.isBusy() ? responder.endCurrentCall : null,
        )
      ]),
    );
  }

  addCall() {
    var random = Random();
    callCenter.dispatchCall(Call(msg: "Customer #${random.nextInt(50)}"));
  }

  endCall() {
    callCenter.endRandomCall();
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: RaisedButton.icon(
            icon: Icon(Icons.call),
            onPressed: addCall,
            label: Text("Add Call"),
          ),
        ),
        RaisedButton.icon(
          icon: Icon(Icons.call_made),
          onPressed: endCall,
          label: Text("End Random Call"),
        )
      ],
    );
  }

  Widget _buildQueueView(List<Call> queueCalls) {
    return Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: queueCalls.map((call) => Text(call.msg)).toList());
  }
}

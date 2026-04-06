abstract class GameEvent {}

// host button
class HostPressed extends GameEvent {
  final int port;
  HostPressed(this.port);
}

// join button
class JoinPressed extends GameEvent {
  final String host;
  final int port;
  JoinPressed(this.host, this.port);
}

// start button
class StartGamePressed extends GameEvent {}

// socket message
class MessageReceived extends GameEvent {
  final Map<String, dynamic> message;
  MessageReceived(this.message);
}

// rack click
class RackTilePressed extends GameEvent {
  final int index;
  RackTilePressed(this.index);
}

// board click
class BoardCellPressed extends GameEvent {
  final int row;
  final int col;
  BoardCellPressed(this.row, this.col);
}

// end button
class EndTurnPressed extends GameEvent {}

// host input
class HostInputChanged extends GameEvent {
  final String host;
  HostInputChanged(this.host);
}

// port input
class PortInputChanged extends GameEvent {
  final String port;
  PortInputChanged(this.port);
}
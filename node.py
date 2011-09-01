import zmq
import atexit
import socket

class Node:
  def __init__(self, endpoint=None):
    if endpoint:
      self.endpoint = endpoint
    else:
      self.endpoint = "tcp://127.0.0.1:%s" % self.next_available_port()
    self.ctx = zmq.Context()
    self.socket = self.ctx.socket(zmq.REP)
    self.store = {}
    def close_ctx():
      self.socket.close(); self.ctx.term()
    atexit.register(close_ctx)

  def serve(self):
    self.socket.bind(self.endpoint)
    print("Node starting on %s" % self.endpoint)
    while True:
      data = self.socket.recv()
      self.process(data)

  def process(self, data):
    properties = data.split(":", 3)
    instruction = properties[0]
    key = properties[1] if len(properties) > 1 else None
    value = properties[2] if len(properties) > 2 else None
    if instruction == "LIST":
      def translate(string):
        return string.replace(",", "%2C")
      keys = ",".join(map(translate, self.store.keys()))
      self.send("ACKLIST", keys)
    elif instruction == "SET":
      v = self.store[key] = value
      self.send("ACKSET", v)
    elif instruction == "GET":
      value = self.store[key] if self.store.has_key(key) else ""
      self.send("ACKGET", value)
    elif instruction == "DELETE":
      value = self.store.pop(key) if self.store.has_key(key) else ""
      self.send("ACKDELETE", value)

  def register(self, endpoint):
    client = self.ctx.socket(zmq.REQ)
    client.connect(endpoint)
    self.send("NODE", self.endpoint.replace(":", "%3A"), client)
    client.recv()
    def notify_close():
      self.send("NODEGONE", self.endpoint.replace(":", "%3A"), client)
      client.recv()
      client.close()
    atexit.register(notify_close)
    self.serve()

  def next_available_port(self):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(("",0))
    s.listen(1)
    port = s.getsockname()[1]
    s.close()
    return port

  def send(self, key, value, socket=None):
    socket = socket if socket else self.socket
    return socket.send("%s:%s" % (key.upper(), value), zmq.NOBLOCK)

if __name__ == '__main__':
  Node().register('tcp://127.0.0.1:6789')

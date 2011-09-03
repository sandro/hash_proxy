HashProxy
=========

A distributed, persistent, key/value store providing language-agnostic
storage-engines.

Requirements
------------
* ZeroMQ
* ConsistentHashr gem

Example
-------

1. Start a node to store data

    `bundle exec bin/hash-proxy-node`

2. Start the proxy server

    `bundle exec bin/hash-proxy`

3. Connect the client to the proxy

```
$ bundle console
>> c = HashProxy::Client.new
=> #<HashProxy::Client:0x00000100b7ff38 @endpoint="tcp://127.0.0.1:6789", @ctx=#<ZMQ::Context:0x00000100b7fee8>, @socket=#<ZMQ::Socket:0x00000100b7fec0>>
>> c.get('key')
=> nil
>> c.set('key', 'value')
=> "value"
>> c.get('key')
=> "value"
>> c.list
=> ["key"]
>> c.delete('key')
=> "value"
>> c.get('key')
=> nil
>> c.list
=> []
```

4. Start a new node

    `bundle exec bin/hash-proxy-node`
    close the old one with CTRl-C
    check `c.list`, the array will be empty

5. Check the dump (persistence)

    The 'dump' log is written out every second if 1000 entries have been made.
    `$ cat dump`

6. The log gets restructured (truncated) every 15 seconds, leaving only the relevant changes.

7. Restarting the server when the log is present will redistribute the key-value pairs to all of the nodes present.

8. Because zmq is the transport protocol, nodes can be written in any language (with a zmq driver). Check out node.py as an example (python node.py).

9. Don't need the persistence or distribution? Connect directly to a node. A small benchmark shows it to be twice as fast.

```
$ bundle exec bin/hash-proxy-node serve
$ bundle console
>> c = HashProxy::Client.new
>> c.set('foo', 'bar')
>> c.get('foo')
```

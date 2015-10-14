# Elixir: A Talk For College Students

This was a talk made during CodeWeek 15 @ [Dept. Informática](http://www.di.uminho.pt), [UMinho](http://www.uminho.pt/en/home_en), for [CeSIUM](https://github.com/cesium).

This repository contains the code examples used during the talk plus a more complete version. It does not contain the best possible version, but a friendlier one, with lots of different resources.

Slides are available [here](https://speakerdeck.com/frmendes/elixir-a-talk-for-college-students).

## Queue

`queue` is the implementation of the Queue module used during the talk. Made using `GenServer`, it has 3 simple functionalities:

- **put**: add an element to the front of the queue
- **poll**: remove and return the first element of the queue
- **front**: show the first element of the queue (does not remove it)

## Server

`server/lib` contains several files and modules:

* `Server.V1` is an echo server that only accepts a single client at a time. It's the first example given during the talk.
* `Server.V2` is that same echo server, using pattern matching to fix the crash issue.
* `Server.V3` accepts multiple clients simultaneously, but only echos back at them. First use of Supervisors.
* `Server` is the first of three modules that implement a simple TCP chat. It's the parent, accepting module.
* `Server.Handler` is the second of these three modules. It creates a messenger and stands by, waiting for messages to send to its client.
* `Server.Messenger` is the last module that composes the server. It listens to messages sent by its client and spreads them across every `Server.Handler` connected.

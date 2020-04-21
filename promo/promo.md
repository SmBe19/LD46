IT and cloud hosting is a fast-growing business, and after spotting
a job offering at shoutr.io requiring no prior knowledge, you decided to apply.
Against all expectations, you actually got the job!

## How to play

You interact with the system using a programmer's favourite tool: the terminal.
It is very simple: type a command and press return to execute it.

You can open the built-in tutorial by typing `tutorial` and pressing return.

If you are already familiar with UNIX-style command line interfaces, you might
already feel at home as the most-used commands are also available here.

## Goals

Your goal is to grow shoutr.io into a large and successful tech company, and to
eventually even provide a cloud platform to host other people's applications.

You start off with a small userbase, who each send requests to your infrastructure.
Keep ahead of the growing demand to avoid congestion, and the growth will continue.


If you encounter problems with the CRT monitor effect, you can turn it off
using the switch at the bottom right.

## Hints

The game has many little commands that might help you out. First you should play through the tutorial. If `tutorial` doesn't give you what you're looking for, try pressing `TAB` in a new line to see a list of commands. Each command has a documentation that can be read using `man [command]`.

If you're wondering about services and requests, use `man list` to see all that you have unlocked. Then `man [request/service]` will tell you how to handle them.

### Managing server load

Later in the game it is easy to struggle at getting the most out of upgraded servers. There are four resources on each server that all have to be scaled up correctly.

*CPU: *The CPU decides how many cycles are available per tick. If a service uses less than the number of cycles your CPU can provide, it is worth installing that service multiple times. A single service should be installed at most so many times that the sum of cycle requirements matches the CPU cycle capability. I.e. install 4 nginx services that each take 256 M Cycles on a server with a 1024 Mhz CPU.

*RAM: *RAM decides how many processes the server can run in parallel. Services only use RAM while they're processing requests. A server should have enough RAM to saturate the CPU usage. A server with 4 nginx services (4x0.25GB RAM) and 4 database services (4x1GB RAM) and a 1024 MHz CPU will require between 1 to 4 GB RAM under full load. So it should have at least 4GB RAM.

*HDD: *Hard disk space decides how many services can be installed on a server. Upgrade it as necessary when unable to install services required to saturate the server's other resources.

*Queue: *The queue not only decides how many requests the server can store, but also limits the bandwidth of incoming requests. See the Downloading Requests section when running the `queue` command. The maximum bandwidth can be calculated by dividing the queue size by the connection delay (find out using ping). As a rule of thumb, if the server is not at 100% CPU load nor 100% RAM load, yet the queue is full that means the bandwidth is too small.

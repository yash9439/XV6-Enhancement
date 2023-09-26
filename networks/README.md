# Mini Project 2: Networking Specification

## Part A: Using Library Functions

### Task Description
Implement the following programs within the `<mini-project2-directory>/networks/partA/basic` directory:

1. TCP server program
2. TCP client program
3. UDP server program
4. UDP client program

The client programs must send text to the server and receive text from the server. Ensure that you check for all possible errors by verifying the return status of relevant functions.

### Implementation

You can use the following libraries:
- `arpa/inet.h`
- `sys/types.h`
- `sys/socket.h`
- `netinet/in.h`

Resources for reference:
- [Socket Programming Slides](https://www.csd.uoc.gr/~hy556/material/tutorials/cs556-3rd-tutorial.pdf)
- [TCP Client and Server in C](https://github.com/nikhilroxtomar/TCP-Client-Server-Implementation-in-C)
- [UDP Client and Server in C](https://github.com/nikhilroxtomar/UDP-Client-Server-implementation-in-C)
- `man` pages

#### Rock, Paper, Scissors Game (UDP and TCP)

1. Start a server that listens for two clients on different ports.
2. Start `clientA` and `clientB`.
3. Both clients enter their decisions (e.g., 0 for Rock, 1 for Paper, 2 for Scissors).
4. The server receives the decisions from both clients.
5. The server deliberates and returns its judgment to both clients.
6. Clients display the judgment ("Win," "Lost," "Draw").
7. Implement this process in a loop so that clients are prompted for another game after the judgment. The next game starts only if both clients agree (handle this using the server).

### Directory Structure
```
<mini-project2-directory>/
└── networks/
    └── partA/
        ├── basic/
        │   ├── TCP_server.c
        │   ├── TCP_client.c
        │   ├── UDP_server.c
        │   └── UDP_client.c
        └── rpc/
            ├── TCP_RPS_server.c
            ├── TCP_RPS_clientA.c
            ├── TCP_RPS_clientB.c
            ├── UDP_RPS_server.c
            ├── UDP_RPS_clientA.c
            └── UDP_RPS_clientB.c
```

## Part B: Implementing TCP Functionality Using UDP

### Task Description
Implement some TCP functionality using UDP sockets to understand networking concepts.

#### Functionalities to Implement

1. **Data Sequencing**: The receiver must divide the data (assume some text) into smaller chunks of a fixed size. Each chunk is assigned a number, which is sent along with the transmission using structs.

2. **Retransmissions**: The client must send an ACK message (with the sequence number) to the server upon receiving a transmission. The server should retransmit the data if it doesn't receive the ACK within some time. However, the server shouldn't wait for an ACK before sending the next transmission. For implementation's sake, send ACK messages randomly to check whether retransmission is working.

### Report (8 marks)

1. **Difference from Traditional TCP**: Explain how your implementation of data sequencing and retransmission differs from traditional TCP. (3 marks)

2. **Extending for Flow Control**: Describe how you can extend your implementation to account for flow control, while ignoring deadlocks. (5 marks)

### Directory Structure
```
<mini-project2-directory>/
└── networks/
    └── partB/
        ├── TCP_over_UDP_server.c
        ├── TCP_over_UDP_client.c
        └── report.md
```

## Submission Format

Please submit your implementations and report as specified above. The report should be in Markdown format and address the questions posed in Part B.
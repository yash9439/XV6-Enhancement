# TCP Functionality Implementation Report

## Introduction
In this project, we implemented certain aspects of TCP functionality using UDP sockets. Specifically, we focused on data sequencing and retransmission. This report discusses the details of our implementation and how it differs from traditional TCP. Additionally, we explore the possibility of extending our implementation to account for flow control.

## Data Sequencing
In our implementation, the receiver divides the incoming data (text in our case) into smaller chunks of a fixed size. Each chunk is assigned a sequence number, and this sequence number is sent along with the data in a custom-defined struct. This allows us to maintain the order of data packets and reconstruct the original data at the receiver's end.

### Differences from Traditional TCP
- In traditional TCP, data sequencing is done using a sequence number in the TCP header. This sequence number is incremented for each segment sent. In our UDP-based implementation, we include the sequence number in the data payload itself, as UDP does not have header fields for sequence numbers.
- TCP uses a sliding window mechanism for flow control, which ensures that the sender does not overwhelm the receiver. In our implementation, we have not implemented a full sliding window mechanism but have focused on sequencing and retransmission.

## Retransmissions
The client in our implementation sends an acknowledgment (ACK) message to the server upon receiving a data transmission. The ACK message contains the sequence number of the received data. If the server does not receive an ACK within some time, it retransmits the data. To simulate the randomness of network conditions, we also introduced random ACK messages from the client to check whether retransmission is working.

### Differences from Traditional TCP
- In traditional TCP, retransmissions are controlled by TCP's Retransmission Timeout (RTO) mechanism. TCP sets a timeout for each segment it sends and retransmits if an ACK is not received within this timeout. Our implementation uses a simplified approach with random ACKs for demonstration purposes.

## Extending for Flow Control
To extend our implementation to account for flow control similar to TCP, we can introduce a sliding window mechanism. The sender would keep track of the available window size at the receiver's end. The sender would only send data if there is available space in the receiver's window. This would prevent the sender from overwhelming the receiver with data.

### Steps to Implement Flow Control
1. Maintain a sliding window at the receiver's end, indicating the available buffer space.
2. The sender should only send data if there is space available in the receiver's window.
3. The receiver can advertise its window size in ACK messages to inform the sender about the available space.
4. The sender can adjust its sending rate based on the receiver's advertised window size, ensuring efficient and controlled data transfer.

## Conclusion
In this project, we successfully implemented data sequencing and retransmission functionalities using UDP sockets. While our implementation differs from traditional TCP in some aspects, it serves as a simplified demonstration of TCP-like behavior. To extend our implementation for flow control, we would need to incorporate a sliding window mechanism similar to TCP.

This project allowed us to gain insights into the fundamental principles of TCP and its mechanisms for data sequencing, retransmission, and flow control.

---
Author: Yash Bhaskar

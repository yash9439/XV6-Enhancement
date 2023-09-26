#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define SERVER_PORT 12345
#define MAX_DATA_SIZE 100
#define MAX_PACKET_SIZE (sizeof(struct Packet))

struct Packet {
    int seq_num;
    char data[MAX_DATA_SIZE];
};

int main() {
    int sockfd;
    struct sockaddr_in server_addr;
    struct Packet packet;
    int seq_num = 0;

    // Create UDP socket
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
        perror("socket");
        exit(1);
    }

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(SERVER_PORT);
    server_addr.sin_addr.s_addr = INADDR_ANY;

    // Bind socket
    if (bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1) {
        perror("bind");
        exit(1);
    }

    while (1) {
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);

        // Receive data from the client
        if (recvfrom(sockfd, &packet, MAX_PACKET_SIZE, 0, (struct sockaddr *)&client_addr, &client_len) == -1) {
            perror("recvfrom");
            continue;
        }

        // Simulate ACK messages randomly
        if (rand() % 5 != 0) {
            printf("Received packet with sequence number %d\n", packet.seq_num);
        } else {
            printf("Simulating ACK loss for sequence number %d\n", packet.seq_num);
        }

        // Simulate retransmission (send the packet again)
        sendto(sockfd, &packet, MAX_PACKET_SIZE, 0, (struct sockaddr *)&client_addr, client_len);
    }

    close(sockfd);
    return 0;
}

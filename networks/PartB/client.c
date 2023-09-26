#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define SERVER_IP "127.0.0.1"  // Change this to the server's IP address if needed
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
    server_addr.sin_addr.s_addr = inet_addr(SERVER_IP);

    while (1) {
        // Prepare a packet with a sequence number
        packet.seq_num = seq_num;
        snprintf(packet.data, sizeof(packet.data), "Packet with seq %d", seq_num);

        // Send the packet to the server
        sendto(sockfd, &packet, MAX_PACKET_SIZE, 0, (struct sockaddr *)&server_addr, sizeof(server_addr));

        // Wait for ACK (or simulate waiting)
        usleep(100000);  // Sleep for 100ms (simulate a delay)

        // Increment the sequence number
        seq_num++;

        // Simulate packet loss (do not increment seq_num)
        if (rand() % 5 == 0) {
            printf("Simulating packet loss for sequence number %d\n", packet.seq_num);
        }
    }

    close(sockfd);
    return 0;
}

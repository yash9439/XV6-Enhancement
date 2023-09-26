#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define SERVER_IP "127.0.0.1"
#define PORT_TCP 12345
#define PORT_UDP 12346
#define BUFFER_SIZE 1024

int main() {
    int tcp_client_socket, udp_client_socket;
    struct sockaddr_in server_tcp_addr, server_udp_addr;
    char buffer[BUFFER_SIZE];
    char play_again;
    int choice;

    // Create TCP client socket
    tcp_client_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (tcp_client_socket < 0) {
        perror("Error in TCP socket");
        exit(1);
    }

    // Create UDP client socket
    udp_client_socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (udp_client_socket < 0) {
        perror("Error in UDP socket");
        exit(1);
    }

    server_tcp_addr.sin_family = AF_INET;
    server_tcp_addr.sin_port = htons(PORT_TCP);
    server_tcp_addr.sin_addr.s_addr = inet_addr(SERVER_IP);

    server_udp_addr.sin_family = AF_INET;
    server_udp_addr.sin_port = htons(PORT_UDP);
    server_udp_addr.sin_addr.s_addr = inet_addr(SERVER_IP);

    // Connect to the server using TCP
    if (connect(tcp_client_socket, (struct sockaddr*)&server_tcp_addr, sizeof(server_tcp_addr)) < 0) {
        perror("Error in TCP connection");
        exit(1);
    }

    while (1) {
        // Game logic here: Ask the user for their choice (0 for Rock, 1 for Paper, 2 for Scissors)
        printf("Enter your choice (0 for Rock, 1 for Paper, 2 for Scissors): ");
        scanf("%d", &choice);

        // Send the choice to the server
        send(tcp_client_socket, &choice, sizeof(choice), 0);

        // Receive game result from the server
        recv(tcp_client_socket, buffer, BUFFER_SIZE, 0);
        printf("Result: %s\n", buffer);

        // Prompt for playing again
        printf("Play again? (y/n): ");
        scanf(" %c", &play_again);

        // Send play again response to the server
        send(tcp_client_socket, &play_again, sizeof(play_again), 0);

        if (play_again == 'n' || play_again == 'N') {
            break; // Exit the loop
        }
    }

    // Close TCP client socket
    close(tcp_client_socket);

    return 0;
}
// Server code
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT_TCP 12345
#define PORT_UDP 12346
#define BUFFER_SIZE 1024

// Function to determine the winner based on the game rules
int determineWinner(int choice1, int choice2) {
    // 0: Rock, 1: Paper, 2: Scissors
    if (choice1 == choice2) {
        return 0; // Draw
    } else if ((choice1 == 0 && choice2 == 2) || (choice1 == 1 && choice2 == 0) || (choice1 == 2 && choice2 == 1)) {
        return 1; // Player 1 wins
    } else {
        return 2; // Player 2 wins
    }
}

int main() {
    int tcp_server_socket, udp_server_socket;
    struct sockaddr_in tcp_server_addr, udp_server_addr;
    char buffer[BUFFER_SIZE];
    char play_again;
    int choice1, choice2, result;

    // Create TCP server socket
    tcp_server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (tcp_server_socket < 0) {
        perror("Error in TCP socket");
        exit(1);
    }

    // Create UDP server socket
    udp_server_socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (udp_server_socket < 0) {
        perror("Error in UDP socket");
        exit(1);
    }

    tcp_server_addr.sin_family = AF_INET;
    tcp_server_addr.sin_port = htons(PORT_TCP);
    tcp_server_addr.sin_addr.s_addr = INADDR_ANY;

    udp_server_addr.sin_family = AF_INET;
    udp_server_addr.sin_port = htons(PORT_UDP);
    udp_server_addr.sin_addr.s_addr = INADDR_ANY;

    // Bind TCP server socket
    if (bind(tcp_server_socket, (struct sockaddr*)&tcp_server_addr, sizeof(tcp_server_addr)) < 0) {
        perror("Error in TCP binding");
        exit(1);
    }

    // Bind UDP server socket
    if (bind(udp_server_socket, (struct sockaddr*)&udp_server_addr, sizeof(udp_server_addr)) < 0) {
        perror("Error in UDP binding");
        exit(1);
    }

    printf("Server is listening...\n");

    while (1) {
        int client1_socket, client2_socket;

        // TCP: Listen for client1
        if (listen(tcp_server_socket, 1) == 0) {
            printf("Waiting for Client 1...\n");
        } else {
            perror("Error in TCP listening");
            exit(1);
        }

        // Accept client1 connection
        client1_socket = accept(tcp_server_socket, NULL, NULL);
        if (client1_socket < 0) {
            perror("Error in accepting client1");
            exit(1);
        }
        printf("Client 1 connected.\n");

        // TCP: Listen for client2
        if (listen(tcp_server_socket, 1) == 0) {
            printf("Waiting for Client 2...\n");
        } else {
            perror("Error in TCP listening");
            exit(1);
        }

        // Accept client2 connection
        client2_socket = accept(tcp_server_socket, NULL, NULL);
        if (client2_socket < 0) {
            perror("Error in accepting client2");
            exit(1);
        }
        printf("Client 2 connected.\n");

        do {
            // Receive choices from clients
            recv(client1_socket, &choice1, sizeof(choice1), 0);
            recv(client2_socket, &choice2, sizeof(choice2), 0);

            result = determineWinner(choice1, choice2);

            // Send game result to both clients
            sprintf(buffer, "Player 1 chose %d, Player 2 chose %d. Result: ", choice1, choice2);

            if (result == 0) {
                strcat(buffer, "It's a Draw!");
            } else if (result == 1) {
                strcat(buffer, "Player 1 Wins!");
            } else {
                strcat(buffer, "Player 2 Wins!");
            }

            send(client1_socket, buffer, strlen(buffer), 0);
            send(client2_socket, buffer, strlen(buffer), 0);

            // Prompt clients to play again
            printf("Play again? (y/n): ");
            scanf(" %c", &play_again);
            send(client1_socket, &play_again, sizeof(play_again), 0);
            send(client2_socket, &play_again, sizeof(play_again), 0);

            // Receive play again response from both clients
            recv(client1_socket, &play_again, sizeof(play_again), 0);
            recv(client2_socket, &play_again, sizeof(play_again), 0);

        } while (play_again == 'y' || play_again == 'Y');

        // Close client sockets
        close(client1_socket);
        close(client2_socket);
    }

    // Close server sockets
    close(tcp_server_socket);
    close(udp_server_socket);

    return 0;
}

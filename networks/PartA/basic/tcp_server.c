#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 12345
#define BUFFER_SIZE 1024

int main() {
    int server_socket, new_socket;
    struct sockaddr_in server_addr, new_addr;
    socklen_t addr_size;
    char buffer[BUFFER_SIZE];

    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket < 0) {
        perror("Error in socket");
        exit(1);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = PORT;
    server_addr.sin_addr.s_addr = INADDR_ANY;

    if (bind(server_socket, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("Error in binding");
        exit(1);
    }

    if (listen(server_socket, 10) == 0) {
        printf("Listening...\n");
    } else {
        printf("Error in listening\n");
        exit(1);
    }

    addr_size = sizeof(new_addr);
    new_socket = accept(server_socket, (struct sockaddr*)&new_addr, &addr_size); // Accept connection

    // Receive data from client
    recv(new_socket, buffer, BUFFER_SIZE, 0);
    printf("Received from client: %s\n", buffer);

    // Send a response to the client
    strcpy(buffer, "Hello from server");
    send(new_socket, buffer, strlen(buffer), 0);

    close(new_socket);
    close(server_socket);

    return 0;
}

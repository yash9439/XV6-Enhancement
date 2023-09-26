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
    int server_socket;
    struct sockaddr_in server_addr;
    char buffer[BUFFER_SIZE];

    server_socket = socket(AF_INET, SOCK_DGRAM, 0);
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

    printf("UDP Server is listening on port %d...\n", PORT);

    socklen_t addr_size;
    struct sockaddr_in client_addr;
    addr_size = sizeof(client_addr);

    recvfrom(server_socket, buffer, BUFFER_SIZE, 0, (struct sockaddr*)&client_addr, &addr_size);
    printf("Received from client: %s\n", buffer);

    strcpy(buffer, "Hello from server");
    sendto(server_socket, buffer, strlen(buffer), 0, (struct sockaddr*)&client_addr, addr_size);

    close(server_socket);

    return 0;
}

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
    int client_socket;
    struct sockaddr_in server_addr;
    char buffer[BUFFER_SIZE];

    client_socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (client_socket < 0) {
        perror("Error in socket");
        exit(1);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = PORT;
    server_addr.sin_addr.s_addr = INADDR_ANY;

    strcpy(buffer, "Hello from client");
    sendto(client_socket, buffer, strlen(buffer), 0, (struct sockaddr*)&server_addr, sizeof(server_addr));

    socklen_t addr_size;
    struct sockaddr_in server_response;
    addr_size = sizeof(server_response);

    recvfrom(client_socket, buffer, BUFFER_SIZE, 0, (struct sockaddr*)&server_response, &addr_size);
    printf("Received from server: %s\n", buffer);

    close(client_socket);

    return 0;
}

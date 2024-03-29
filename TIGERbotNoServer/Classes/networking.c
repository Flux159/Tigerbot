/**
 C networking library for Tigerbot (iPhone and ARM cross-compilable)
 Written by: Kevin Yuan Li
 */

/**
 * Library to setup a listening socket and
 * read/write to a client 
 *
 * some code from:
 * http://www.paulgriffiths.net/program/c/srcs/echoservsrc.html
 */

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <time.h>
#include <sys/time.h>

#include "networking.h"

int close_socket(int sockfd){
	return close(sockfd);
}

int serv_connect(char* server_ip, int server_port){
	fd_set w_set;
	int sockfd;
	struct timeval timeout;
	int err;
	struct sockaddr_in servaddr;
	sockfd = socket(AF_INET, SOCK_STREAM, 0);
	set_nonblocking(sockfd);
	
	bzero(&servaddr, sizeof(servaddr));
	//servaddr.sin_len = sizeof(servaddr);
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htons(server_port);
	//servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	inet_aton(server_ip, &servaddr.sin_addr);
	
   	err = connect(sockfd, (struct sockaddr*)&servaddr, sizeof(servaddr));
	
	FD_ZERO(&w_set);
	FD_SET(sockfd,&w_set);
	
	//Timeout time of 0.5 sec = 500000 usec
	timeout.tv_sec = 0;
	timeout.tv_usec = 500000;
	
	select(FD_SETSIZE,0,&w_set,0,&timeout);
	if(FD_ISSET(sockfd,&w_set)){
		return sockfd;
	}else {
		//Stop connect
		close_socket(sockfd);
		return -1;
	}

	//sleep(1);
	//if(errno == ENETUNREACH){
	//	return err;
	//}
	//return sockfd;
}

int accept_client(int sock){
	printf("waiting for client...\n");
	int client = accept(sock, NULL, NULL);
	return client;
}

void set_nonblocking(int newclientfd){
	int opts;

	setsockopt(newclientfd, SOL_SOCKET, SO_REUSEADDR, &opts, sizeof(opts));
                                                                                                     
	if((opts = fcntl(newclientfd, F_GETFL)) < 0){
		printf("Error getting Options\n");
	}

	opts = (opts|O_NONBLOCK);

	if(fcntl(newclientfd, F_SETFL, opts) < 0){
		printf("Error setting Options\n");
	}
	
}

int setup_socket(int port){
	struct sockaddr_in myaddr;
    int sock;
    int err = 0;
    int opts = 1;

    /* Create Socket */
    if((sock = socket(AF_INET,SOCK_STREAM,0)) < 0) {
        printf("socket error\n");
        return sock;
    }

    /* Set Options */
    setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,&opts,sizeof(opts));
    if((opts = fcntl(sock,F_GETFL))<0) {
        printf("fcntl (get)");
        return opts;
    }

	/*  Set Non Blocking*/
	
    opts = (opts | O_NONBLOCK);
    if((err = fcntl(sock,F_SETFL,opts))<0) {
        printf("fcntl (set)");
        return err;
	}
	

    /* Bind Socket */
    memset(&myaddr,'\0',sizeof((myaddr))); //zero myaddr                                    
    myaddr.sin_family = AF_INET;
    myaddr.sin_port = htons(port);
    myaddr.sin_addr.s_addr = htonl(INADDR_ANY);//bind to any local address                  


    if((err = bind(sock,(struct sockaddr*)&myaddr,sizeof(myaddr)) < 0)) {
        printf("bind error\n");
        return err;
    }

	/* Start Listening */
    if((err = listen(sock,5)) < 0) {
        printf("listen error\n");
        return err;
    }

	
	//convert int32 to dot format
	unsigned int ip_num = gethostid();
	unsigned short high = ip_num;
	unsigned short low = ip_num>>16;
	struct in_addr myip;
	myip.s_addr = (high<<16)|low;
    
    //Debugging printf
	//char *ip = inet_ntoa(myip);
	//printf("I am a server listening on ip address %s port %d for clients\n", ip, port);
	
	return sock;

}

ssize_t readline(int sockd, void *vptr, size_t maxlen) {
    size_t n;
	ssize_t rc;
    char    c, *buffer;

    buffer = vptr;

    for ( n = 1; n < maxlen; n++ ) {
		
		if ( (rc = read(sockd, &c, 1)) == 1 ) {
			*buffer++ = c;
			if ( c == '\n' )
				break;
		}
		else if ( rc == 0 ) {
			if ( n == 1 )
				return 0;
			else
				break;
		}
		else {
			if ( errno == EINTR )
				continue;
			return -1;
		}
    }

    *buffer = 0;
    return n;
}

ssize_t writeline(int sockd, const void *vptr, size_t n) {
    size_t      nleft;
    ssize_t     nwritten;
    const char *buffer;

    buffer = vptr;
    nleft  = n;

    while ( nleft > 0 ) {
		if ( (nwritten = write(sockd, buffer, nleft)) <= 0 ) {
			if ( errno == EINTR )
				nwritten = 0;
			else
				return -1;
		}
		nleft  -= nwritten;
		buffer += nwritten;
    }

    return n;
}

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>

int main() {
    void* buffer;
    int fd,hfd;
    int bytes;

    fd = open("/dev/sbd0",O_RDWR);
    buffer = mmap(NULL,524288, PROT_READ, MAP_PRIVATE, fd, 0);

    if (buffer == MAP_FAILED) {
        perror("mmap failed");
        return 1;
    }
 
    hfd  = open("/dev/honeypot", O_RDWR);
    if (hfd < 0 ){
            printf("Failed to open ");
            return 2;
    }
    bytes = write(hfd, buffer, 524288);
    if (bytes < 0){
        perror("failed to write");
        return 3;
    }
    printf("Going to sleep\n");
    sleep(1);
    printf("Touching memory, This would trigger the microvisor...\n");
    /*
    * Please examine /proc/hyplet_stats for changes
    */
   sleep(100);
}
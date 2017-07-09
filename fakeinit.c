#define _XOPEN_SOURCE 700
#include <signal.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/resource.h>

int main() {
    sigset_t set;
    int status, i;
    struct rlimit rlim;

    // what is max number of file descriptors?
    if (getrlimit(RLIMIT_NOFILE, &rlim) != 0) {
        return 1;
    }

    // let's close all file descriptors
    for (i = 0; i < (int)rlim.rlim_cur; i++) {
        close(i);
    }

    if (getpid() != 1) {
        return 1;
    }

    sigfillset(&set);
    sigprocmask(SIG_BLOCK, &set, 0);

    for (;;) {
        wait(&status);
    }
}


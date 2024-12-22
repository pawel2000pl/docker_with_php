#!/usr/bin/python3

import os
import subprocess
from sys import argv

def get_param(name, default):
    for v in argv[1:]:
        if not '=' in v: continue
        [argname, argvalue] = v.split('=')
        if argname == name:
            return argvalue
    return default

DEBUG = get_param("DEBUG", "false").lower() == "true"
NO_MAPPING = get_param("NO_MAPPING", "true").lower() == "true"
ASYNC = get_param("ASYNC", "false").lower() == "true"

BUILD_ARGS = []
RUN_FLAGS = []

if DEBUG:
    BUILD_ARGS.append("--build-arg")
    BUILD_ARGS.append("DEBUG=TRUE")
    RUN_FLAGS.append("-e")
    RUN_FLAGS.append("DEBUG=TRUE")

if not NO_MAPPING:
    RUN_FLAGS.append("--mount")
    RUN_FLAGS.append("type=bind,source=%s/application,target=/debug"%os.getcwd())
    RUN_FLAGS.append("--device")
    RUN_FLAGS.append("/dev/fuse")
    RUN_FLAGS.append("--privileged")

if ASYNC:
    RUN_FLAGS.append("-d")
else:
    RUN_FLAGS.append("-it")


def build_image():
    subprocess.run(["docker", "build"] + BUILD_ARGS + ["-t", "my_php_app", "."])


def remove_container():
    subprocess.run(["docker", "kill", "my_php_app"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    subprocess.run(["docker", "container", "rm", "-f", "my_php_app"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def run_container():
    remove_container()
    subprocess.run(["docker", "run", "--env-file", ".env"] + RUN_FLAGS + ["-p", "8080:80", "-p", "43443:443", "-p", "2222:22", "--name", "my_php_app", "my_php_app"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def remove_all_containers():
    subprocess.run(["docker", "container", "rm", "-f"] + subprocess.run(["docker", "container", "ls", "-aq"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True).stdout.splitlines(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def remove_image():
    remove_container()
    subprocess.run(["docker", "container", "rm", "-f", "my_php_app"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def shell_yes(command, yes_count=100):
    proc = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    proc.communicate(input='y\n' * yes_count)
    proc.wait()


def system_prune():
    remove_container()
    remove_all_containers()
    shell_yes(["docker", "builder", "prune"])
    shell_yes(["docker", "system", "prune", "-a"])
    

def forget_ssh():
    subprocess.run(["ssh-keygen", "-f", os.path.expanduser("~")+"/.ssh/known_hosts", "-R", "[localhost]:2222"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def all():
    build_image()
    run_container()
    

if __name__ == "__main__":
    if len(argv) == 1:
        all()
    command = argv[1]
    if command == 'all': all()
    elif command == 'image': build_image()
    elif command == 'run': run_container()
    elif command == 'remove-container': remove_container()
    elif command == 'remove-all': remove_all_containers()
    elif command == 'remove': remove_image()
    elif command == 'system-prune': system_prune()
    elif command == 'forget-ssh': forget_ssh()
    else: all()

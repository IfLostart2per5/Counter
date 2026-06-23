from platform import system
OS = system()

if OS == "Windows":
    from buildwindows import build
else:
    from buildlinux import build

build("Usable")
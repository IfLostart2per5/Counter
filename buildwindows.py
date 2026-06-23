from pathlib import Path
import tarfile
from typing import Any
import zipfile
import shutil
import platform
from http.client import HTTPSConnection
ROOT = Path(".").resolve()
ARCH = platform.architecture()[0]
MODES = ("Distribuition", "Usable")
APPNAME = "Counter"
BUILD = "buildtemp"
BUILDPATH = Path(BUILD)
APP = Path(APPNAME)
APPEXEC = Path(F"{APPNAME}.exe")
LOVELIBFILE = Path(f"love.zip")
LOVEPATH = Path("love")
LOVEEXEC = BUILDPATH / Path(f"love.exe")

LIBS = [
    "lsys",
    "component.lua",
    "componentloader.lua",
    "enums",
    "valuebox.lua",
    "util.lua",
    "color.lua",
    "dkjson.lua",
    "config.lua"
]
CONFIGS = [
    "langs",
    "config.json",
    "langsfile.txt"
]

files: dict[str, Path] = {}

def ropen(filename: str, mode: str) -> Any:
    absolutepath = Path(filename).resolve()
    files[absolutepath.name] = Path(filename).resolve()
    return open(filename, mode)

def assrt(x: Any):
    if x is None:
        raise Exception("Null object")
    return x

def download(url: str, filename:str|None=None, maxredirects:int=10, __nredirects: int=0) -> None: # type: ignore
    utilpart = url.split("://")[-1]
    parts = utilpart.split("/", 1)
    host = parts[0]
    path = "/" + parts[1]
    filename = filename or path.split("/")[-1]
    #print("host", host)
    #print('path', path)
    #print("filename", filename)
    conn = HTTPSConnection(host)
    conn.request("GET", path)
    response = conn.getresponse()
    read = 0
    if response.status == 200:
        with ropen(filename, "wb") as f:
            while True:
                chunk = response.read(8192)
                howmuch = len(chunk)
                #print("Read", read + howmuch)
                read += howmuch
                if not chunk:
                    break
                f.write(chunk)
    elif response.status in (301, 302, 307, 308):
        if __nredirects >= maxredirects:
            raise Exception("Redirect limit was reached")
        newurl = response.getheader("Location")
        if not newurl:
            raise Exception("Invalid redirect")
        conn.close()
        return download(newurl, filename, maxredirects, __nredirects + 1)

            
    conn.close()

#-----------CLEAN FUNCTIONS

def cleanpath(path: Path) -> None:
    if path.exists():
        if path.is_file():
            path.unlink()
        else:
            shutil.rmtree(path)

def clean(mode: str) -> None:
    cleanpath(BUILDPATH)
    if mode == "Distribuition":
        cleanpath(APP)
    cleanpath(Path("game.love"))
    

def cleanapp(mode: str) -> None:
    clean(mode)
    cleanpath(APPEXEC)
    cleanpath(APP)
    cleanpath(Path(f"{APPNAME}.zip"))

def cleanall() -> None:
    for v in [x for x in files.values()]:
        unlinkfile(v)


#-------------FILE FUNCTIONS
def registerfile(path: Path) -> None:
    files[str(path.resolve())] = path.resolve()

def unlinkfile(path: Path, delete: bool=True) -> None:
    key = str(path.resolve())
    if path.exists() and key in files:
        if delete:
            cleanpath(files[key])
        del files[key]

def issafe(base: Path, target: Path) -> bool:
    b, t = base.resolve(), target.resolve()
    return b in t.parents or b == t
def tarit(fname: str, folder: Path):
    with tarfile.TarFile(fname, "w") as tarf:
        for archive in folder.rglob("*"):
            if archive.is_file():
                tarf.add(archive)
def zipit(fname: str, folder: Path) -> None:
    with zipfile.ZipFile(fname, "w", zipfile.ZIP_DEFLATED) as zipf:
        for archive in folder.rglob("*"):
            if archive.is_file():
                zipf.write(archive, archive.relative_to(folder))


def untarit(fname: Path, dest: Path, flat:bool=False) -> None:
    with tarfile.open(fname, "r:gz") as tarf:
        if flat:
            for member in tarf.getmembers():
                if member.isdir():
                    continue
                filename = Path(member.name).name
                target = dest / filename
                if not issafe(dest, target):
                    raise Exception(f"Path traversal detected: {target.resolve()}")
                with assrt(tarf.extractfile(member)) as src, open(target, "wb") as dest_:
                    dest_.write(src.read())
        else:
            for member in tarf.getmembers():
                file = Path(member.name)
                if not issafe(dest, dest / file):
                    raise Exception(f"Path traversal detected: {(dest / file).resolve()}")
            tarf.extractall(dest)

def unzipit(fpath: Path, dest: Path, flat: bool=False) -> None:
    with zipfile.ZipFile(fpath, "r") as zipf:
        if flat:
            for info in zipf.infolist():
                if info.is_dir():
                    continue
                filename = Path(info.filename).name
                target = dest / filename
                if not issafe(dest, target):
                    raise Exception(f"Path traversal detected: {target.resolve()}")
                with zipf.open(info, "r") as src, open(target, "wb") as dest_:
                    dest_.write(src.read())
        else:
            for member in zipf.infolist():
                file = Path(member.filename)
                if not issafe(dest, dest / file):
                    raise Exception(f"Path traversal detected: {(dest / file).resolve()}")
            zipf.extractall(dest)
    

def joinfiles(output: Path, *files: Path) -> None:
    with open(output, "wb") as out:
        for file in files:
            with open(file, "rb") as f:
                out.write(f.read())



#-------------------BUILD FUNCTIONS
def prebuild(mode: str) -> None:
    cleanapp(mode)
    BUILDPATH.mkdir()
    registerfile(BUILDPATH)
    print(f"Created {BUILD}/")
    APP.mkdir()
    registerfile(APP)
    print(f"Created {APPNAME}/")



def toroot(filepath: Path, root: Path, dest: Path|None=None) -> None:
    if dest is None:
        dest = filepath
    dest = root / dest
    if filepath.is_file():
        if not dest.parent.exists():
            dest.parent.mkdir(parents=True)
        shutil.copy2(filepath, dest)
    else:
        shutil.copytree(filepath, dest)

def tobuild(filepath: Path, dest: Path|None=None):
    toroot(filepath, BUILDPATH, dest)

def toapp(filepath: Path, dest: Path|None=None):
    toroot(filepath, APP, dest)
def loadlibs() -> None:
    for lib in LIBS:
        tobuild(Path(lib))
        print(f"[LIBS]: loaded {lib if lib != "clibs" else "C libraries"}")
    print("Loaded libraries")

def loadconfigs(whither: Path=BUILDPATH) -> None:
    for config in CONFIGS:
        toroot(Path(config), whither)
        print(f'[CONFIGURATION]: Loaded {config}')
    print(f"Loaded configurations to {whither.name}")

def loadmain() -> None:
    tobuild(Path("main.lua"))
    tobuild(Path("components"))
    print("Loaded main files")


def downloadlove(forcedownloadagain: bool=False):
    if LOVELIBFILE.exists():
        if forcedownloadagain:
            cleanpath(LOVELIBFILE)
        else:
            return

    
    filename = "love-11.5-"
    url = "https://www.github.com/love2d/love/releases/download/11.5/love-11.5-"
    if "64" in ARCH or "32" in ARCH:
        suffix = f"win{64 if "64" in ARCH else "32"}.zip"
        filename += suffix
        url += suffix
    else:
        raise Exception(f"Architeture \"{ARCH}\" not supported.")
    print("Downloading LÖVE from " + url)
    download(url)
    Path(filename).rename(LOVELIBFILE)

def bringlove() -> None:
    downloadlove()
    print("Downloaded love file")
    unzipit(LOVELIBFILE, BUILDPATH, True)
    print("Loaded LÖVE2D")




def build(mode: str, justclean:bool=False):
    if not mode in MODES:
        raise Exception("invalid mode")
    if justclean:
        cleanpath(LOVELIBFILE)
        cleanapp(mode)
        print("Clean!")
        return
    prebuild(mode)
    bringlove()
    loadlibs()
    loadconfigs()
    loadmain()
    

    zipit("game.zip", BUILDPATH)
    file = ROOT / "game.zip"
    file = file.rename("game.love")
    registerfile(file)
    joinfiles(APPEXEC, LOVEEXEC, file)
    registerfile(APPEXEC)
    print(f"Built {APPEXEC.name}")
    toapp(APPEXEC)
    loadconfigs(APP)
    if mode == "Distribuition":
        zipit(f"{APPNAME}.zip", APP)
        registerfile(Path(f"{APPNAME}.zip"))
        cleanpath(APP)
        print("Packaged it")
    clean(mode)
    print("Done!")



if __name__ == "__main__":
    try:
        build("Usable")
    except Exception as e:
        cleanall()
        raise e
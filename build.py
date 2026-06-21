from pathlib import Path
import zipfile
import shutil
import platform
from http.client import HTTPSConnection

MODES = ("Distribuition", "Usable")
APPNAME = "Counter"
BUILD = "buildtemp"
BUILDPATH = Path(BUILD)
APP = Path(APPNAME)
APPEXEC = Path(F"{APPNAME}.exe")
LOVEPATH = Path("love.zip")
ROOT = Path(".").resolve()
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

def ropen(filename, mode):
    absolutepath = Path(filename).resolve()
    files[absolutepath.name] = Path(filename).resolve()
    return open(filename, mode)
def download(url: str, filename:str=None, maxredirects:int=10, __nredirects:int=0) -> None:
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
        conn.close()
        return download(newurl, filename, maxredirects, __nredirects + 1)

            
    conn.close()

def downloadlove(forcedownloadagain: bool=False):
    if LOVEPATH.exists():
        if forcedownloadagain:
            cleanpath(LOVEPATH)
        else:
            return

    os, arch = platform.system(), platform.architecture()[0]
    filename = "love-11.5-"
    url = "https://www.github.com/love2d/love/releases/download/11.5/love-11.5-"
    if os == "Windows":
        suffix = f"win{64 if "64" in arch else "32"}.zip"
        filename += suffix
        url += suffix
    else:
        raise Exception("Platafornna não suportada")
    print("Downloading LÖVE from " + url)
    download(url)
    Path(filename).rename(LOVEPATH)

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

def registerfile(path: Path) -> None:
    files[str(path.resolve())] = path.resolve()

def unlinkfile(path: Path) -> None:
    key = str(path.resolve())
    if path.exists() and key in files:
        cleanpath(files[key])
        del files[key]

def zipit(fname: str, folder: Path) -> None:
    with zipfile.ZipFile(fname, "w", zipfile.ZIP_DEFLATED) as zipf:
        for archive in folder.rglob("*"):
            if archive.is_file():
                zipf.write(archive, archive.relative_to(folder))

def unzipit(fpath: Path, dest: Path, flat: bool=False) -> None:
    with zipfile.ZipFile(fpath, "r") as zipf:
        if flat:
            for info in zipf.infolist():
                if info.is_dir():
                    continue
                filename = Path(info.filename).name
                target = dest / filename
                with zipf.open(info, "r") as src, open(target, "wb") as dest_:
                    dest_.write(src.read())
        else:
            zipf.extractall(dest)
    

def prebuild(mode: str) -> None:
    cleanapp(mode)
    BUILDPATH.mkdir()
    registerfile(BUILDPATH)
    print(f"Created {BUILD}/")
    APP.mkdir()
    registerfile(APP)
    print(f"Created {APPNAME}/")



def toroot(filepath: Path, root: Path, dest: Path=None) -> None:
    if dest is None:
        dest = filepath
    dest = root / dest
    if filepath.is_file():
        if not dest.parent.exists():
            dest.parent.mkdir(parents=True)
        shutil.copy2(filepath, dest)
    else:
        shutil.copytree(filepath, dest)

def tobuild(filepath: Path, dest: Path=None):
    toroot(filepath, BUILDPATH, dest)

def toapp(filepath: Path, dest: Path=None):
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

def bringlove() -> None:
    downloadlove()
    print("Downloaded love.zip")
    unzipit(LOVEPATH, BUILDPATH, True)
    print("Loaded LÖVE2D")


def joinfiles(output: Path, *files: Path) -> None:
    with open(output, "wb") as out:
        for file in files:
            with open(file, "rb") as f:
                out.write(f.read())

def build(mode: str, justclean=False):
    if not mode in MODES:
        raise Exception("invalid mode")
    if justclean:
        cleanpath(LOVEPATH)
        cleanapp()
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
    joinfiles(APPEXEC.name, BUILDPATH / "love.exe", file)
    registerfile(APPEXEC)
    print(f"Built {APPEXEC.name}")
    toapp(APPEXEC)
    loadconfigs(APP)
    if mode == "Usable":
        zipit(f"{APPNAME}.zip", APP)
        registerfile(Path(f"{APPNAME}.zip"))
        print("Packaged it")
    clean(mode)
    print("Done!")


try:
    build("Usable")
except Exception as e:
    cleanall()
    raise e

# Packaging Strait Bible for Linux

What is in this folder:

| File | What it is |
|---|---|
| `build-linux.sh` | builds the program with `lazbuild` (GTK2) from a clean checkout |
| `install-linux.sh` | installs the built program into `DESTDIR`/`PREFIX` (binary, modules, translations, icons, desktop file) |
| `straitbible.desktop` | menu entry |
| `io.github.doonoo.StraitBible.metainfo.xml` | AppStream data (needed by software centers, Flathub, ...) |
| `arch/PKGBUILD` | AUR package (`straitbible-git`, builds the latest commit) |
| `../straitbible.spec`, `../straitbible.dbp` | the rpm spec and the Debreate project that came with Unbound Bible (renamed, still to be updated) |
| `../straitbible.svg`, `../straitbible.png` | the logo |

**Status:** the program was written and tested on Windows. Nothing in this folder has been run on Linux yet. Build it in
a clean environment first (a container or a chroot) and fix what does not work before publishing anything.

## Where it can be published, and what each place needs

Publishing needs an account of its own on every site, and the sites ask for it by name, so it has to be done by the
maintainer (you) - nobody else can do it for you.

| Where | Who can use it | What you need | How |
|---|---|---|---|
| **AUR** (Arch, Manjaro, EndeavourOS) | Arch based systems, through `yay` / `paru` | an AUR account and an SSH key | `git clone ssh://aur@aur.archlinux.org/straitbible-git.git`, copy `arch/PKGBUILD`, run `makepkg --printsrcinfo > .SRCINFO`, commit and push. Test first with `makepkg -s` in a clean chroot (`extra-x86_64-build`). |
| **GitHub Releases** (no account besides GitHub) | everybody, as a download | the GitHub repository | attach a `.tar.gz` of the built program (and an AppImage, see below) to a release |
| **Flathub** (Flatpak) | every distribution | a pull request to `flathub/flathub`, a manifest | needs a manifest that builds Free Pascal / Lazarus inside the Flatpak sandbox (heavy) or uses a prebuilt binary from a release; the app id is `io.github.doonoo.StraitBible` |
| **Snap Store** | Ubuntu and others | a Snapcraft account | `snapcraft.yaml` with a Lazarus build part |
| **Debian / Ubuntu** | the `.deb` family | for the official archive: a sponsor (mentors.debian.net); for your own repository: a Launchpad account (PPA) | `debian/` directory (control, rules, changelog, copyright); the old `straitbible.dbp` has the control data |
| **Fedora** | Fedora, RHEL family | a Fedora account, a package review; or COPR for a repository of your own | `straitbible.spec` (needs the build steps filled in) |
| **openSUSE Build Service** | openSUSE, and it can build for many distributions | an OBS account | spec or Debian files |
| **Nixpkgs, Gentoo overlay, ...** | Nix, Gentoo users | a pull request | a package description in the format of the distribution |
| **AppImage** | every distribution, as one file | nothing besides a build machine | `appimagetool` over an AppDir made with `install-linux.sh` |

The usual order is: build a tarball and an AppImage for GitHub Releases first, then the AUR, then the rest once
people ask for them. Every package should declare the GPL-3.0 license and say that the program is based on Unbound
Bible by Vladimir Rybant.

Distribution rules to be aware of: the program contains Bible translations in `modules/`. Their licenses decide whether
a distribution may ship them (some modern translations are copyrighted). Before sending the program to an official
repository, check that every module may be redistributed, or build a smaller package without the modules.

## Prebuilt Linux download

`.github/workflows/linux-build.yml` builds the program on GitHub (Ubuntu 22.04) and produces
`straitbible-linux-x86_64.tar.gz`. Start it from the Actions tab of the repository ("Linux build" -> "Run workflow"), or
push a tag such as `v1.0` and the file is attached to a release. It has not been run yet.

Unbound Bible
===========

The Unbound Bible is an open source and a free, multilingual Bible-reader program for Windows, macOS and Linux. This is fast and effective way to explore bibles.


Changes in this fork
--------------------

**Compare**
- Next-verse link (`Genesis 1:6 »`) and, new, a previous-verse link (`« Genesis 1:4`) at the top of the Compare page. Going back crosses chapter and book boundaries.

**Copy Verses**
- *Translation name* option appends the translation name to the copied reference.
- *Abbreviate translation name* option uses the translation's abbreviation instead (e.g. `NKJV`). Modules without an abbreviation of their own use their file name (`NKJV.SQLite3` gives `NKJV`).

**Fonts** (Tools → Options)
- *Add font...* adds your own `.ttf` / `.otf` files. They are copied to the `Fonts` folder of the data directory and loaded on every start.
- Any `.ttf` / `.otf` placed in `Fonts` (data directory) or in a `fonts` folder next to the program is loaded automatically, so a set of fonts can be shipped with the program.
- Windows: fonts are registered for the running program only, nothing is installed system-wide. Linux: fonts are copied to `~/.local/share/fonts/unboundbible` and the font cache is refreshed; restart the program to see them.

**Grey notes** (Tools → Options)
- Some translations (the Amplified Bible, for example) put extra text in grey brackets inside the verse. *Grey notes* controls it: *Show* (the original behavior), *Show on hover* (each note is collapsed to a small `[+1]`, `[+2]`… marker and its text opens in a popup when the pointer rests on it) or *Hide* (removed from the Bible and Compare pages; in hover mode the Compare page shows the notes in full).
- The blue footnote markers (`[1]`, `[2]`…) are not affected and still open when clicked.

**Themes** (Tools → Options)
- Built-in themes: *Light*, *Dark*, *Sepia*, *Solarized Dark* and *High Contrast*, plus *System default*.
- *Customize theme...* opens a color editor (background, text, links, Strong's numbers, footnotes, words of Christ, notes, cross-references) and saves the result under a name you choose.
- A theme colors the whole window: text areas, book and chapter lists, panels, toolbar, status bar, search box and the footnote / Strong's popup. On Windows the title bar (dark mode and caption color need Windows 10 2004 / Windows 11), the menu bar (Tools, Edit, Notes, Help), the tab headers and the scroll bars follow the theme too (`unitchrome.pas`). The drop-down menus and the right-click menus are drawn in the theme colors, dark toolbar and menu icons are lightened on dark themes, and the other windows (Options, Copy Verses, Search, ...) are themed when they are shown. Native push buttons keep the system look. If a Windows call is not available the part simply keeps the system look. Other systems keep the system look for these parts.
- Custom themes are plain `.ini` files in the `Themes` folder of the data directory and can also be written by hand:

```ini
[Theme]
Background=1E1E1E
Text=DCDCDC
Link=FF9900
Strong=FD971F
Footnote=66CCCC
Words=E54242
Note=A0A0A0
Red=FF5050
```

  Colors are `RRGGBB`. Keep the link, Strong's, footnote and words colors different from each other, because the program tells clickable text apart by its color.

Build Instructions
------------------

(Tested under Linux.)

Install ZeosDBO (see the [Lazarus wiki](https://wiki.freepascal.org/ZeosDBO) for full instructions):

```bash
$ cd components
$ svn co http://svn.code.sf.net/p/zeoslib/code-0/trunk
$ mv trunk zeosdb
$ cd ..
```

Compile the dependent packages:

```bash
$ lazbuild components/zeosdb/packages/lazarus/zcomponent.lpk
$ lazbuild components/richmemo/richmemopackage.lpk
$ lazbuild components/unboundmemo/unboundmemopackage.lpk
```

Build unboundbible:

```bash
$ lazbuild unboundbible.lpr
```

The binary will be in the current folder.



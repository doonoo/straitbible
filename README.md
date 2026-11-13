<p align="center"><img src="straitbible.png" alt="Strait Bible: a scroll behind a gate" width="128"></p>

Strait Bible
============

Strait Bible is an open source and free, multilingual Bible-reader program for Windows and Linux, to read, compare
and study the Bible in many translations, with themes, your own fonts and background pictures, bookmarks,
highlights, notes and reading plans.

The name and the logo, a scroll behind a gate, come from Matthew 7:13-14: *"Enter ye in at the strait gate ...
strait is the gate, and narrow is the way, which leadeth unto life."*


Credits and license
-------------------

This program is based on **Unbound Bible** by **Vladimir Rybant**
([github.com/vrybant/unboundbible](https://github.com/vrybant/unboundbible)), who wrote the program, the
Bible module formats and the RichMemo based text view that everything here builds on. It is free software,
published under the **GNU General Public License v3** (see `LICENSE`), like the original. The original
copyright notices stay in the source files.

Your data and the old name
--------------------------

Strait Bible keeps working with the folders of Unbound Bible: if a folder `Unbound Bible` (your Bibles,
notes and modules) or the settings of Unbound Bible already exist on the computer, they keep being used, so
nothing is lost. A new installation uses folders named `Strait Bible` (Windows) and `~/.config/straitbible` (Linux).

What is new compared to Unbound Bible
-------------------------------------

**Compare**
- Next-verse link (`Genesis 1:6 »`) and, new, a previous-verse link (`« Genesis 1:4`) at the top of the Compare page. Going back crosses chapter and book boundaries.

**Copy Verses**
- *Translation name* option appends the translation name to the copied reference.
- *Abbreviate translation name* option uses the translation's abbreviation instead (e.g. `NKJV`). Modules without an abbreviation of their own use their file name (`NKJV.SQLite3` gives `NKJV`).

**Bookmarks and reading**
- *Bookmarks* menu (between Notes and Help): *Add bookmark* (Ctrl+D) saves the current verse, the saved verses are listed in the menu and open when clicked, and *Remove* deletes one. Bookmarks are kept in the `[Bookmarks]` section of `config.ini`.
- *Highlight verse* (Bookmarks menu, Ctrl+1 ... Ctrl+5, Ctrl+0 to remove) colors the selected verse(s) yellow, green, blue, pink or orange. Highlights are saved in `config.ini` and adapt to the theme so the text stays readable.
- *Verse of the day* (Bookmarks menu) opens one of 76 well-known verses, the same all day. Options → *Show the verse of the day on startup* does it automatically.
- *Reading plan...* (Bookmarks menu): the Bible in a year, about three chapters a day. Tick the chapters you have read, see your progress, jump to the next unread chapter, or restart the plan.
- *My highlights* and *My bookmarks* (Bookmarks menu) list those verses with their text in the order of the Bible; a click on a reference opens the verse.
- The reading plan can be the Bible in a year, the New Testament in 90 days, or Psalms and Proverbs in 60 days. Chapters marked as read count in every plan.
- *Note for this verse...* (Bookmarks menu) lets you write your own note for the selected verse. It is shown in italics after the verse, and *My notes* lists all of them. Notes are saved in `config.ini`.
- *Read aloud* (F5, Windows): the chapter is read with the voice of the system, from the selected verse. Choose it again to stop.
- *Chapter* submenu: *Copy chapter* (Ctrl+Shift+C) and *Save chapter as text file...*.
- *My data* submenu: back up the bookmarks, highlights, notes and reading plan to a file, and restore them from one (for example on another computer).
- Ctrl+G: jump to the reference box (type for example `John 3:16` and press Enter).
- Options → *Background*: a picture (jpg, png or bmp) behind the text of every page, as *cover*, *stretch* or *tile*, with a *Visibility* slider (a low value keeps the text easy to read). Windows only: the text areas are painted by `unitbackground.pas`.
- Options → *Text margins* (none, small, medium, large) and *Justify the text*.
- Options → *Night theme*: a theme that is used automatically from 19:00 to 07:00.
- *Random verse* (Bookmarks menu).
- The text colors follow the theme on Windows too (the text, links, notes, footnotes, words of Christ and Strong's numbers).
- Options → *Line spacing*: normal, relaxed, wide or double, for the Bible and Compare pages.
- Settings (font, size, theme, ...) are written to `config.ini` as soon as they are changed.
- Ctrl+Left / Ctrl+Right: previous / next chapter, across the books (not on the Notes page, where they move by word).
- Ctrl + mouse wheel over the text: bigger / smaller text. The size is remembered.
- F11: full screen. F9: hide / show the list of books and chapters.

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

Build Strait Bible:

```bash
$ lazbuild straitbible.lpi
```

The binary (`straitbible_<os>`, for example `straitbible_win64.exe`) will be in the current folder.

Notes: ZeosLib 7.2.x (for example the `7.2.14-stable` branch of
[marsupilami79/zeoslib](https://github.com/marsupilami79/zeoslib)) builds with Free Pascal 3.2.2; its 8.0 branch needs a newer compiler.
On Windows the program expects `sqlite3.dll` next to the executable.



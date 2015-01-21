# DocsEmbedder

**PLEASE NOTE THAT THIS IS BETA SOFTWARE. I'M IN NO WAY RESPONSIBLE FOR ANY DATA LOSS.**

<p align="center">
  <img src="docs/docs/img/img001.png" alt="DocsEmbedder"/>
</p>


*DocsEmbedder* is a tool that allows to embed a set of documentation files, html related, inside a **PE** (portable executable) file. The documentation can then be referenced and visualized using the **res://** protocol with a compatible browser or ActiveX control.

One of the way to embed a documentation is to write the desired markdown files, build a site with [MkDocs](http://www.mkdocs.org/) and then embed the resulting files with *DocsEmbedder*, flattening them first. This document is actually embedded in the binary release of *DocsEmbedder* and can be visualized clicking on its **Help** menu item.

### Download

The build archive is [here on GitHub](https://github.com/cyruz-git/DocsEmbedder/releases).

### How it works

*DocsEmbedder* loops over a desired directory, loading all files and embedding them inside the desired PE file, through the Win32 [UpdateResource](http://msdn.microsoft.com/en-us/library/windows/desktop/ms648049%28v=vs.85%29.aspx) function. Because of a documentation site being often structured in multiple subfolders, *DocsEmbedder* can **flatten** the desired directory, moving all subfolders files to the root directory and changing all the **href** and **src** attributes in the html files according to the new structure. A **temporary folder** can be used to avoid any change to the actual files.

*DocsEmbedder* can embed the files in a pre-existing PE file or generate a new one with the desired name and extension. The generated file is a hardcoded executable, compiled with Visual C++ 2010 Express, optimized to keep the size less than 1 KB. If run, the generated executable shows a message box and returns.

### Remarks

* There could be issues if the documentation is embedded on a **compressed** executable that already contains resources. The correct behaviour would be to embed the documentation first and then compress the executable, or use a standalone file.

* The site must be **flat** (all the resources must reside in the root folder) because of the limitations of the PE format. The flattening feature of the program must be used if the documentation site cannot be organized in a single flat folder.

* All the resources will be stored inside the PE file using their **filename** (with extension) as resource name, **RT_HTML** as resource type and a **neutral** language identifier. 

* Because of some limitations of the **res://** protocol, filenames cannot contain exclusively digits (or/and spaces), so they must be named carefully. E.g. "001.png" doesn't work, "img001.png" works.

* The embedded files can be referenced only by a compatible viewer (like **Internet Explorer**).

### Files

Name | Description
-----|------------
docs\ | Folder containing the documentation, built with MkDocs.
lib\ | Folder containing the required libraries.
COPYING | GNU General Public License.
COPYING.LESSER | GNU Lesser General Public License.
DocsEmbedder.ahk | Main source file.
Icon.ico | Program's icon file.
LibSetup.ahk | Libraries setup script.
Logo.png | Program's logo file.
README.md | This document.

### How to compile

*DocsEmbedder* should be compiled with the **Ahk2Exe** compiler, that can be downloaded from the [AHKscript download page](http://ahkscript.org/download/).

Run the `LibSetup.ahk` script in advance to retrieve the required libraries from GitHub.

Browse to the files so that the fields are filled as follows:

    Source:      path\to\DocsEmbedder.ahk
    Destination: path\to\DocsEmbedder.exe
    Custom Icon: path\to\Icon.ico

Select a **Base File** indicating your desired build and click on the **> Convert <** button. Don't use **MPRESS**.

Embed the documentation into the resulting exe using the script version of the program.

The documentation site is built with [MkDocs](http://www.mkdocs.org/).

### License

*DocsEmbedder* is released under the terms of the [GNU Lesser General Public License](http://www.gnu.org/licenses/). The program logo contains an icon from the [Pretty Office Icon Set Part 7](http://www.customicondesign.com/free-icons/pretty-office-icon-set/pretty-office-icon-set-part-7/), released under the term of [CustomIconDesign License Agreement](http://www.customicondesign.com/license-agreement/).

### Contact

For hints, bug reports or anything else, you can contact me at [focabresm@gmail.com](mailto:focabresm@gmail.com), open a issue on the dedicated [GitHub repo](https://github.com/cyruz-git/DocsEmbedder) or use the [AHKscript development thread](http://ahkscript.org/boards/viewtopic.php?f=6&t=5918).
# BatchTools

**BatchTools** is a collection of batch scripts for video downloading, conversion, and audio extraction, designed for easy use on Windows. It automates common media tasks using `FFmpeg` and `yt-dlp`.

## Features
- **Downloader Tool** - Download videos from supported websites.
- **Converter Tool** - Convert HEVC/non-MP4 videos into MP4.
- **Audio Extractor Tool** - Extract audio from video files.
- **Command Prompt Access** - Quickly open CMD in the installation directory.
- **Uninstaller** - Easily remove BatchTools when needed.

## Installation
1. **Download and Extract**  
   - Download the repository as a ZIP file or clone it.
   - Ensure `BatchTools.zip` and `installer.bat` are in the same directory.

2. **Run the Installer**  
   - Double-click `installer.bat` and allow administrator privileges.
   - The tools will be installed in `C:\ProgramData\BatchToolsData` or `%LocalAppData%\BatchToolsData` (if needed).
   - A shortcut (`Tools.lnk`) will be placed on your desktop.

3. **Verify Installation**  
   - Open `Tools.lnk` to access the BatchTools menu.
   - Ensure `FFmpeg` and `yt-dlp` are installed. The installer will handle this automatically if they are missing.

## Uninstallation
1. Open `Tools.lnk` and choose option `6` to uninstall.
2. Alternatively, run `uninstaller.bat` inside the installation directory( Which is     C:\ProgramData\BatchTools, or %LocalAppData%\BatchToolsData(If you didnt find the    C:\ProgramData\BatchTools path))

## Notes
- If `yt-dlp` or `FFmpeg` is already installed, the installer will not remove them.
- If `yt-dlp` and/or `FFmpeg` is allready installed in your system, the installer will not reinstall `yt-dlp` and\or `FFmpeg` but makes the installation much quicker
- **Customizing**: Modify files in the `src` folder before compressing `BatchTools.zip` for redistribution.

## Contributing
Feel free to submit issues or suggest improvements. If you modify the tools, consider sharing updates with the community!

## License
This project is licensed under the **MIT License**. See `LICENSE` for details.

---

Created by [witcarryllanto123]  
Contact: [My email: witcarryllanto@gmail.com,
          My FB Account: https://www.facebook.com/profile.php?id=61554846134169]  

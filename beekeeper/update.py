#!/usr/bin/env python

import os
import requests

DOTFILES = os.getenv("DOTFILES")
USER = os.getenv("USER")
HOME = os.getenv("HOME")
TMP = "/tmp"
DESKTOP_FILE = f"{HOME}/.local/share/applications/Beekeeper.desktop"
RELEASES_URL = "https://api.github.com/repos/beekeeper-studio/beekeeper-studio/releases"
APP = "/opt/beekeeper"
EXTENSION = ".AppImage"


def get_latest_release():
    response = requests.get(RELEASES_URL)
    latest_version = response.json()[0]["tag_name"].removeprefix("v")
    file_end = latest_version + EXTENSION
    browser_download_url = ""
    filename = ""

    for asset in response.json()[0]["assets"]:
        if file_end in asset["browser_download_url"]:
            browser_download_url = asset["browser_download_url"]
            filename = asset["name"]

    path_to_latest_version = f"{APP}/{filename}"
    path_to_tmp = f"{TMP}/{filename}"
    return (latest_version, browser_download_url, path_to_latest_version, path_to_tmp)


def get_current_version():
    with open(DESKTOP_FILE, encoding="utf-8") as file:
        for line in file:
            if "Version=" in line:
                return line.replace("Version=", "").strip()
    return None


def load_latest_release(browser_download_url, path_to_latest_version, path_to_tmp):
    print("Loading", browser_download_url)
    response = requests.get(browser_download_url)

    with open(path_to_tmp, "wb") as file:
        file.write(response.content)

    os.system(f"sudo mv {path_to_tmp} {path_to_latest_version}")


def update_desktop_file(path_to_latest_version, latest_version):
    print("Updating the desktop file", DESKTOP_FILE)
    with open(DESKTOP_FILE, encoding="utf-8") as desktop_file:
        desktop_lines = desktop_file.readlines()

    updated_desktop_lines = []
    for line in desktop_lines:
        if "Version=" in line:
            updated_desktop_lines.append(f"Version={latest_version}\n")
        elif "Exec=" in line:
            updated_desktop_lines.append(f"Exec={path_to_latest_version}\n")
        else:
            updated_desktop_lines.append(line)

    with open(DESKTOP_FILE, "w", encoding="utf-8") as desktop_file:
        desktop_file.writelines(updated_desktop_lines)


def update_app():
    (
        latest_version,
        browser_download_url,
        path_to_latest_version,
        path_to_tmp,
    ) = get_latest_release()
    current_version = get_current_version()
    print("Updating Beekeeper")

    if latest_version == current_version:
        print("Beekeeper has already updated")
    else:
        load_latest_release(browser_download_url, path_to_latest_version, path_to_tmp)
        update_desktop_file(path_to_latest_version, latest_version)


update_app()

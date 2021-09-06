#!/usr/bin/env python
# -*- coding: utf-8 -*-

import git
import os

def create_dir():
    if not os.path.exists("modules"):
        os.mkdir("modules")
    return

def strip_url(url):
    return url.split("/")[-1].replace(".git", "")

def check_lock(url):
    if os.path.exists(os.path.join(os.getcwd(), "modules", strip_url(url), ".git", "index.lock")):
        return True
    else:
        return False

def clone_or_pull_repo(url):
    git_dir = os.path.join("modules", strip_url(url))
    if os.path.exists(git_dir):
        repo = git.Git(git_dir)
        repo.checkout("main")
        print("Pull changes for module repository %s" % strip_url(url))
        repo.pull()
        return repo
    else:
        print("Clone module repository %s to modules/" % url)
        repo = git.Git("modules").clone(url)
        return git.Git(git_dir)

def git_module(config):
    create_dir()
    if check_lock(config["url"]):
        return
    repo = clone_or_pull_repo(config["url"])
    print("Checkout %s for module repository %s" % (config["tag"], strip_url(config["url"])))
    repo.checkout(config["tag"])
    return

def git_modules(config):
    for module in config:
        git_module(config[module])
    return

def path_snakefile(module):
    return os.path.join(os.getcwd(), "modules", module, "workflow", "Snakefile")
